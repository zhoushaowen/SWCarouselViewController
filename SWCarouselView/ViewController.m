//
//  ViewController.m
//  SWCarouselView
//
//  Created by zhoushaowen on 2017/3/6.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "ViewController.h"
#import "SWCarouselView.h"

@interface ViewController ()<SWCarouselViewDelegate>
{
    NSArray *_array;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SWCarouselView *carouselView = [[SWCarouselView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 200)];
    carouselView.delegate = self;
    [self.view addSubview:carouselView];
    _array = @[@"1",@"2",@"3"];
}

- (NSUInteger)sw_numberOfItemsCarouselView:(SWCarouselView *)carouselView
{
    return _array.count;
}

- (void)sw_carouselView:(SWCarouselView *)carouselView imageView:(UIImageView *)imageView forIndex:(NSInteger)index
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[_array[index] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:@"png"] ofType:nil]];
    imageView.image = image;
}



@end
