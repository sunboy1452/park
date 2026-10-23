package com.youlai.boot.module.marketing.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
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
import com.youlai.boot.module.marketing.model.vo.MarketingOverviewVO;
import com.youlai.boot.module.marketing.model.vo.PublicMarketingSpaceVO;

public interface MarketingService {

    Page<MarketingChannel> getChannelPage(MarketingChannelPageQuery query);
    MarketingChannel getChannel(Long id);
    boolean saveChannel(MarketingChannelForm form);
    boolean updateChannel(Long id, MarketingChannelForm form);
    void deleteChannels(String ids);

    Page<MarketingLead> getLeadPage(MarketingLeadPageQuery query);
    MarketingLead getLead(Long id);
    MarketingLead getLeadDetail(Long id);
    boolean saveLead(MarketingLeadForm form);
    boolean updateLead(Long id, MarketingLeadForm form);
    void deleteLeads(String ids);
    boolean assignLead(Long id, MarketingLeadAssignForm form);

    Page<MarketingFollowUp> getFollowUpPage(Long leadId, MarketingFollowUpPageQuery query);
    MarketingFollowUp getFollowUpDetail(Long leadId, Long followUpId);
    boolean saveFollowUp(Long leadId, MarketingFollowUpForm form);
    boolean updateFollowUp(Long leadId, Long followUpId, MarketingFollowUpForm form);
    void deleteFollowUps(Long leadId, String ids);

    Page<MarketingSpace> getSpacePage(MarketingSpacePageQuery query);
    MarketingSpace getSpace(Long id);
    boolean saveSpace(MarketingSpaceForm form);
    boolean updateSpace(Long id, MarketingSpaceForm form);
    void deleteSpaces(String ids);
    Page<PublicMarketingSpaceVO> getPublicSpacePage(MarketingSpacePageQuery query);
    PublicMarketingSpaceVO getPublicSpace(Long id);

    MarketingOverviewVO getOverview();
}
