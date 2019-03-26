//
//  MSGuideMaskView.h
//  MSDragTableView
//
//  Created by ypl on 2018/10/15.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSGuideMaskView : UIView

@property (nonatomic, strong) void (^featureDidClosed)(void);

/**显示一次 */
- (instancetype)initWithFirstGuideKey:(NSString *)firstGuideKey;
/** 设置被覆盖视图 */
- (void)setMaskedView:(UIView *)maskedView;
/** 设置覆盖颜色 */
- (void)setMaskColor:(UIColor *)maskColor;
/** 设置透明度 */
- (void)setMaskAlpha:(CGFloat)maskAlpha;
/** 设置frame偏移 */
- (void)setEdgesInMaskedView:(UIEdgeInsets)edgeInsets;

/** 添加透明区域 */
- (void)addTransparentRect:(CGRect)TransparentRect;
- (void)addTransparentInView:(UIView *)view;

/** 在指定位置添加图片 */
- (void)addImage:(UIImage *)image inRect:(CGRect)rect;
/** 覆盖在view上，并居中显示 */
- (void)addImage:(UIImage *)image inview:(UIView *)view;
/** 在指定位置添加滑动手势图片 */
- (void)addAnimationImage:(UIImage *)image inRect:(CGRect)rect;
/** 开始动画 */
- (void)startAnimation;

/** 显示 */
- (void)show;
/** 清除所有指引图 */
+ (void)clearAllInMaskedView:(UIView *)maskedView;

@end
