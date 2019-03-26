//
//  MSGuideMaskView.m
//  MSDragTableView
//
//  Created by ypl on 2018/10/15.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import "MSGuideMaskView.h"

CGMutablePathRef CGPathCreateRoundedRect(CGRect rect, CGFloat cornerRadius){
    CGMutablePathRef result = CGPathCreateMutable();
    CGPathMoveToPoint(result, nil, CGRectGetMinX(rect)+cornerRadius, (CGRectGetMinY(rect)) );
    CGPathAddArc(result, nil, (CGRectGetMinX(rect)+cornerRadius), (CGRectGetMinY(rect)+cornerRadius), cornerRadius, M_PI*1.5, M_PI*1.0, 1);//topLeft
    CGPathAddArc(result, nil, (CGRectGetMinX(rect)+cornerRadius), (CGRectGetMaxY(rect)-cornerRadius), cornerRadius, M_PI*1.0, M_PI*0.5, 1);//bottomLeft
    CGPathAddArc(result, nil, (CGRectGetMaxX(rect)-cornerRadius), (CGRectGetMaxY(rect)-cornerRadius), cornerRadius, M_PI*0.5, 0.0, 1);//bottomRight
    CGPathAddArc(result, nil, (CGRectGetMaxX(rect)-cornerRadius), (CGRectGetMinY(rect)+cornerRadius), cornerRadius, 0.0, M_PI*1.5, 1);//topRight
    CGPathCloseSubpath(result);
    
    return result;
}

#pragma mark - MSTransparentArea

@interface MSTransparentArea : NSObject
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGFloat radius;

+ (MSTransparentArea *)areaWithRect:(CGRect)rect radius:(CGFloat)radius;

@end

@implementation MSTransparentArea

+ (MSTransparentArea *)areaWithRect:(CGRect)rect radius:(CGFloat)radius {
    MSTransparentArea *area = [[MSTransparentArea alloc] init];
    area.rect = rect;
    area.radius = radius;
    
    return area;
}

@end


#pragma mark - MSGuideMaskView

@interface MSGuideMaskView ()

@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) CGFloat maskAlpha;
@property (nonatomic, assign) UIEdgeInsets edgeInsetsInMaskedView;
@property (nonatomic, strong) NSString *firstGuideKey;
@property (nonatomic, strong) NSMutableArray *transparencies;
@property (nonatomic, strong) UIView *maskedView;

@property (nonatomic, strong) UITapGestureRecognizer *closeGuesture;
@property (nonatomic, strong) UIImageView *animationImg;

@end


@implementation MSGuideMaskView

#pragma mark - 生命周期

- (instancetype)init {
    return [self initWithFirstGuideKey:nil];
}

- (instancetype)initWithFirstGuideKey:(NSString *)firstGuideKey {
    self = [super init];
    if (self) {
        self.firstGuideKey = firstGuideKey;
        if ([self canShow]) {
            self.maskColor = [UIColor blackColor];
            self.maskAlpha = 0.7f;
            self.backgroundColor = [UIColor clearColor];
            self.opaque =NO;
            self.closeGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
            [self addGestureRecognizer:self.closeGuesture];
            
            self.transparencies = [NSMutableArray array];
        }
    }
    return self;
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat alpha = 0.0f;
    [self.maskColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:self.maskAlpha];
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextAddRect(context, rect);
    for (MSTransparentArea *area in self.transparencies) {
        CGRect arect = area.rect;
        CGFloat radius = area.radius;
        
        CGMutablePathRef roundRect = CGPathCreateRoundedRect(arect, radius);
        CGContextAddPath(context, roundRect);
        CGPathRelease(roundRect);
        
    }
    CGContextEOFillPath(context);
}

#pragma mark - 事件处理

- (void)clickMaskView {
    [self markShowed];
    if (self.featureDidClosed) {
        self.featureDidClosed();
    }
    [self removeFromSuperview];
}

- (void)clickCloseButton:(UIButton *)button
{
    [self markShowed];
    if (self.featureDidClosed) {
        self.featureDidClosed();
    }
    [self removeFromSuperview];
}

#pragma mark - 设置
- (void)setMaskedView:(UIView *)maskedView {
    if ([self canShow]) {
        _maskedView = maskedView;
    }
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    _maskAlpha = maskAlpha;
}

- (void)setEdgesInMaskedView:(UIEdgeInsets)edgeInsets {
    self.edgeInsetsInMaskedView = edgeInsets;
}

