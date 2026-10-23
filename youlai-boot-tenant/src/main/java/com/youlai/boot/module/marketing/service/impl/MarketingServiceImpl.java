package com.youlai.boot.module.marketing.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youlai.boot.common.exception.BusinessException;
import com.youlai.boot.framework.security.util.SecurityUtils;
import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.module.marketing.mapper.MarketingChannelMapper;
import com.youlai.boot.module.marketing.mapper.MarketingFollowUpMapper;
import com.youlai.boot.module.marketing.mapper.MarketingLeadMapper;
import com.youlai.boot.module.marketing.mapper.MarketingSpaceMapper;
import com.youlai.boot.module.asset.mapper.AssetBuildingMapper;
import com.youlai.boot.module.asset.mapper.AssetFloorMapper;
import com.youlai.boot.module.asset.mapper.AssetParkMapper;
import com.youlai.boot.module.asset.mapper.AssetRegionMapper;
import com.youlai.boot.module.asset.model.entity.AssetBuilding;
import com.youlai.boot.module.asset.model.entity.AssetFloor;
import com.youlai.boot.module.asset.model.entity.AssetPark;
import com.youlai.boot.module.asset.model.entity.AssetRegion;
import com.youlai.boot.module.marketing.model.entity.MarketingChannel;
import com.youlai.boot.module.marketing.model.entity.MarketingFollowUp;
import com.youlai.boot.module.marketing.model.entity.MarketingLead;
import com.youlai.boot.module.marketing.model.entity.MarketingSpace;
import com.youlai.boot.module.marketing.model.form.MarketingChannelForm;
import com.youlai.boot.module.marketing.model.form.MarketingFollowUpForm;
import com.youlai.boot.module.marketing.model.form.MarketingLeadAssignForm;
import com.youlai.boot.module.marketing.model.form.MarketingLeadForm;
import com.youlai.boot.module.marketing.model.form.MarketingSpaceForm;
import com.youlai.boot.module.marketing.model.query.MarketingChannelPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingFollowUpPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingLeadPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingSpacePageQuery;
import com.youlai.boot.module.marketing.model.vo.MarketingChannelConversionVO;
import com.youlai.boot.module.marketing.model.vo.MarketingOverviewVO;
import com.youlai.boot.module.marketing.model.vo.PublicMarketingSpaceVO;
import com.youlai.boot.module.marketing.service.MarketingService;
import com.youlai.boot.system.mapper.UserMapper;
import com.youlai.boot.system.model.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MarketingServiceImpl implements MarketingService {

    private final MarketingChannelMapper channelMapper;
    private final MarketingLeadMapper leadMapper;
    private final MarketingFollowUpMapper followUpMapper;
    private final MarketingSpaceMapper spaceMapper;
    private final AssetParkMapper assetParkMapper;
    private final AssetRegionMapper assetRegionMapper;
    private final AssetBuildingMapper assetBuildingMapper;
    private final AssetFloorMapper assetFloorMapper;
    private final UserMapper userMapper;

    @Override
    public Page<MarketingChannel> getChannelPage(MarketingChannelPageQuery query) {
        return channelMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()),
                new LambdaQueryWrapper<MarketingChannel>()
                        .and(StrUtil.isNotBlank(query.getKeyword()), w -> w
                                .like(MarketingChannel::getCode, query.getKeyword())
                                .or().like(MarketingChannel::getName, query.getKeyword()))
                        .eq(StrUtil.isNotBlank(query.getChannelType()), MarketingChannel::getChannelType, query.getChannelType())
                        .eq(query.getStatus() != null, MarketingChannel::getStatus, query.getStatus())
                        .orderByDesc(MarketingChannel::getCreateTime));
    }

    @Override
    public MarketingChannel getChannel(Long id) {
        MarketingChannel channel = channelMapper.selectById(id);
        if (channel == null) {
            throw new BusinessException("渠道不存在");
        }
        return channel;
    }

    @Override
    @Transactional
    public boolean saveChannel(MarketingChannelForm form) {
        ensureChannelCodeAvailable(form.getCode(), null);
        MarketingChannel channel = BeanUtil.copyProperties(form, MarketingChannel.class);
        channel.setCreateBy(SecurityUtils.getUserId());
        channel.setUpdateBy(SecurityUtils.getUserId());
        return channelMapper.insert(channel) > 0;
    }

    @Override
    @Transactional
    public boolean updateChannel(Long id, MarketingChannelForm form) {
        MarketingChannel channel = getChannel(id);
        ensureChannelCodeAvailable(form.getCode(), id);
        BeanUtil.copyProperties(form, channel);
        channel.setId(id);
        channel.setUpdateBy(SecurityUtils.getUserId());
        return channelMapper.updateById(channel) > 0;
    }

    @Override
    @Transactional
    public void deleteChannels(String ids) {
        List<Long> idList = parseIds(ids);
        long references = leadMapper.selectCount(new LambdaQueryWrapper<MarketingLead>()
                .in(MarketingLead::getChannelId, idList));
        if (references > 0) {
            throw new BusinessException("渠道已被线索引用，不能删除");
        }
        channelMapper.delete(new LambdaQueryWrapper<MarketingChannel>().in(MarketingChannel::getId, idList));
    }

    @Override
    public Page<MarketingLead> getLeadPage(MarketingLeadPageQuery query) {
        Page<MarketingLead> page = leadMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()),
                new LambdaQueryWrapper<MarketingLead>()
                        .and(StrUtil.isNotBlank(query.getKeyword()), w -> w
                                .like(MarketingLead::getCustomerName, query.getKeyword())
                                .or().like(MarketingLead::getCompanyName, query.getKeyword())
                                .or().like(MarketingLead::getContactName, query.getKeyword())
                                .or().like(MarketingLead::getPhone, query.getKeyword()))
                        .eq(query.getChannelId() != null, MarketingLead::getChannelId, query.getChannelId())
                        .eq(StrUtil.isNotBlank(query.getStage()), MarketingLead::getStage, query.getStage())
                        .eq(query.getAssigneeId() != null, MarketingLead::getAssigneeId, query.getAssigneeId())
                        .orderByDesc(MarketingLead::getUpdateTime));
        enrichLeadNames(page.getRecords());
        return page;
    }

    @Override
    public MarketingLead getLead(Long id) {
        MarketingLead lead = leadMapper.selectById(id);
        if (lead == null) {
            throw new BusinessException("线索不存在");
        }
        return lead;
    }

    @Override
    public MarketingLead getLeadDetail(Long id) {
        MarketingLead lead = getLead(id);
        enrichLeadNames(List.of(lead));
        return lead;
    }

    @Override
    @Transactional
    public boolean saveLead(MarketingLeadForm form) {
        validateLeadReferences(form.getChannelId(), form.getSpaceId(), form.getAssigneeId());
        MarketingLead lead = BeanUtil.copyProperties(form, MarketingLead.class);
        lead.setCreateBy(SecurityUtils.getUserId());
        lead.setUpdateBy(SecurityUtils.getUserId());
        return leadMapper.insert(lead) > 0;
    }

    @Override
    @Transactional
    public boolean updateLead(Long id, MarketingLeadForm form) {
        MarketingLead lead = getLead(id);
        validateLeadReferences(form.getChannelId(), form.getSpaceId(), null);
        Long assigneeId = lead.getAssigneeId();
        BeanUtil.copyProperties(form, lead);
        lead.setId(id);
        lead.setAssigneeId(assigneeId);
        lead.setUpdateBy(SecurityUtils.getUserId());
        return leadMapper.updateById(lead) > 0;
    }

    @Override
    @Transactional
    public void deleteLeads(String ids) {
        List<Long> idList = parseIds(ids);
        followUpMapper.delete(new LambdaQueryWrapper<MarketingFollowUp>().in(MarketingFollowUp::getLeadId, idList));
        leadMapper.delete(new LambdaQueryWrapper<MarketingLead>().in(MarketingLead::getId, idList));
    }

    @Override
    @Transactional
    public boolean assignLead(Long id, MarketingLeadAssignForm form) {
        MarketingLead lead = getLead(id);
        validateAssignee(form.getAssigneeId());
        lead.setAssigneeId(form.getAssigneeId());
        lead.setUpdateBy(SecurityUtils.getUserId());
        return leadMapper.updateById(lead) > 0;
    }

    @Override
    public Page<MarketingFollowUp> getFollowUpPage(Long leadId, MarketingFollowUpPageQuery query) {
        getLead(leadId);
        return followUpMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()),
                new LambdaQueryWrapper<MarketingFollowUp>()
                        .eq(MarketingFollowUp::getLeadId, leadId)
                        .orderByDesc(MarketingFollowUp::getCreateTime));
    }

    @Override
    public MarketingFollowUp getFollowUpDetail(Long leadId, Long followUpId) {
        getLead(leadId);
        return getFollowUp(leadId, followUpId);
    }

    @Override
    @Transactional
    public boolean saveFollowUp(Long leadId, MarketingFollowUpForm form) {
        getLead(leadId);
        MarketingFollowUp followUp = BeanUtil.copyProperties(form, MarketingFollowUp.class);
        followUp.setLeadId(leadId);
        followUp.setCreateBy(SecurityUtils.getUserId());
        followUp.setUpdateBy(SecurityUtils.getUserId());
        return followUpMapper.insert(followUp) > 0;
    }

    @Override
    @Transactional
    public boolean updateFollowUp(Long leadId, Long followUpId, MarketingFollowUpForm form) {
        getLead(leadId);
        MarketingFollowUp followUp = getFollowUp(leadId, followUpId);
        BeanUtil.copyProperties(form, followUp);
        followUp.setId(followUpId);
        followUp.setLeadId(leadId);
        followUp.setUpdateBy(SecurityUtils.getUserId());
        return followUpMapper.updateById(followUp) > 0;
    }

    @Override
    @Transactional
    public void deleteFollowUps(Long leadId, String ids) {
        getLead(leadId);
        followUpMapper.delete(new LambdaQueryWrapper<MarketingFollowUp>()
                .eq(MarketingFollowUp::getLeadId, leadId)
                .in(MarketingFollowUp::getId, parseIds(ids)));
    }

    @Override
    public Page<MarketingSpace> getSpacePage(MarketingSpacePageQuery query) {
        Page<MarketingSpace> page = spaceMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()),
                new LambdaQueryWrapper<MarketingSpace>()
                        .and(StrUtil.isNotBlank(query.getKeyword()), w -> w
                                .like(MarketingSpace::getSpaceCode, query.getKeyword())
                                .or().like(MarketingSpace::getProjectName, query.getKeyword())
                                .or().like(MarketingSpace::getBuildingName, query.getKeyword())
                                .or().like(MarketingSpace::getFloorName, query.getKeyword())
                                .or().like(MarketingSpace::getRoomNo, query.getKeyword())
                                .or().like(MarketingSpace::getDisplayTitle, query.getKeyword()))
                        .like(StrUtil.isNotBlank(query.getProjectName()), MarketingSpace::getProjectName, query.getProjectName())
                        .eq(query.getParkId() != null, MarketingSpace::getParkId, query.getParkId())
                        .eq(query.getBuildingId() != null, MarketingSpace::getBuildingId, query.getBuildingId())
                        .eq(StrUtil.isNotBlank(query.getAvailability()), MarketingSpace::getAvailability, query.getAvailability())
                        .eq(query.getPublishStatus() != null, MarketingSpace::getPublishStatus, query.getPublishStatus())
                        .orderByDesc(MarketingSpace::getUpdateTime));
        enrichSpaceLocations(page.getRecords());
        return page;
    }

    @Override
    public MarketingSpace getSpace(Long id) {
        MarketingSpace space = spaceMapper.selectById(id);
        if (space == null) {
            throw new BusinessException("房源不存在");
        }
        return space;
    }

    @Override
    @Transactional
    public boolean saveSpace(MarketingSpaceForm form) {
        ensureSpaceCodeAvailable(form.getSpaceCode(), null);
        validateSpaceLocation(form);
        MarketingSpace space = BeanUtil.copyProperties(form, MarketingSpace.class);
        space.setCreateBy(SecurityUtils.getUserId());
        space.setUpdateBy(SecurityUtils.getUserId());
        return spaceMapper.insert(space) > 0;
    }

    @Override
    @Transactional
    public boolean updateSpace(Long id, MarketingSpaceForm form) {
        MarketingSpace space = getSpace(id);
        ensureSpaceCodeAvailable(form.getSpaceCode(), id);
        validateSpaceLocation(form);
        BeanUtil.copyProperties(form, space);
        space.setId(id);
        space.setUpdateBy(SecurityUtils.getUserId());
        return spaceMapper.updateById(space) > 0;
    }

    @Override
    @Transactional
    public void deleteSpaces(String ids) {
        List<Long> idList = parseIds(ids);
        long references = leadMapper.selectCount(new LambdaQueryWrapper<MarketingLead>()
                .in(MarketingLead::getSpaceId, idList));
        if (references > 0) {
            throw new BusinessException("房源已被线索引用，不能删除");
        }
        spaceMapper.delete(new LambdaQueryWrapper<MarketingSpace>().in(MarketingSpace::getId, idList));
    }

    @Override
    public Page<PublicMarketingSpaceVO> getPublicSpacePage(MarketingSpacePageQuery query) {
        Page<MarketingSpace> source = new Page<>(query.getPageNum(), query.getPageSize());
        if (TenantContextHolder.getTenantId() == null) {
            return new Page<PublicMarketingSpaceVO>(query.getPageNum(), query.getPageSize()).setRecords(List.of());
        }
        source = spaceMapper.selectPage(source, publicSpaceQuery(query));
        enrichSpaceLocations(source.getRecords());
        Page<PublicMarketingSpaceVO> result = new Page<>(source.getCurrent(), source.getSize(), source.getTotal());
        result.setRecords(source.getRecords().stream().map(this::toPublicSpace).toList());
        return result;
    }

    @Override
    public PublicMarketingSpaceVO getPublicSpace(Long id) {
        if (TenantContextHolder.getTenantId() == null) {
            throw new BusinessException("房源不存在");
        }
        MarketingSpace space = spaceMapper.selectOne(publicSpaceQuery(new MarketingSpacePageQuery())
                .eq(MarketingSpace::getId, id));
        if (space == null) {
            throw new BusinessException("房源不存在");
        }
        enrichSpaceLocations(List.of(space));
        return toPublicSpace(space);
    }

    @Override
    public MarketingOverviewVO getOverview() {
        MarketingOverviewVO overview = new MarketingOverviewVO();
        overview.setLeadTotal(leadMapper.selectCount(new LambdaQueryWrapper<MarketingLead>()).intValue());
        overview.setNewLeadCount(countLeadsByStage("NEW"));
        overview.setVisitCount(countLeadsByStage("VISITED"));
        overview.setIntentionCount(countLeadsByStage("INTENTION"));
        overview.setConvertedCount(countLeadsByStage("CONVERTED"));
        // Follow-up rows have no completion flag, so count scheduled dates that have not arrived yet.
        overview.setPendingFollowUpCount(followUpMapper.selectCount(new LambdaQueryWrapper<MarketingFollowUp>()
                .isNotNull(MarketingFollowUp::getNextFollowAt)
                .ge(MarketingFollowUp::getNextFollowAt, LocalDateTime.now())).intValue());

        Map<Long, MarketingChannel> channels = channelMapper.selectList(new LambdaQueryWrapper<MarketingChannel>())
                .stream().collect(Collectors.toMap(MarketingChannel::getId, Function.identity()));
        List<MarketingChannelConversionVO> conversions = leadMapper.getChannelConversions();
        conversions.forEach(item -> {
            MarketingChannel channel = channels.get(item.getChannelId());
            item.setChannelName(channel != null ? channel.getName() : "");
        });
        overview.setChannelConversion(conversions);
        return overview;
    }

    private LambdaQueryWrapper<MarketingSpace> publicSpaceQuery(MarketingSpacePageQuery query) {
        return new LambdaQueryWrapper<MarketingSpace>()
                .eq(MarketingSpace::getPublishStatus, 1)
                .eq(MarketingSpace::getAvailability, "AVAILABLE")
                .and(StrUtil.isNotBlank(query.getKeyword()), w -> w
                        .like(MarketingSpace::getProjectName, query.getKeyword())
                        .or().like(MarketingSpace::getBuildingName, query.getKeyword())
                        .or().like(MarketingSpace::getFloorName, query.getKeyword())
                        .or().like(MarketingSpace::getRoomNo, query.getKeyword())
                        .or().like(MarketingSpace::getDisplayTitle, query.getKeyword()))
                .like(StrUtil.isNotBlank(query.getProjectName()), MarketingSpace::getProjectName, query.getProjectName())
                .orderByDesc(MarketingSpace::getUpdateTime);
    }

    private PublicMarketingSpaceVO toPublicSpace(MarketingSpace space) {
        PublicMarketingSpaceVO result = new PublicMarketingSpaceVO();
        result.setId(space.getId());
        result.setProjectName(space.getProjectName());
        result.setParkId(space.getParkId());
        result.setRegionId(space.getRegionId());
        result.setBuildingId(space.getBuildingId());
        result.setFloorId(space.getFloorId());
        result.setParkName(space.getParkName());
        result.setRegionName(space.getRegionName());
        result.setBuildingName(space.getBuildingName());
        result.setFloorName(space.getFloorName());
        result.setRoomNo(space.getRoomNo());
        result.setArea(space.getArea());
        result.setRentUnitPrice(space.getRentUnitPrice());
        result.setAvailability(space.getAvailability());
        result.setDisplayTitle(space.getDisplayTitle());
        result.setDescription(space.getDescription());
        result.setCoverUrl(space.getCoverUrl());
        result.setVrUrl(space.getVrUrl());
        return result;
    }

    private void validateSpaceLocation(MarketingSpaceForm form) {
        boolean hasAnyLocation = form.getParkId() != null || form.getRegionId() != null
                || form.getBuildingId() != null || form.getFloorId() != null;
        if (!hasAnyLocation) return;
        if (form.getParkId() == null || form.getRegionId() == null || form.getBuildingId() == null || form.getFloorId() == null) {
            throw new BusinessException("请选择完整的园区、区域、楼栋和楼层");
        }
        AssetPark park = assetParkMapper.selectById(form.getParkId());
        AssetRegion region = assetRegionMapper.selectById(form.getRegionId());
        AssetBuilding building = assetBuildingMapper.selectById(form.getBuildingId());
        AssetFloor floor = assetFloorMapper.selectById(form.getFloorId());
        if (park == null || region == null || building == null || floor == null
                || !Objects.equals(region.getParkId(), park.getId())
                || !Objects.equals(building.getParkId(), park.getId())
                || !Objects.equals(building.getRegionId(), region.getId())
                || !Objects.equals(floor.getBuildingId(), building.getId())) {
            throw new BusinessException("房源的园区、区域、楼栋或楼层关系不匹配");
        }
        form.setBuildingName(building.getName());
        form.setFloorName(floor.getFloorName());
    }

    private void enrichSpaceLocations(List<MarketingSpace> spaces) {
        List<MarketingSpace> linked = spaces.stream().filter(space -> space.getParkId() != null).toList();
        if (linked.isEmpty()) return;
        Set<Long> parkIds = linked.stream().map(MarketingSpace::getParkId).collect(Collectors.toSet());
        Set<Long> regionIds = linked.stream().map(MarketingSpace::getRegionId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, String> parks = assetParkMapper.selectBatchIds(parkIds).stream()
                .collect(Collectors.toMap(AssetPark::getId, AssetPark::getName));
        Map<Long, String> regions = regionIds.isEmpty() ? Map.of() : assetRegionMapper.selectBatchIds(regionIds).stream()
                .collect(Collectors.toMap(AssetRegion::getId, AssetRegion::getName));
        linked.forEach(space -> {
            space.setParkName(parks.get(space.getParkId()));
            space.setRegionName(regions.get(space.getRegionId()));
        });
    }

    private int countLeadsByStage(String stage) {
        return leadMapper.selectCount(new LambdaQueryWrapper<MarketingLead>().eq(MarketingLead::getStage, stage)).intValue();
    }

    private MarketingFollowUp getFollowUp(Long leadId, Long followUpId) {
        MarketingFollowUp followUp = followUpMapper.selectOne(new LambdaQueryWrapper<MarketingFollowUp>()
                .eq(MarketingFollowUp::getId, followUpId)
                .eq(MarketingFollowUp::getLeadId, leadId));
        if (followUp == null) {
            throw new BusinessException("跟进记录不存在");
        }
        return followUp;
    }

    private void validateLeadReferences(Long channelId, Long spaceId, Long assigneeId) {
        if (channelId != null) {
            MarketingChannel channel = channelMapper.selectById(channelId);
            if (channel == null || !Integer.valueOf(1).equals(channel.getStatus())) {
                throw new BusinessException("渠道不存在或已停用");
            }
        }
        if (spaceId != null && spaceMapper.selectById(spaceId) == null) {
            throw new BusinessException("房源不存在");
        }
        validateAssignee(assigneeId);
    }

    private void enrichLeadNames(List<MarketingLead> leads) {
        if (leads.isEmpty()) {
            return;
        }
        List<Long> channelIds = leads.stream()
                .map(MarketingLead::getChannelId)
                .filter(id -> id != null)
                .distinct()
                .toList();
        List<Long> assigneeIds = leads.stream()
                .map(MarketingLead::getAssigneeId)
                .filter(id -> id != null)
                .distinct()
                .toList();

        Map<Long, String> channelNames = channelIds.isEmpty()
                ? Map.of()
                : channelMapper.selectList(new LambdaQueryWrapper<MarketingChannel>()
                                .in(MarketingChannel::getId, channelIds)
                                .select(MarketingChannel::getId, MarketingChannel::getName))
                        .stream().collect(Collectors.toMap(MarketingChannel::getId, MarketingChannel::getName));
        Map<Long, String> assigneeNames = assigneeIds.isEmpty()
                ? Map.of()
                : userMapper.selectList(new LambdaQueryWrapper<User>()
                                .in(User::getId, assigneeIds)
                                .eq(User::getIsDeleted, 0)
                                .select(User::getId, User::getNickname, User::getUsername))
                        .stream().collect(Collectors.toMap(User::getId,
                                user -> StrUtil.blankToDefault(user.getNickname(), user.getUsername())));

        leads.forEach(lead -> {
            lead.setChannelName(lead.getChannelId() == null ? null : channelNames.get(lead.getChannelId()));
            lead.setAssigneeName(lead.getAssigneeId() == null ? null : assigneeNames.get(lead.getAssigneeId()));
        });
    }

    private void validateAssignee(Long assigneeId) {
        if (assigneeId == null) {
            return;
        }
        Long count = userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getId, assigneeId)
                .eq(User::getStatus, 1)
                .eq(User::getIsDeleted, 0));
        if (count == 0) {
            throw new BusinessException("负责人不存在或已停用");
        }
    }

    private void ensureChannelCodeAvailable(String code, Long excludedId) {
        LambdaQueryWrapper<MarketingChannel> query = new LambdaQueryWrapper<MarketingChannel>()
                .eq(MarketingChannel::getCode, code);
        query.ne(excludedId != null, MarketingChannel::getId, excludedId);
        if (channelMapper.selectCount(query) > 0) {
            throw new BusinessException("渠道编码已存在");
        }
    }

    private void ensureSpaceCodeAvailable(String code, Long excludedId) {
        LambdaQueryWrapper<MarketingSpace> query = new LambdaQueryWrapper<MarketingSpace>()
                .eq(MarketingSpace::getSpaceCode, code);
        query.ne(excludedId != null, MarketingSpace::getId, excludedId);
        if (spaceMapper.selectCount(query) > 0) {
            throw new BusinessException("房源编号已存在");
        }
    }

    private List<Long> parseIds(String ids) {
        if (StrUtil.isBlank(ids)) {
            throw new BusinessException("请传入有效ID");
        }
        try {
            List<Long> result = Arrays.stream(ids.split(","))
                    .map(String::trim)
                    .filter(StrUtil::isNotBlank)
                    .map(Long::valueOf)
                    .distinct()
                    .toList();
            if (result.isEmpty()) {
                throw new BusinessException("请传入有效ID");
            }
            return result;
        } catch (NumberFormatException exception) {
            throw new BusinessException("ID格式无效", exception);
        }
    }
}
