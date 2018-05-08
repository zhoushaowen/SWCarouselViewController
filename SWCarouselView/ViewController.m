//
//  ViewController.m
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "ViewController.h"
#import "SWCarouselViewController.h"

@interface ViewController ()<SWCarouselViewDelegate>
{
    NSArray *_array;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SWCarouselViewController *carouselViewController = [[SWCarouselViewController alloc] init];
    carouselViewController.delegate = self;
    carouselViewController.scrollInterval = 2;
    carouselViewController.initialIndex = 1;
    [self addChildViewController:carouselViewController];
    carouselViewController.view.frame = CGRectMake(0, 20+64, self.view.bounds.size.width, 200);
    [self.view addSubview:carouselViewController.view];
    [carouselViewController didMoveToParentViewController:self];
    _array = @[@"1",@"2",@"3"];
//    _array = @[@"1"];
}

- (NSUInteger)sw_numberOfItemsInCarouselViewController:(SWCarouselViewController *)carouselViewController
{
    return _array.count;
}

- (void)sw_carouselViewController:(SWCarouselViewController *)carouselViewController imageView:(UIImageView *)imageView forIndex:(NSInteger)index
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[_array[index] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:@"png"] ofType:nil]];
    imageView.image = image;
}

- (void)sw_carouselViewController:(SWCarouselViewController *)carouselViewController didScrollToIndex:(NSInteger)index {
    NSLog(@"%zd",index);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}



@end
