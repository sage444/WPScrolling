//
//  WPScrollingView.m
//  WPScrolling
//
//  Created by Mykola Denysyuk on 7/1/14.
//  Copyright (c) 2014 Mykola Denysyuk. All rights reserved.
//

@interface UIView (SizeAccessors)
- (CGFloat)width;
- (CGFloat)height;
@end
@implementation UIView (SizeAccessors)
- (CGFloat)width
{
    return self.frame.size.width;
}
- (CGFloat)height
{
    return self.frame.size.height;
}
@end

const NSTimeInterval kAnimationDuration = 0.25f;
const NSInteger kMinTitlesCount = 3;
const CGFloat kMarginBetweenTitles = 10.0f;

#import "WPScrollingView.h"

@interface WPScrollingView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint lastTouchPoint;
@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) NSInteger currentItemIndex;
@property (nonatomic) NSMutableArray * titleLabels;
@property (nonatomic) NSMutableDictionary * reusedViews;
@property (nonatomic) CGFloat totalTitlesWidth;
@property (nonatomic) UILabel * fakeLabelLeft;
@property (nonatomic) UILabel * fakeLabelRight;

@end

@implementation WPScrollingView

#pragma mark - Initialization:

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code:
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize
{
    self.userInteractionEnabled = YES;
    
    _widthBetweenTitles = kMarginBetweenTitles;
    
    _titlesScrollViewHeight = 30.0f;
    
    _titleFont = [UIFont fontWithName:@"Avenir-Light" size:34];
    _titleColor = [UIColor darkGrayColor];
    _selectedTitleColor = [UIColor whiteColor];
    
    _topView = [UIView new];
    _topView.userInteractionEnabled = NO;
    [self addSubview:self.topView];
    
    _titlesScrollView = [UIScrollView new];
    _titlesScrollView.userInteractionEnabled = NO;
    [self addSubview:self.titlesScrollView];
    
    _contentScrollView = [UIScrollView new];
    _contentScrollView.delegate = self;
    _contentScrollView.userInteractionEnabled = YES;
    _contentScrollView.scrollEnabled = NO;
    [self addSubview:self.contentScrollView];
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(swipeGestureAction:)];
    panGesture.delegate = self;
    [panGesture setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer * tapOnTitles = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(swipeGestureAction:)];
    [self addGestureRecognizer:tapOnTitles];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGRect bounds = self.bounds;
    
    self.topView.frame = CGRectMake(0, 0, bounds.size.width, self.topScrollViewHeight);
    
    [self layoutTitles];
    
    self.contentScrollView.frame = CGRectMake(0, self.titlesScrollView.frame.origin.y + self.titlesScrollView.height,
                                              bounds.size.width, bounds.size.height - self.titlesScrollView.frame.origin.y - self.titlesScrollView.height);
    
    for (UIView * subview in self.contentScrollView.subviews) {
        CGRect frame = subview.frame;
        frame.size = self.contentScrollView.frame.size;
        subview.frame = frame;
    }
    
}

- (void)layoutTitles
{
    const CGRect bounds = self.bounds;
    
    self.titlesScrollView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.height,
                                             bounds.size.width, self.titlesScrollViewHeight);
    [self.titleLabels makeObjectsPerformSelector:@selector(sizeToFit)];
    
    self.totalTitlesWidth = [[self.titleLabels valueForKeyPath:@"@sum.width"] floatValue];

    CGFloat titleContentWidth = self.totalTitlesWidth + self.titleLabels.count*self.widthBetweenTitles + self.widthBetweenTitles;
    self.titlesScrollView.contentSize = CGSizeMake(titleContentWidth, self.titlesScrollView.height);
    CGFloat itemX = self.widthBetweenTitles;
    NSInteger currentItem = self.currentItemIndex;

    for (int i = 0; i<self.titleLabels.count; i++) {
        UILabel * label = self.titleLabels[currentItem];
        CGRect lFrame = label.frame;
        lFrame.origin.x = itemX;
        lFrame.size.height = self.titlesScrollView.height;
        label.frame = lFrame;
        itemX += lFrame.size.width + self.widthBetweenTitles;
        currentItem++;
        if (currentItem >= self.titleLabels.count) {
            currentItem = 0;
        }
    }
}

#pragma mark - Setters, Accessors:

