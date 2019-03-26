//
//  MSIntroductionPage.h
//  TipsView
//
//  Created by ypl on 2018/11/12.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EllipsePageControl.h"

@protocol MSIntroductionDelegate <NSObject>
- (void)msIntroductionViewEnterTap:(id)sender;
@end

@interface MSIntroductionPage : UIViewController
@property (nonatomic, strong) UIScrollView * pageScrollView;//浮层ScrollView
@property (nonatomic, strong) UIButton     * enterBtn;//进入按钮
@property (nonatomic, strong) UIButton     * skipBtn;//调过按钮
@property (nonatomic, assign) BOOL           msAutoScrolling;//是否自动滚动
@property (nonatomic, assign) CGPoint        msPageControlOffSet;//pageControl默认偏移量
@property (nonatomic, strong) EllipsePageControl *msPageControl;//引导pageControl


@property (nonatomic, strong) NSArray      * backgroundImgArr;//底层背景图数组
@property (nonatomic, strong) NSArray      * coverImgArr;//浮层图片数组
@property (nonatomic, strong) NSArray      * coverTitlesArr;//浮层文字数组
@property (nonatomic, strong) NSDictionary * msLabelAttributesDic;//文字特性

@property (nonatomic, strong) NSArray      * titlesArr;//浮层标题文字数组
@property (nonatomic, strong) NSArray      * descArr;//浮层描述文字数组
@property (nonatomic, strong) NSArray      * msPageArr;//放置浮层view数组
@property (nonatomic, strong) NSMutableArray * msTitlelabelArr;
@property (nonatomic, strong) NSMutableArray * msDesclabelArr;

@property (nonatomic, weak) id<MSIntroductionDelegate>delegate;

- (instancetype)init;


@end
