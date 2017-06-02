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
    UIImageView *_backgroundImageView;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,weak) UIPanGestureRecognizer *panGesture;
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
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundImageView];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = YES;
    self.scrollView = _collectionView;
    self.panGesture = _collectionView.panGestureRecognizer;
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
    [self scrollToIndex:self.initialIndex animated:NO];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = _backgroundImage;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_delegate && [_delegate respondsToSelector:@selector(sw_numberOfItemsCarouselView:)]){
        _numberOfItems = [_delegate sw_numberOfItemsCarouselView:self];
        if(_numberOfItems && !_disableIntervalScroll){
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }else{
            [self stopIntervelScroll];
        }
        _collectionView.scrollEnabled = !(_numberOfItems == 1 && _disableScrollForSingle);
        if(self.disableUserScroll){
            _collectionView.scrollEnabled = NO;
        }
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
    if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didScrollToIndex:)]){
        if(_numberOfItems>0){
            NSIndexPath *indexPath = [_collectionView indexPathsForVisibleItems].lastObject;
            NSInteger index = _enableInfiniteScroll?indexPath.item%_numberOfItems:indexPath.item;
            [_delegate sw_carouselView:self didScrollToIndex:index];
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
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didScrollToIndex:)]){
                    [_delegate sw_carouselView:self didScrollToIndex:transferIndex];
            }
        }
    }else{
        if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didScrollToIndex:)]){
            NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
            [_delegate sw_carouselView:self didScrollToIndex:index];
        }
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

- (void)setDisableUserScroll:(BOOL)disableUserScroll {
    _disableUserScroll = disableUserScroll;
    _collectionView.scrollEnabled = !_disableUserScroll;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    _collectionView.bounces = bounces;
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    if(_enableInfiniteScroll){
        if(_numberOfItems>0 && index >= 0 && index < _numberOfItems){
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index+_numberOfItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didScrollToIndex:)]){
                [_delegate sw_carouselView:self didScrollToIndex:index];
            }
        }
    }else{
        if(_numberOfItems>0 && index >= 0 && index < _numberOfItems){
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
            if(_delegate && [_delegate respondsToSelector:@selector(sw_carouselView:didScrollToIndex:)]){
                NSInteger index = _collectionView.contentOffset.x/_collectionView.bounds.size.width;
                [_delegate sw_carouselView:self didScrollToIndex:index];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:_observer2];
}







@end