- (void)setDatasource:(id<WPScrollingViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)setDelegate:(id<WPScrollingViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    [self.titleLabels makeObjectsPerformSelector:@selector(setFont:) withObject:titleFont];
    [self setNeedsLayout];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.titleLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:titleColor];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
    _selectedTitleColor = selectedTitleColor;
    if (self.titleLabels.count>self.currentItemIndex) {
        UILabel * selectedLabel = [self.titleLabels objectAtIndex:self.currentItemIndex];
        selectedLabel.textColor = selectedTitleColor;
    }
}

- (void)setTopScrollViewHeight:(CGFloat)topScrollViewHeight
{
    _topScrollViewHeight = topScrollViewHeight;
    [self setNeedsLayout];
}

- (void)setTitlesScrollViewHeight:(CGFloat)titlesScrollViewHeight
{
    _titlesScrollViewHeight = titlesScrollViewHeight;
    [self setNeedsLayout];
}

- (void)setWidthBetweenTitles:(CGFloat)widthBetweenTitles
{
    _widthBetweenTitles = widthBetweenTitles;
    [self layoutTitles];
}

- (NSUInteger)currentSelectedIndex
{
    return self.currentItemIndex;
}

- (CGFloat)currentScrolledProgress
{
    CGFloat scrollProgress = (self.contentScrollView.frame.size.width * self.currentItemIndex + self.contentScrollView.contentOffset.x)/(self.contentScrollView.frame.size.width * self.numberOfItems);
    if (scrollProgress < 0) {
        scrollProgress = 1 + scrollProgress;
    }
    return scrollProgress;
}

#pragma mark - Gesture delegate:

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.numberOfItems > 1;
}

#pragma mark - Gesture recognizer action:

- (void)swipeGestureAction:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.lastTouchPoint = [recognizer locationInView:recognizer.view];
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentTouchPoint = [recognizer locationInView:recognizer.view];
            CGFloat scrollOffset = self.lastTouchPoint.x - currentTouchPoint.x;
            
            NSInteger nextCurrentIndex = NSNotFound;
            CGFloat nextViewOriginX = 0;
            
            [self determineByOffset:scrollOffset
                    nextCurrentItem:&nextCurrentIndex
                    nextViewOriginX:&nextViewOriginX];
            
            //
            // Shift 'content' to offset
            
            self.contentScrollView.contentOffset = CGPointMake(scrollOffset, 0);
            
            //
            // shift 'titles' to offset:
            
            UILabel * scrollToLabel = [self retrieveTitleLabelAtIndex:nextCurrentIndex];
            UILabel * currentTitleLabel = [self.titleLabels objectAtIndex:self.currentItemIndex];
            CGFloat labelWidth = currentTitleLabel.width;
            if (scrollOffset<0) {

                if (self.fakeLabelLeft == nil) {
                    self.fakeLabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(-(scrollToLabel.frame.size.width), 0,
                                                                                    scrollToLabel.width, scrollToLabel.height)];
                    [self.titlesScrollView addSubview:self.fakeLabelLeft];
                    
                    self.fakeLabelLeft.text = scrollToLabel.text;
                    self.fakeLabelLeft.font = scrollToLabel.font;
                    self.fakeLabelLeft.textColor = scrollToLabel.textColor;
                    self.fakeLabelLeft.backgroundColor = scrollToLabel.backgroundColor;
                }
                
                scrollToLabel = self.fakeLabelLeft;
                
                labelWidth = scrollToLabel.width;
            }
            
            CGFloat scrollProgress = scrollOffset / self.contentScrollView.frame.size.width;
            CGFloat titleOffset = (self.widthBetweenTitles + labelWidth) * scrollProgress;
            
            self.titlesScrollView.contentOffset = CGPointMake(titleOffset, 0);
            
            if (self.totalTitlesWidth - self.titlesScrollView.contentOffset.x < self.titlesScrollView.frame.size.width) {
                if (self.fakeLabelRight == nil) {
                    
                    UILabel * overLastLabel = [self retrieveTitleLabelAtIndex:(nextCurrentIndex + self.titleLabels.count-1)%self.titleLabels.count];
                    self.fakeLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(self.titlesScrollView.contentSize.width, overLastLabel.frame.origin.y,
                                                                                    overLastLabel.frame.size.width, overLastLabel.frame.size.height)];
                    self.fakeLabelRight.backgroundColor = overLastLabel.backgroundColor;
                    self.fakeLabelRight.textColor = self.titleColor;
                    self.fakeLabelRight.font = overLastLabel.font;
                    self.fakeLabelRight.text = overLastLabel.text;
                    [self.titlesScrollView addSubview:self.fakeLabelRight];
                }
            }
            
        }
            break;
        default:
        {
            CGPoint currentTouchLocation = [recognizer locationInView:recognizer.view];
            
            if (CGRectContainsPoint(self.titlesScrollView.frame, currentTouchLocation) && [recognizer isMemberOfClass:[UITapGestureRecognizer class]]) {
                
                //
                // Single tap on title label, require scroll to appropriate section:
                // TODO: implement transition to actual tapped title's section instead of just next item:
                if (currentTouchLocation.x > self.widthBetweenTitles+[self retrieveTitleLabelAtIndex:self.currentItemIndex].width) {
                    [self completeScrollByOffset:320.0f];
                }
            }
            else
            if (abs(self.contentScrollView.contentOffset.x) < self.contentScrollView.frame.size.width*0.25) {
                
                //
                // Scroll back to original state:
                
                [UIView animateWithDuration:kAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.contentScrollView.contentOffset = CGPointZero;
                                     self.titlesScrollView.contentOffset = CGPointZero;
                                 }
                                 completion:^(BOOL finished) {
                                     [self.fakeLabelLeft removeFromSuperview];
                                     [self.fakeLabelRight removeFromSuperview];
                                     self.fakeLabelLeft = nil;
                                     self.fakeLabelRight = nil;
                                 }];
            }
            else
            {
                
                //
                // Complete scroll transition to next view item:
                
                [self completeScrollByOffset:self.contentScrollView.contentOffset.x];
            }
        }
            break;
    }
}

