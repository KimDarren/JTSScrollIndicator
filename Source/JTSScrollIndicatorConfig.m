//
//  JTSScrollIndicatorConfig.h
//
//  Created by TAE JUN KIM (korean.darren@gmail.com) on 2015. 8. 26..
//

#import "JTSScrollIndicatorConfig.h"
#import "JTSScrollIndicator.h"

static CGFloat JTSScrollIndicator_IndicatorWidth = 2.5f;
static CGFloat JTSScrollIndicator_MinIndicatorHeightWhenCompressed = 8.0f;
static CGFloat JTSScrollIndicator_MinIndicatorHeightWhenScrolling = 37.0f;
static CGFloat JTSScrollIndicator_IndicatorRightMargin = 2.5f;
static UIEdgeInsets JTSScrollIndicator_InherentInset;

@implementation JTSScrollIndicatorConfig

+ (JTSScrollIndicatorConfig *)sharedConfig
{
    static JTSScrollIndicatorConfig *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JTSScrollIndicatorConfig alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        JTSScrollIndicator_InherentInset = UIEdgeInsetsMake(2.5, 0, 2.5, 0);
        _width = JTSScrollIndicator_IndicatorWidth;
        _minHeightWhenCompressed = JTSScrollIndicator_MinIndicatorHeightWhenCompressed;
        _minHeightWhenScrolling = JTSScrollIndicator_MinIndicatorHeightWhenScrolling;
        _rightMargin = JTSScrollIndicator_IndicatorRightMargin;
        _inherentInsets = JTSScrollIndicator_InherentInset;
    }
    return self;
}

- (void)reloadScrollIndicatorFrame
{
    [_indicator setFrame:[JTSScrollIndicator targetRectForScrollView:_indicator.scrollView]];
}

#pragma mark - Setter

- (void)setWidth:(CGFloat)width
{
    _width = width;
    _indicator.layer.cornerRadius = _width * 0.75;
    [self reloadScrollIndicatorFrame];
}

- (void)setMinHeightWhenCompressed:(CGFloat)minHeightWhenCompressed
{
    _minHeightWhenCompressed = minHeightWhenCompressed;
    [self reloadScrollIndicatorFrame];
}

- (void)setMinHeightWhenScrolling:(CGFloat)minHeightWhenScrolling
{
    _minHeightWhenScrolling = minHeightWhenScrolling;
    [self reloadScrollIndicatorFrame];
}

- (void)setRightMargin:(CGFloat)rightMargin
{
    _rightMargin = rightMargin;
    [self reloadScrollIndicatorFrame];
}

- (void)setInherentInsets:(UIEdgeInsets)inherentInsets
{
    _inherentInsets = inherentInsets;
    [self reloadScrollIndicatorFrame];
}

@end
