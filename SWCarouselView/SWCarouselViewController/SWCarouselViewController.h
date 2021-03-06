//
//  SWCarouselView.h
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWCarouselViewController;

@protocol SWCarouselViewDelegate <NSObject>

@required

- (NSUInteger)sw_numberOfItemsInCarouselViewController:(SWCarouselViewController *)carouselViewController;

- (void)sw_carouselViewController:(SWCarouselViewController *)carouselViewController imageView:(UIImageView *)imageView forIndex:(NSInteger)index;

@optional

/**
 点击了某个索引
 */
- (void)sw_carouselViewController:(SWCarouselViewController *)carouselViewController didSelectedIndex:(NSInteger)index;

/**
 当前滑动到哪个索引
 */
- (void)sw_carouselViewController:(SWCarouselViewController *)carouselViewController didScrollToIndex:(NSInteger)index;

@end

@interface SWCarouselViewController : UIViewController

@property (nonatomic,readonly,strong) UIScrollView *scrollView;

@property (nonatomic,readonly,strong) UIPageControl *pageControl;

@property (nonatomic,weak) id<SWCarouselViewDelegate> delegate;
/**
 背景图片
 */
@property (nonatomic,strong) UIImage *backgroundImage;

/** 定时轮播的时间间隔,默认是5秒*/
@property (nonatomic) NSTimeInterval scrollInterval;
/** 禁止定时轮播,默认是NO*/
@property (nonatomic) BOOL disableIntervalScroll;

/**
 当只有一张图片的时候是否禁止定时轮播,默认是YES
 */
@property (nonatomic) BOOL disableIntervalScrollForSinglePage;
/**
 初始化的index，默认是0
 */
@property (nonatomic) NSInteger initialIndex;

/**
 禁止用户手动滑动,默认NO
 */
@property (nonatomic) BOOL disableUserScroll;

/**
 是否允许无限轮播,默认是YES
 */
@property (nonatomic) BOOL enableInfiniteScroll;

/**
 是否允许弹簧效果,默认YES
 */
@property (nonatomic) BOOL bounces;

/**
 滑动手势
 */
@property (nonatomic,readonly,weak) UIPanGestureRecognizer *panGesture;

/** 开启定时轮播,默认已经是开启的*/
- (void)startIntervelScroll;
/** 停止定时轮播*/
- (void)stopIntervelScroll;

/**
 滑动到某个索引

 @param index 索引
 @param animated 是否做动画
 */
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

/**
 刷新数据
 */
- (void)reload;


@end