#pragma mark - ScrollView delegate:

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger nextCurrentIndex = NSNotFound;
    CGFloat nextViewOriginX = 0;
    
    //
    // Continue shifting 'content' to offset:
    
    [self determineByOffset:scrollView.contentOffset.x
            nextCurrentItem:&nextCurrentIndex
            nextViewOriginX:&nextViewOriginX];
    
    [UIView setAnimationsEnabled:NO];
    UIView * scrollToView = [self retrieveViewAtIndex:nextCurrentIndex];
    scrollToView.frame = CGRectMake(nextViewOriginX, 0,
                                    self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    [UIView setAnimationsEnabled:YES];
    [self.contentScrollView addSubview:scrollToView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(wpScrollingView:didChangeScrollProgress:)]) {
        CGFloat scrollProgress = (scrollView.frame.size.width * self.currentItemIndex + scrollView.contentOffset.x)/(scrollView.frame.size.width * self.numberOfItems);
        if (scrollProgress < 0) {
            scrollProgress = 1 + scrollProgress;
        }
        [self.delegate wpScrollingView:self
               didChangeScrollProgress:scrollProgress];
    }
}

#pragma mark - Private: Common helpers:

- (void)reloadData
{
    self.numberOfItems = [self.datasource numberOfItemsInWPScrollingView:self];
    
    //
    // Prepare title labels:

    int minTitlesCount = self.numberOfItems;
    NSMutableArray * tmpTitlesList = [NSMutableArray arrayWithCapacity:minTitlesCount];
    for (int i = 0; i < minTitlesCount; i++) {
        UILabel * label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = (i == self.currentItemIndex) ? self.selectedTitleColor : self.titleColor;
        label.font = self.titleFont;
        label.text = [self.datasource wpScrollingView:self
                                  titleForItemAtIndex:i];
        [tmpTitlesList addObject:label];
        [self.titlesScrollView addSubview:label];
    }
    [self.titleLabels removeAllObjects];
    self.titleLabels = tmpTitlesList;
    [self layoutTitles];
    
    //
    // Prepare reusable views storage:
    
    [self.reusedViews removeAllObjects];
    self.reusedViews = [NSMutableDictionary dictionaryWithCapacity:self.numberOfItems];
    
    if (self.numberOfItems > 0) {
        UIView * viewItem = [self retrieveViewAtIndex:0];
        [self.contentScrollView addSubview:viewItem];
    }
    
    //
    //  and in the last order relayout views:
    
    [self setNeedsDisplay];
}