#pragma mark - 显示
/** 清除所有指引图 */
+ (void)clearAllInMaskedView:(UIView *)maskedView {
    for (UIView *subview in maskedView.subviews) {
        if ([subview isKindOfClass:[MSGuideMaskView class]]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)show {
    if (![self canShow]) {
        return;
    }
    [self removeShowing];
    
    CGFloat x = self.edgeInsetsInMaskedView.left;
    CGFloat y = self.edgeInsetsInMaskedView.top;
    CGFloat height = self.maskedView.frame.size.height - self.edgeInsetsInMaskedView.top - self.edgeInsetsInMaskedView.bottom;
    CGFloat width = self.maskedView.frame.size.width - self.edgeInsetsInMaskedView.left - self.edgeInsetsInMaskedView.right;
    self.frame = CGRectMake(x, y, width, height);
    
    [self.maskedView addSubview:self];
}

- (void)markShowed {
    if (!self.firstGuideKey) {
        return;
    }
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    [userDefaluts setValue:@"showing" forKey:self.firstGuideKey];
    [userDefaluts synchronize];
}

- (BOOL)canShow {
    if (self.firstGuideKey) {
        NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
        NSString *exist = [userDefaluts valueForKey:self.firstGuideKey];
        if (exist) {
            return NO;
        }
    }
    return YES;
}

- (void)removeShowing {
    for (UIView *subview in self.maskedView.subviews) {
        if ([subview isKindOfClass:[MSGuideMaskView class]]) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - add Transparent area
- (void)addTransparentRect:(CGRect)TransparentRect {
    [self addTransparentRect:TransparentRect radius:0.0f];
}

- (void)addTransparentInView:(UIView *)view {
    [self addTransparentInView:view radius:0.0f];
}

- (void)addTransparentInView:(UIView *)view radius:(CGFloat)radius {
    [self addTransparentInView:view radius:radius innerRect:CGRectMake(0.0f, 0.0, view.frame.size.width, view.frame.size.height)];
}

- (void)addTransparentInView:(UIView *)view radius:(CGFloat)radius innerRect:(CGRect)innerRect {
    CGPoint innerOrigin = innerRect.origin;
    CGPoint newOrigin = [view convertPoint:innerOrigin toView:self.maskedView];
    CGRect TransparentRect = CGRectMake(newOrigin.x,
                                         newOrigin.y,
                                         innerRect.size.width,
                                         innerRect.size.height);
    
    [self addTransparentRect:TransparentRect radius:radius];
}

- (void)addTransparentRect:(CGRect)TransparentRect radius:(CGFloat)radius {
    CGFloat x = TransparentRect.origin.x - self.edgeInsetsInMaskedView.left;
    CGFloat y = TransparentRect.origin.y - self.edgeInsetsInMaskedView.top;
    CGFloat height = TransparentRect.size.height;
    CGFloat width = TransparentRect.size.width;
    
    MSTransparentArea *area = [MSTransparentArea areaWithRect:CGRectMake(x, y, width, height) radius:radius];
    [self.transparencies addObject:area];
}

#pragma mark - add guide view

- (void)addImage:(UIImage *)image inRect:(CGRect)rect {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat x = rect.origin.x - self.edgeInsetsInMaskedView.left;
    CGFloat y = rect.origin.y - self.edgeInsetsInMaskedView.top;
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    imageView.frame = CGRectMake(x, y, width, height);
    [self addSubview:imageView];
}

/** 覆盖在view上，并居中显示 */
- (void)addImage:(UIImage *)image inview:(UIView *)view {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGPoint oldviewOrigin = view.frame.origin;
    CGPoint newviewOrigin = [view.superview convertPoint:oldviewOrigin toView:self.maskedView];
    CGFloat x = newviewOrigin.x + (view.frame.size.width - imageWidth) / 2;
    CGFloat y = newviewOrigin.y + (view.frame.size.height - imageHeight) / 2;
    [self addImage:image inRect:CGRectMake(x, y, imageWidth, imageHeight)];
}

- (void)addAnimationImage:(UIImage *)image inRect:(CGRect)rect {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat x = rect.origin.x - self.edgeInsetsInMaskedView.left;
    CGFloat y = rect.origin.y - self.edgeInsetsInMaskedView.top;
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    imageView.frame = CGRectMake(x, y, width, height);
    [self addSubview:imageView];
    _animationImg = imageView;
}

- (void)startAnimation {
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation1.toValue = @(-50);
    // 比例缩放
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation2.toValue = @(0.5);
    // 透明度
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation3.toValue = @(0);
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime() + 1;
    group.duration = 1.5;
    group.repeatCount = 999;
    group.removedOnCompletion = YES;
    group.animations = [NSArray arrayWithObjects:animation1, animation3, nil];
    [_animationImg.layer addAnimation:group forKey:@"group"];
    self.maskedView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.maskedView.userInteractionEnabled = YES;
    });
}

@end
