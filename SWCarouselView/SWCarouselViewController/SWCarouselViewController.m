//
//  SWCarouselView.m
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "SWCarouselViewController.h"
#import <SWExtension/NSTimer+SWUnRetainTimer.h>

@interface SWCarouselCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation SWCarouselCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

@end

static NSString *const Cell = @"cell";

@interface SWCarouselViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
    NSUInteger _numberOfItems;
    UIImageView *_backgroundImageView;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,weak) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,weak) id observer1;
@property (nonatomic,weak) id observer2;
@property (nonatomic) BOOL isInitialIndexScrolled;


@end

@implementation SWCarouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_backgroundImageView];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flow];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = YES;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView = _collectionView;
    self.panGesture = _collectionView.panGestureRecognizer;
    [_collectionView registerClass:[SWCarouselCollectionViewCell class] forCellWithReuseIdentifier:Cell];
    [self.view addSubview:_collectionView];
    _pageControl = [[UIPageControl alloc] init];
    [self.view addSubview:_pageControl];
    __weak typeof(self) weakSelf = self;
    _observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf stopIntervelScroll];
    }];
    _observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf startIntervelScroll];
    }];
    _enableInfiniteScroll = YES;
    _disableIntervalScrollForSinglePage = YES;
    _scrollInterval = 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addTimerToRunLoop];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeTimerFromRunLoop];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    if(!CGSizeEqualToSize(flow.itemSize, self.view.bounds.size)){
        flow.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    }
    _pageControl.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height - 20);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = _backgroundImage;
}

- (BOOL)addTimerToRunLoop {
    if((_numberOfItems > 1 && !_disableIntervalScroll) || (_numberOfItems == 1 && !_disableIntervalScrollForSinglePage && !_disableIntervalScroll)){
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        return YES;
    }
    return NO;
}

- (void)removeTimerFromRunLoop {
    [_timer invalidate];
    _timer = nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_numberOfItemsInCarouselViewController:)]){
        _numberOfItems = [_delegate sw_numberOfItemsInCarouselViewController:self];
        _pageControl.numberOfPages = _numberOfItems;
        if(![self addTimerToRunLoop]){
            [self removeTimerFromRunLoop];
        }
        _collectionView.scrollEnabled = !(_numberOfItems == 1 && _disableIntervalScrollForSinglePage);
        if(self.disableUserScroll){
            _collectionView.scrollEnabled = NO;
        }
        if(_enableInfiniteScroll){
            return _numberOfItems*3;
        }else{
            return _numberOfItems;
        }
    }
    _pageControl.numberOfPages = 0;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SWCarouselCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Cell forIndexPath:indexPath];
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:imageView:forIndex:)]){
        NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
        [_delegate sw_carouselViewController:self imageView:cell.imageView forIndex:index];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didSelectedIndex:)]){
        NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
        [_delegate sw_carouselViewController:self didSelectedIndex:index];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.item == 0){
        if(self.isInitialIndexScrolled) return;
        self.isInitialIndexScrolled = YES;
        if(self.initialIndex <= 0) return;
        [self scrollToIndex:self.initialIndex animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reset];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self reset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopIntervelScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self reset];
    }
    [self startIntervelScroll];
}

- (void)calculateIndex {
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didScrollToIndex:)]){
        if(_numberOfItems>0){
            NSIndexPath *indexPath = [_collectionView indexPathsForVisibleItems].lastObject;
            NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
            [_delegate sw_carouselViewController:self didScrollToIndex:index];
        }
    }

}

- (void)reset
{
    if(_enableInfiniteScroll){
        if(_numberOfItems>0){
            NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
            NSInteger transferIndex = index%_numberOfItems;
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:transferIndex+_numberOfItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didScrollToIndex:)]){
                [_delegate sw_carouselViewController:self didScrollToIndex:transferIndex];
            }
            _pageControl.currentPage = transferIndex;
        }
    }else{
        NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
        if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didScrollToIndex:)]){
            [_delegate sw_carouselViewController:self didScrollToIndex:index];
        }
        _pageControl.currentPage = index;
    }
}


- (NSTimer *)timer
{
    if(!_timer){
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer sw_timerWithTimeInterval:_scrollInterval block:^(NSTimer *timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf onTimer];
        } repeats:YES];
    }
    return _timer;
}

- (void)onTimer
{
    NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
    if(_enableInfiniteScroll){
        index ++;
    }else{
        if(index == _numberOfItems - 1){
            index = 0;
        }else{
            index ++;
        }
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)stopIntervelScroll
{
    if(_disableIntervalScroll) return;
    if(_timer.isValid){
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)startIntervelScroll
{
    if(_disableIntervalScroll) return;
    if(_numberOfItems < 1) return;
    if(_numberOfItems < 2 && _disableIntervalScrollForSinglePage) return;
    if(_timer.isValid){
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }
}

- (void)reload
{
    [_collectionView reloadData];
    _pageControl.currentPage = 0;
}

- (void)setDisableIntervalScroll:(BOOL)disableIntervalScroll
{
    _disableIntervalScroll = disableIntervalScroll;
    if(_disableIntervalScroll){
        [self removeTimerFromRunLoop];
    }else{
        [self addTimerToRunLoop];
    }
}

- (void)setEnableInfiniteScroll:(BOOL)enableInfiniteScroll
{
    _enableInfiniteScroll = enableInfiniteScroll;
    [self reload];
}

- (void)setDisableUserScroll:(BOOL)disableUserScroll {
    _disableUserScroll = disableUserScroll;
    _collectionView.scrollEnabled = !_disableUserScroll;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    _collectionView.bounces = bounces;
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    _pageControl.currentPage = index;
    if(_enableInfiniteScroll){
        if(_numberOfItems>0 && index >= 0 && index < _numberOfItems){
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index+_numberOfItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didScrollToIndex:)]){
                [_delegate sw_carouselViewController:self didScrollToIndex:index];
            }
        }
    }else{
        if(_numberOfItems>0 && index >= 0 && index < _numberOfItems){
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselViewController:didScrollToIndex:)]){
                NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
                [_delegate sw_carouselViewController:self didScrollToIndex:index];
            }
        }
    }
}

- (void)dealloc
{
    //bug fix:[SWCarouselView respondsToSelector:]: message sent to deallocated instance
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    [self removeTimerFromRunLoop];
    [[NSNotificationCenter defaultCenter] removeObserver:_observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:_observer2];
    NSLog(@"%s",__func__);
}







@end