- (void)completeScrollByOffset:(CGFloat)offset
{
    NSInteger nextCurrentIndex = NSNotFound;
    CGFloat nextViewOriginX = 0;
    
    [self determineByOffset:offset
            nextCurrentItem:&nextCurrentIndex
            nextViewOriginX:&nextViewOriginX];
    
    UILabel * nextTitleLabel = self.fakeLabelLeft && (offset<0) ? self.fakeLabelLeft : [self retrieveTitleLabelAtIndex:nextCurrentIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(wpScrollingView:willScrollToItemAtIndex:)]) {
        [self.delegate wpScrollingView:self willScrollToItemAtIndex:nextCurrentIndex];
    }
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.contentScrollView.contentOffset = CGPointMake(nextViewOriginX, 0);
                         self.titlesScrollView.contentOffset = CGPointMake(nextTitleLabel.frame.origin.x-self.widthBetweenTitles, 0);
                     }
                     completion:^(BOOL finished) {
                         [self.fakeLabelLeft removeFromSuperview];
                         [self.fakeLabelRight removeFromSuperview];
                         self.fakeLabelLeft = nil;
                         self.fakeLabelRight = nil;
                         self.currentItemIndex = nextCurrentIndex;
                         [self scrollToCenter];
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(wpScrollingView:didScrollToItemAtIndex:)]) {
                             [self.delegate wpScrollingView:self didScrollToItemAtIndex:nextCurrentIndex];
                         }
                     }];
}

- (void)scrollToCenter
{
    //
    // 'titles'
    
    UILabel * currentLabel = [self.titleLabels objectAtIndex:self.currentItemIndex];
    [self.titleLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:self.titleColor];
    currentLabel.textColor = self.selectedTitleColor;
    [self layoutTitles];
    self.titlesScrollView.contentOffset = CGPointZero;
    
    //
    // 'content'
    
    [self.contentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView * currentViewItem = [self retrieveViewAtIndex:self.currentItemIndex];
    CGRect frame = self.contentScrollView.bounds;
    frame.origin = CGPointZero;
    currentViewItem.frame = frame;
    [self.contentScrollView addSubview:currentViewItem];
    [self.contentScrollView setContentOffset:CGPointZero];
}

- (void)determineByOffset:(CGFloat)contentOffset nextCurrentItem:(NSInteger*)nextItem nextViewOriginX:(CGFloat*)nextViewOriginX
{
    if (contentOffset > 0) {
        //
        // Scroll to left:
        
        *nextItem = [self righItemIndex];
        *nextViewOriginX = self.contentScrollView.frame.size.width;
    }
    else
    {
        //
        // Scroll to right:
        
        *nextItem = [self leftItemIndex];
        *nextViewOriginX = -self.contentScrollView.frame.size.width;
    }
}

- (NSUInteger)leftItemIndex
{
    const NSInteger leftIndex = self.currentItemIndex - 1;
    return (leftIndex >= 0) ? leftIndex : self.numberOfItems-1;
}

- (NSUInteger)righItemIndex
{
    const NSInteger rightIndex = self.currentItemIndex + 1;
    return (rightIndex < self.numberOfItems) ? rightIndex : 0;
}

- (UILabel *)retrieveTitleLabelAtIndex:(NSUInteger)index
{
    NSAssert(index < self.titleLabels.count, @"{INTERNAL ERROR} %s: retrieved title index couldn't be greater than label's count", __PRETTY_FUNCTION__);
    
    UILabel * labelAtIndex = self.titleLabels[index];
    labelAtIndex.text = [self.datasource wpScrollingView:self
                                     titleForItemAtIndex:index];
    return labelAtIndex;
}

- (UIView *)retrieveViewAtIndex:(NSUInteger)index
{
    UIView * viewItem = [self.datasource wpScrollingView:self
                                         itemViewAtIndex:index
                                      withReusedItemView:[self reusedViewAtIndex:index]];
    [self.reusedViews setObject:viewItem
                         forKey:[NSString stringWithFormat:@"%i", index]];
    return viewItem;
}

- (UIView *)reusedViewAtIndex:(NSUInteger)index
{
    return [self.reusedViews objectForKey:[NSString stringWithFormat:@"%i", index]];
}

@end
