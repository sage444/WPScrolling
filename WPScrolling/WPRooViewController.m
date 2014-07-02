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
        self.scrollingView.topScrollView.backgroundColor = [UIColor lightGrayColor];
        self.scrollingView.titlesScrollView.backgroundColor = [UIColor blackColor];
        
        self.titles = @[@"a cat", @"also a cat", @"not a cat"];
        self.images = @[[UIImage imageNamed:@"cat1.jpg"], [UIImage imageNamed:@"cat2.jpg"], [UIImage imageNamed:@"notacat3.jpg"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.scrollingView];
    self.scrollingView.delegate = self;
    self.scrollingView.datasource = self;
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
        UIImageView * imageView = [[UIImageView alloc] initWithImage:self.images[index]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        view = imageView;
    }
    else
    {
        UIImageView * imageView = (UIImageView*)view;
        imageView.image = self.images[index];
    }
    return view;
}

- (NSString *)wpScrollingView:(WPScrollingView *)scrollingView titleForItemAtIndex:(NSUInteger)index
{
    return self.titles[index];
}

@end
