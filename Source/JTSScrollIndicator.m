//
//  JTSScrollIndicator.m
//
//
//  Created by Jared Sinclair on 11/11/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "JTSScrollIndicator.h"
#import "JTSScrollIndicatorConfig.h"

@interface JTSScrollIndicator () <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL shouldHide;
@property (assign, nonatomic) BOOL isScrollingToTop;
@property (weak, nonatomic, readwrite) UIScrollView *scrollView;

@end

@implementation JTSScrollIndicator

#pragma mark - Public

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    CGRect startingFrame = CGRectZero;
    self = [super initWithFrame:startingFrame];
    if (self) {
        _scrollView = scrollView;
        _scrollView.showsVerticalScrollIndicator = NO;  // The default scroll indicator in the scroll view must to be hide to show JTSScrollIndicator.
        
        JTSScrollIndicatorConfig *config = [JTSScrollIndicatorConfig sharedConfig];
        
        self.layer.cornerRadius = config.width * 0.75;
        self.clipsToBounds = YES;
        self.alpha = 0;
        _shouldHide = YES;
        [scrollView addSubview:self];
        [self reset];
    }
    return self;
}

- (void)setKeepHidden:(BOOL)keepHidden {
    if (_keepHidden != keepHidden) {
        _keepHidden = keepHidden;
        if (_keepHidden) {
            [self setShouldHide:YES];
        }
    }
}

- (void)reset {
    if (self.scrollView) {
        [self setFrame:[self.class targetRectForScrollView:self.scrollView]];
        _isScrollingToTop = NO;
        _keepHidden = NO;
        _shouldHide = YES;
        [self hide:NO];
    }
}

#pragma mark - Math

+ (CGRect)targetRectForScrollView:(UIScrollView *)scrollView {
    CGRect underlyingRect = [self underlyingIndicatorRectForScrollView:scrollView];
    CGRect adjustedRect = [self adjustUnderlyingRect:underlyingRect forScrollView:scrollView];
    return adjustedRect;
}

+ (CGRect)underlyingIndicatorRectForScrollView:(UIScrollView *)scrollView {
    JTSScrollIndicatorConfig *config = [JTSScrollIndicatorConfig sharedConfig];
    
    CGRect underlyingRect = CGRectZero;
    CGFloat contentHeight = scrollView.contentSize.height;
    UIEdgeInsets indicatorInsets = scrollView.scrollIndicatorInsets;
    CGFloat frameHeight = scrollView.frame.size.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    CGFloat frameHeightWithoutScrollIndicatorInsets = (frameHeight - indicatorInsets.top - indicatorInsets.bottom - config.inherentInsets.top);
    
    underlyingRect.size.width = config.width;
    underlyingRect.origin.x = scrollView.frame.size.width - config.width - config.rightMargin;
    
    CGFloat ratio = (contentHeightWithInsets != 0) ? frameHeightWithoutScrollIndicatorInsets / contentHeightWithInsets : 1.0f;
    
    underlyingRect.size.height = frameHeight * ratio;
    underlyingRect.origin.y = contentOffset.y + ((contentOffset.y+contentInset.top) * ratio) + indicatorInsets.top;
    
    if (underlyingRect.size.height < config.minHeightWhenScrolling) {
        CGFloat contentHeightWithoutLastFrame = contentHeightWithInsets - frameHeight;
        CGFloat percentageScrolled = (contentOffset.y+contentInset.top) / contentHeightWithoutLastFrame;
        underlyingRect.origin.y -= (config.minHeightWhenScrolling - underlyingRect.size.height) * percentageScrolled;
        underlyingRect.size.height = config.minHeightWhenScrolling;
    }
    
    underlyingRect.size.height -= config.inherentInsets.top;
    underlyingRect.origin.y += config.inherentInsets.top;
    
    return underlyingRect;
}

