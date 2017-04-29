//
//  SWCarouselView.h
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWCarouselView;

@protocol SWCarouselViewDelegate <NSObject>

@required

- (NSUInteger)sw_numberOfItemsCarouselView:(SWCarouselView *)carouselView;

- (void)sw_carouselView:(SWCarouselView *)carouselView imageView:(UIImageView *)imageView forIndex:(NSInteger)index;

@optional

- (void)sw_carouselView:(SWCarouselView *)carouselView didSelectedIndex:(NSInteger)index;

- (void)sw_carouselView:(SWCarouselView *)carouselView didScrollToIndex:(NSInteger)index;

- (void)sw_carouselView:(SWCarouselView *)carouselView scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)sw_carouselView:(SWCarouselView *)carouselView scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface SWCarouselView : UIView

@property (nonatomic,weak) id<SWCarouselViewDelegate> delegate;
/** 定时轮播的时间间隔,默认是5秒*/
@property (nonatomic) NSTimeInterval scrollInterval;
/** 禁止定时轮播,默认是NO*/
@property (nonatomic) BOOL disableIntervalScroll;
/** 是否允许无限轮播,默认是YES*/
@property (nonatomic) BOOL enableInfiniteScroll;

/**
 当只有一条数据的时候,禁止滑动.默认是NO
 */
@property (nonatomic) BOOL disableScrollForSingle;
/** 开启定时轮播,默认已经是开启的*/
- (void)startIntervelScroll;
/** 停止定时轮播*/
- (void)stopIntervelScroll;

/**
 刷新数据
 */
- (void)reload;


@end
