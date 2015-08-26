//
//  JTSScrollIndicatorConfig.h
//
//  Created by TAE JUN KIM (korean.darren@gmail.com) on 2015. 8. 26..
//

#import <UIKit/UIKit.h>

@class JTSScrollIndicator;

@interface JTSScrollIndicatorConfig : NSObject

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat minHeightWhenCompressed;
@property (assign, nonatomic) CGFloat minHeightWhenScrolling;
@property (assign, nonatomic) CGFloat rightMargin;
@property (assign, nonatomic) UIEdgeInsets inherentInsets;

@property (weak, nonatomic) JTSScrollIndicator *indicator;

+ (JTSScrollIndicatorConfig *)sharedConfig;

- (instancetype)init;

@end
