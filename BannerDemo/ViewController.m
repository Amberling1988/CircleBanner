//
//  ViewController.m
//  BannerDemo
//
//  Created by mengll on 2016/11/21.
//  Copyright © 2016年 tinaya. All rights reserved.
//

#import "ViewController.h"

#define kScreenWidth self.view.bounds.size.width

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *originImages;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ViewController
/*
 * 懒加载，适合少量图片
 * 逻辑：
 * 1，originImages数组首尾insert最后一张图片和第一张图片，生成新数组lastImages；
 * 2，当轮播到lastImages数组最后一张图片时，scorllview自动调整显示当前contentOffset为第二张图片的位置
 * 3，注意 pagecontrol 的 currentpage
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *originMArr = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i+1]];
        [originMArr addObject:image];
    }
    self.originImages = [NSMutableArray arrayWithArray:originMArr];
    self.images =[NSMutableArray arrayWithArray:self.originImages];
    //设置scrollView
    [self setupScrollView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setter
- (void)setImages:(NSMutableArray *)images {
    _images = images;
    
    [_images insertObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",7]] atIndex:0];
    [_images insertObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",1]] atIndex:_images.count];
    
}

#pragma mark - 初始化scrollView

- (void)setupScrollView {

    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    }
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(kScreenWidth*self.images.count, 200);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width, 0);
    
    NSLog(@"self.images = %@",self.images);
    for (int i = 0; i < self.images.count; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, 200)];
        UIImage *image = self.images[i];
        imageView.image = image;
        [_scrollView addSubview:imageView];
    }
    
    [self.view addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 160, 100, 40)];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.numberOfPages = self.originImages.count;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.center = CGPointMake(kScreenWidth*0.5, 180);
    [self.view addSubview:_pageControl];

    [self startTimer];
}

- (void)nextImage {
    int nextPage = (int)_pageControl.currentPage+2;//0123456
    
    if (nextPage == self.originImages.count) {
        nextPage = 0;
    }
    
    [_scrollView setContentOffset:CGPointMake(nextPage*_scrollView.bounds.size.width, 0) animated:YES];
    
}

#pragma mark - set timer

- (void)startTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
     [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.timer = timer;
}
- (void)stoptimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (int)(scrollView.contentOffset.x/scrollView.bounds.size.width +0.5);//四舍五入
    
    if (page == self.images.count -1) {
        
        [_scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width, 0) animated:NO];
        _pageControl.currentPage = 0;
    }else if(page == 0){
        [_scrollView setContentOffset:CGPointMake((self.images.count-2)*scrollView.bounds.size.width, 0) animated:NO];
        _pageControl.currentPage = self.originImages.count-1;
    }else{
        _pageControl.currentPage = page -1;
    }

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
   
    [self startTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stoptimer];
}

@end
