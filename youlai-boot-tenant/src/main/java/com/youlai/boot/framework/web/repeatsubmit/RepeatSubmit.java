package com.youlai.boot.framework.web.repeatsubmit;


import java.lang.annotation.*;

/**
 * 防重复提交注解，默认拦截窗口 5 秒
 *
 * @author Ray.Hao
 * @since 2.3.0
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
public @interface RepeatSubmit {

    /**
     * 锁过期时间（秒）
     */
    int expire() default 5;

}
