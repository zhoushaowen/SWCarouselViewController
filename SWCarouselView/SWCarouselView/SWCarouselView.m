//
//  SWCarouselView.m
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "SWCarouselView.h"

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

@interface SWCarouselView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
    NSUInteger _numberOfItems;
}

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,weak) id observer1;
@property (nonatomic,weak) id observer2;


@end

@implementation SWCarouselView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
    }
    return self;
}

- (void)setup
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    [_collectionView registerClass:[SWCarouselCollectionViewCell class] forCellWithReuseIdentifier:Cell];
    [self addSubview:_collectionView];
    _observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self stopIntervelScroll];
    }];
    _observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self startIntervelScroll];
    }];
    _enableInfiniteScroll = YES;
    _scrollInterval = 5;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    flow.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_numberOfItemsCarouselView:)]){
        _numberOfItems = [_delegate sw_numberOfItemsCarouselView:self];
        if(_numberOfItems && !_disableIntervalScroll){
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
        _collectionView.scrollEnabled = !(_numberOfItems == 1 && _disableScrollForSingle);
        self.disableIntervalScroll = !_collectionView.scrollEnabled;
        if(_enableInfiniteScroll){
            return _numberOfItems*3;
        }else{
            return _numberOfItems;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SWCarouselCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Cell forIndexPath:indexPath];
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:imageView:forIndex:)]){
        NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
        [_delegate sw_carouselView:self imageView:cell.imageView forIndex:index];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didSelectedIndex:)]){
        NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
        [_delegate sw_carouselView:self didSelectedIndex:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:scrollViewDidScroll:)]){
        [_delegate sw_carouselView:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reset];
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:scrollViewDidEndDecelerating:)]){
        [_delegate sw_carouselView:self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self reset];
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:scrollViewDidEndDecelerating:)]){
        [_delegate sw_carouselView:self scrollViewDidEndDecelerating:scrollView];
    }
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

- (void)reset
{
    if(_enableInfiniteScroll){
        NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
        NSInteger transferIndex = index%_numberOfItems;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:transferIndex+_numberOfItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}


- (NSTimer *)timer
{
    if(!_timer){
        _timer = [NSTimer timerWithTimeInterval:_scrollInterval target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
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
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)startIntervelScroll
{
    if(_disableIntervalScroll) return;
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

- (void)reload
{
    [_collectionView reloadData];
}

- (void)setDisableIntervalScroll:(BOOL)disableIntervalScroll
{
    _disableIntervalScroll = disableIntervalScroll;
    if(_disableIntervalScroll){
        [self.timer invalidate];
        self.timer = nil;
    }else{
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)setEnableInfiniteScroll:(BOOL)enableInfiniteScroll
{
    _enableInfiniteScroll = enableInfiniteScroll;
    [self reload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:_observer2];
}







@end
