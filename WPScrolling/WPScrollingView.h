//
//  WPScrollingView.h
//  WPScrolling
//
//  Created by Mykola Denysyuk on 7/1/14.
//  Copyright (c) 2014 Mykola Denysyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WPScrollingViewDatasource, WPScrollingViewDelegate;

//
// Scrolling view:

@interface WPScrollingView : UIView

@property (readonly, nonatomic, strong) UIView * topView;
@property (readonly, nonatomic, strong) UIScrollView * titlesScrollView;
@property (readonly, nonatomic, strong) UIScrollView * contentScrollView;

@property (nonatomic) CGFloat topScrollViewHeight;
@property (nonatomic) CGFloat titlesScrollViewHeight;
@property (nonatomic) CGFloat widthBetweenTitles;

@property (nonatomic, strong) UIFont * titleFont;
@property (nonatomic, strong) UIColor * titleColor;
@property (nonatomic, strong) UIColor * selectedTitleColor;

@property (readonly, nonatomic) NSUInteger currentSelectedIndex;
@property (readonly, nonatomic) CGFloat currentScrolledProgress;

@property (nonatomic, assign) id<WPScrollingViewDelegate> delegate;
@property (nonatomic, assign) id<WPScrollingViewDatasource> datasource;

- (void)reloadData;

@end

//
// Datasource & delegation protocols:

@protocol WPScrollingViewDatasource <NSObject>

@required
- (NSUInteger)numberOfItemsInWPScrollingView:(WPScrollingView *)scrollingView;

- (UIView *)wpScrollingView:(WPScrollingView *)scrollingView itemViewAtIndex:(NSUInteger)index withReusedItemView:(UIView *)view;

- (NSString *)wpScrollingView:(WPScrollingView *)scrollingView titleForItemAtIndex:(NSUInteger)index;

@end


@protocol WPScrollingViewDelegate <NSObject>

@optional
- (void)wpScrollingView:(WPScrollingView *)scrollingView willScrollToItemAtIndex:(NSUInteger)index;

- (void)wpScrollingView:(WPScrollingView *)scrollingView didScrollToItemAtIndex:(NSUInteger)index;

- (void)wpScrollingView:(WPScrollingView *)scrollingView didChangeScrollProgress:(CGFloat)scrollProgress;

@end