+ (CGRect)adjustUnderlyingRect:(CGRect)underlyingRect forScrollView:(UIScrollView *)scrollView {
    JTSScrollIndicatorConfig *config = [JTSScrollIndicatorConfig sharedConfig];
    
    CGRect adjustedRect = underlyingRect;
    
    CGFloat contentHeight = scrollView.contentSize.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    UIEdgeInsets indicatorInset = scrollView.scrollIndicatorInsets;
    CGFloat frameHeight = scrollView.frame.size.height;
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    
    if (contentOffset.y < 0-contentInset.top
     || adjustedRect.origin.y < (0-contentInset.top + indicatorInset.top) + config.inherentInsets.top) {
        CGFloat heightAdjustment = fabsf(contentInset.top - fabsf(contentOffset.y));
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, config.minHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + indicatorInset.top + config.inherentInsets.top;
    }
    else if (contentOffset.y + frameHeight > contentHeight + contentInset.bottom
        || adjustedRect.origin.y + adjustedRect.size.height > contentOffset.y + frameHeight - indicatorInset.bottom - config.inherentInsets.bottom) {
        adjustedRect.origin.y = contentHeightWithInsets - underlyingRect.size.height - indicatorInset.bottom;
        CGFloat heightAdjustment = (contentOffset.y + frameHeight) - (contentHeight + contentInset.bottom);
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, config.minHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + frameHeight - adjustedRect.size.height - indicatorInset.bottom - config.inherentInsets.bottom;
    }
    
    adjustedRect.origin.x = underlyingRect.origin.x + indicatorInset.left;
    adjustedRect.origin.x = underlyingRect.origin.x - indicatorInset.right;
    
    return adjustedRect;
}

+ (BOOL)indicatorShouldBeVisibleForScrollView:(UIScrollView *)scrollView {
    
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat frameHeight = scrollView.frame.size.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    return (contentHeightWithInsets > frameHeight * 1.1 && contentHeight > 0);
}

#pragma mark - Scroll View Changes

#pragma mark - Required for Implementers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView == nil) {
        [self setScrollView:scrollView];
    }
    
    [self setFrame:[self.class targetRectForScrollView:scrollView]];
    
    if (self.isScrollingToTop == NO && self.keepHidden == NO) {
        if ([self.class indicatorShouldBeVisibleForScrollView:scrollView]) {
            [self setShouldHide:NO];
            if (scrollView.dragging == NO && scrollView.decelerating == NO) {
                // ScrollViewDidEndScrollingAnimation is not called sometimes, goddamn UIKit,
                // such as when dismissing a keyboard triggers an atypical programmatic scroll.
                __weak JTSScrollIndicator *weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [weakSelf setShouldHide:YES];
                });
            }
        } else {
            [self setShouldHide:YES];
        }
    }
    else if (self.isScrollingToTop) {
        [self setShouldHide:NO];
    }
    else {
        [self setShouldHide:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self setShouldHide:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setShouldHide:YES];
}

- (void)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
    [self setIsScrollingToTop:YES];
    //[self setShouldHide:YES];
    
    // ScrollViewDidScrollToTop: is not called sometimes, goddamn UIKit. :-/
    __weak JTSScrollIndicator *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf setIsScrollingToTop:NO];
        [weakSelf setShouldHide:YES];
    });
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self setIsScrollingToTop:NO];
    [self setShouldHide:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self setShouldHide:YES];
}

#pragma mark - Animations

- (void)setShouldHide:(BOOL)shouldHide {
    
    if (_shouldHide != shouldHide) {
        _shouldHide = shouldHide;
        if (_shouldHide == NO) {
            [self show:YES];
        } else {
            [self hide:YES];
        }
    }
}

- (void)show:(BOOL)animated {
    [self setAlpha:1];
}

- (void)hide:(BOOL)animated {
    __weak JTSScrollIndicator *weakSelf = self;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.33 delay:0 options:options animations:^{
        [weakSelf setAlpha:0];
    } completion:nil];
}

@end




