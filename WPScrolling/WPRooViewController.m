//
//  WPRooViewController.m
//  WPScrolling
//
//  Created by Mykola Denysyuk on 7/1/14.
//  Copyright (c) 2014 Mykola Denysyuk. All rights reserved.
//

#import "WPRooViewController.h"
#import "WPScrollingView.h"

@interface WPRooViewController () <WPScrollingViewDatasource, WPScrollingViewDelegate>

@property (nonatomic, strong) WPScrollingView * scrollingView;
@property (nonatomic, strong) NSArray * titles;
@property (nonatomic, strong) NSArray * images;

@end

@implementation WPRooViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.scrollingView = [WPScrollingView new];
        self.scrollingView.topView.backgroundColor = [UIColor lightGrayColor];
        self.scrollingView.titlesScrollView.backgroundColor = [UIColor blackColor];
        
        self.titles = @[@"a cat", @"also a cat", @"not a cat", @"smile cat", @"cat's visa", @"domestic cat"];
        self.images = @[@"cat1.jpg", @"cat2.jpg",@"notacat3.jpg", @"cat4.jpg", @"cat5.jpg", @"cat6.jpg"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.scrollingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollingView.delegate = self;
    self.scrollingView.datasource = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.scrollingView.delegate = nil;
    self.scrollingView.datasource = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.scrollingView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WPScrollingView:

- (NSUInteger)numberOfItemsInWPScrollingView:(WPScrollingView *)scrollingView
{
    return self.images.count;
}

- (UIView *)wpScrollingView:(WPScrollingView *)scrollingView itemViewAtIndex:(NSUInteger)index withReusedItemView:(UIView *)view
{
    if (view == nil) {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.images[index]]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        view = imageView;
    }
    else
    {
        UIImageView * imageView = (UIImageView*)view;
        imageView.image = [UIImage imageNamed:self.images[index]];
    }
    return view;
}

- (NSString *)wpScrollingView:(WPScrollingView *)scrollingView titleForItemAtIndex:(NSUInteger)index
{
    return self.titles[index];
}

- (void)wpScrollingView:(WPScrollingView *)scrollingView didChangeScrollProgress:(CGFloat)scrollProgress
{
    NSLog(@"%f", scrollProgress);
}

@end
