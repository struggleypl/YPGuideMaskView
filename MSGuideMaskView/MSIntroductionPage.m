//
//  MSIntroductionPage.m
//  TipsView
//
//  Created by ypl on 2018/11/12.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import "MSIntroductionPage.h"

#define kScaleSize(num)  (num*([UIScreen mainScreen].bounds.size.width/375))
#define isIphoneX        (([UIApplication sharedApplication].statusBarFrame.size.height==44)?YES:NO)

@interface MSIntroductionPage ()<UIScrollViewDelegate>
{
    NSArray        * _msBgViewArr;
    NSInteger        _msCurrentIndex;
    NSTimer        * _msTimer;
    CGFloat          _positionY;
}
@end


@implementation MSIntroductionPage

- (NSMutableArray *)msTitlelabelArr {
    if (!_msTitlelabelArr) {
        _msTitlelabelArr = [NSMutableArray new];
    }
    return _msTitlelabelArr;
}

- (NSMutableArray *)msDesclabelArr {
    if (!_msDesclabelArr) {
        _msDesclabelArr = [NSMutableArray new];
    }
    return _msDesclabelArr;
}

- (NSArray *)msGetPageArr{
    if([self msGetPagesNum] <1){
        return  nil;
    }
    if(_msPageArr){
        return _msPageArr;
    }
    NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
    if(_coverImgArr){
        [_coverImgArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tmpArr addObject:[self msGetCoverImgViewWithImgName:obj]];
        }];
    }else if(_coverTitlesArr){
        [_coverTitlesArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tmpArr addObject:[self msGetPageWithTitle:obj]];
        }];
    }
    _msPageArr = tmpArr;
    return  _msPageArr;
}

- (void)msReloadCoverTitles{
    for(UILabel * label in _msPageArr){
        
        CGFloat height = 30;
        NSString * text = [label.attributedText string];
        if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
            CGSize size = [text sizeWithAttributes:_msLabelAttributesDic];
            height = size.height;
        }
        label.attributedText = [[NSAttributedString alloc]initWithString:text attributes:_msLabelAttributesDic];
    }
}

- (void)msReloadTitles {
    __block CGFloat x = 0;
    [self.msTitlelabelArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * view = (UIView *)obj;
        view.frame = CGRectOffset(view.frame, x, 0);
        [self.pageScrollView addSubview:view];
        x += view.frame.size.width;
        NSLog(@"x:%.2f",x);
        if (idx==0&&self.msTitlelabelArr.count>0) {
            UILabel *titlelabel = self.msTitlelabelArr[idx];
            [self addLineAnimationWithView:titlelabel fromPoint:CGPointMake(CGRectGetMidX(titlelabel.frame)+200, CGRectGetMidY(titlelabel.frame)) toPoint:CGPointMake(CGRectGetMidX(titlelabel.frame), CGRectGetMidY(titlelabel.frame))];
        }
    }];
}

- (void)msReloadDescription {
    __block CGFloat x = 0;
    [self.msDesclabelArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * view = (UIView *)obj;
        view.frame = CGRectOffset(view.frame, x, 0);
        [self.pageScrollView addSubview:view];
        x += view.frame.size.width;
        NSLog(@"x:%.2f",x);
        if (idx==0&&self.msDesclabelArr.count>0) {
            UILabel *desclabel = self.msDesclabelArr[idx];
            [self addLineAnimationWithView:desclabel fromPoint:CGPointMake(CGRectGetMidX(desclabel.frame)-200, CGRectGetMidY(desclabel.frame)) toPoint:CGPointMake(CGRectGetMidX(desclabel.frame), CGRectGetMidY(desclabel.frame))];
        }
    }];
}

- (instancetype)init{
    if(self = [super init]){
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _positionY = isIphoneX?60:0;
        [self loadUI];
    }
    return self;
}

- (void)loadUI{
    self.msAutoScrolling = NO;
    [self msLayoutSkipBtn];
    [self msLayoutEnterBtn];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self msStopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self msAddPageScroll];
    [self msStartTimer];
}

- (void)msEnter:(UIButton *)object{
    [self msStopTimer];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(msIntroductionViewEnterTap:)]){
        [self.delegate msIntroductionViewEnterTap:object];
    }
}

- (void)msAddBackgroundViews{
    CGRect frame = self.view.bounds;
    NSMutableArray * tmpArr = [NSMutableArray new];
    [[[_backgroundImgArr reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView * imgView = [[UIImageView alloc]init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.image = [UIImage imageNamed:obj];
        imgView.frame = frame;
        imgView.tag = idx + 1;
        [tmpArr addObject:imgView];
        [self.view addSubview:imgView];
        
    }];
    _msBgViewArr = [[tmpArr reverseObjectEnumerator] allObjects];
    [self.view bringSubviewToFront:self.pageScrollView];
    [self.view bringSubviewToFront:_msPageControl];
}

- (void)setBackgroundImgArr:(NSArray *)backgroundImgArr{
    _backgroundImgArr = backgroundImgArr;
    [self msAddBackgroundViews];
}

- (void)setCoverImgArr:(NSArray *)coverImgArr {
    _coverImgArr = coverImgArr;
    [self msReloadPage];
}

- (void)setCoverTitlesArr:(NSArray *)coverTitlesArr {
    _coverTitlesArr = coverTitlesArr;
    [self msReloadPage];
}

- (void)setmsLabelAttributesDic:(NSDictionary *)msLabelAttributesDic{
    _msLabelAttributesDic = msLabelAttributesDic;
    [self msReloadCoverTitles];
}

- (void)setTitlesArr:(NSArray *)titlesArr {
    _titlesArr = titlesArr;
    [_titlesArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *titleLabel = [self msGetPageWithTitle:(NSString *)obj];
        [self.msTitlelabelArr addObject:titleLabel];
    }];
    [self msReloadTitles];
}

- (void)setDescArr:(NSArray *)descArr {
    _descArr = descArr;
    [_descArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *titleLabel = [self msGetPageWithDescription:(NSString *)obj];
        [self.msDesclabelArr addObject:titleLabel];
    }];
    [self msReloadDescription];
}

- (void)msLayoutSkipBtn{
    if(!self.skipBtn){
        self.skipBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.skipBtn setTitle:@"跳过 >" forState:UIControlStateNormal];
        [self.skipBtn setBackgroundColor:[UIColor clearColor]];
        [self.skipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.skipBtn.titleLabel setFont:[UIFont systemFontOfSize:kScaleSize(13)]];
        self.skipBtn.frame = CGRectMake(self.view.frame.size.width-80, isIphoneX?kScaleSize(50):kScaleSize(30), 80, 30);
    }
    [self.skipBtn addTarget:self action:@selector(msEnter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipBtn];
}

- (void)msAddPageScroll{
    self.pageScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.pageScrollView.delegate = self;
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    self.pageScrollView.userInteractionEnabled = YES;
    [self.view addSubview:self.pageScrollView];
    _msPageControl = [[EllipsePageControl alloc]initWithFrame:[self msLayoutPageControlFrame]];
    _msPageControl.currentColor = [UIColor whiteColor];
    _msPageControl.otherColor = [UIColor whiteColor];
    [self.view addSubview:_msPageControl];
}

- (void)msLayoutEnterBtn{
    if(!self.enterBtn){
        self.enterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.enterBtn setTitle:@"马上体验" forState:UIControlStateNormal];
        [self.enterBtn setBackgroundColor:[UIColor whiteColor]];
        [self.enterBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:191/255.0 blue:0/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [self.enterBtn setTitleColor:[UIColor colorWithRed:245/255.0 green:185/255.0 blue:0/255.0 alpha:1/1.0] forState:UIControlStateHighlighted];
        self.enterBtn.hidden = NO;
        self.enterBtn.frame = [self msLayoutEnterBtnFrame];
        self.enterBtn.layer.cornerRadius = self.enterBtn.frame.size.height/2;
        self.enterBtn.clipsToBounds = YES;
        self.enterBtn.alpha = 0;
    }
    [self.enterBtn addTarget:self action:@selector(msEnter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enterBtn];
}

- (CGRect)msLayoutPageControlFrame{
    CGRect msFrame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 30);
    return CGRectOffset(msFrame,self.msPageControlOffSet.x, self.msPageControlOffSet.y);
}

- (CGRect)msLayoutEnterBtnFrame{
    CGSize size = self.enterBtn.bounds.size;
    if(CGSizeEqualToSize(size, CGSizeZero)){
        size = CGSizeMake(self.view.frame.size.width * 0.6, kScaleSize(50));
    }
    return CGRectMake(self.view.frame.size.width/2 -size.width/2,self.view.frame.size.height - size.height - ([UIScreen mainScreen].bounds.size.width==320?20:30), size.width, size.height);
}

- (void)msStartTimer{
    if(_msAutoScrolling){
        _msTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(msOnTimer) userInfo:nil repeats:YES];
    }
}

- (void)msOnTimer{
    CGRect frame = self.pageScrollView.frame;
    frame.origin.x = frame.size.width * (_msPageControl.currentPage + 1);
    frame.origin.y = 0;
    if(frame.origin.x >= self.pageScrollView.contentSize.width){
        frame.origin.x = 0;
    }
    [self.pageScrollView scrollRectToVisible:frame animated:YES];
}

- (void)msStopTimer{
    [_msTimer invalidate];
    _msTimer = nil;
}

- (void)msReloadPage{
    _msPageControl.numberOfPages = [self msGetPagesNum];
    _pageScrollView.contentSize = [self msGetScrollContentSize];
    __block CGFloat x = 0;
    NSArray * msPageArr = [self msGetPageArr];
    [msPageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * view = (UIView *)obj;
        view.userInteractionEnabled = YES;
        view.frame = CGRectOffset(view.frame, x, 0);
        [self.pageScrollView addSubview:view];
        x += view.frame.size.width;
//        if(idx == msPageArr.count - 1){
//            [view addSubview:self.enterBtn];
//        }
    }];
    
    if(_msPageControl.numberOfPages == 1){
        _enterBtn.alpha = 1;
        _msPageControl.alpha = 0;
    }
    if(self.pageScrollView.contentSize.width == self.pageScrollView.frame.size.width){
        self.pageScrollView.contentSize = CGSizeMake(self.pageScrollView.contentSize.width + 1, self.pageScrollView.contentSize.height);
    }
    [self msLayoutSkipBtn];
    [self msLayoutEnterBtn];
}

- (void)setmsAutoScrolling:(BOOL)msAutoScrolling{
    _msAutoScrolling = msAutoScrolling;
    if(!_msTimer&&_msAutoScrolling){
        [self msStartTimer];
    }
}

- (NSInteger)msGetPagesNum{
    if(_coverImgArr){
        return _coverImgArr.count;
        
    }else if(_coverTitlesArr){
        return _coverTitlesArr.count;
        
    }
    return 0;
}

- (NSInteger)msGetCurrentPage{
    return self.pageScrollView.contentOffset.x/self.view.bounds.size.width;
}

- (CGSize)msGetScrollContentSize{
    UIView * view = [[self msGetPageArr] firstObject];
    return CGSizeMake(view.frame.size.width* _msPageArr.count, view.frame.size.height);
}

- (void)msPageControlChangePage:(UIScrollView *)pageScrollView{
    __weak typeof(self) weakSelf = self;
    if([self msIsLastPage:_msPageControl]){
        if(_msPageControl.alpha == 1){
            [UIView animateWithDuration:0.75 animations:^{
                weakSelf.enterBtn.alpha = 1;
                weakSelf.msPageControl.alpha = 0;
            }];
        }
    }else{
        if(_msPageControl.alpha == 0){
            [UIView animateWithDuration:0.75 animations:^{
                weakSelf.enterBtn.alpha = 0;
                weakSelf.msPageControl.alpha = 1;
            }];
        }
    }
}

- (BOOL)msIsLastPage:(UIPageControl *)pageControl{
    return pageControl.numberOfPages == pageControl.currentPage + 1;
}

- (BOOL)msIsGoOnNext:(UIPageControl *)pageControl{
    return pageControl.numberOfPages>pageControl.currentPage + 1;
}

- (UILabel *)msGetPageWithTitle:(NSString *)title{
    CGSize size = self.view.frame.size;
    CGRect rect;
    CGFloat height = 30;
    if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        CGSize size = [title sizeWithAttributes:_msLabelAttributesDic];
        height = size.height;
    }
    rect = CGRectMake(0, kScaleSize(70)+_positionY, size.width, height);
    UILabel * label = [[UILabel alloc]initWithFrame:rect];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:kScaleSize(36)];
    label.alpha = 0;
    return  label;
}

- (UILabel *)msGetPageWithDescription:(NSString *)description {
    CGSize size = self.view.frame.size;
    CGRect rect;
    CGFloat height = 30;
    if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        CGSize size = [description sizeWithAttributes:_msLabelAttributesDic];
        height = size.height;
    }
    rect = CGRectMake(0, kScaleSize(110)+_positionY, size.width, height);
    UILabel * label = [[UILabel alloc]initWithFrame:rect];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = description;
    label.font = [UIFont fontWithName:@"PingFangSC-Thin" size:kScaleSize(24)];
    label.alpha = 0;
    return  label;
}

- (UIView *)msGetCoverImgViewWithImgName:(NSString *)imgName{
    UIImageView * imgView = [[UIImageView alloc]init];
    imgView.image = [UIImage imageNamed:imgName];
    imgView.userInteractionEnabled = YES;
    CGSize size = self.view.bounds.size;
    imgView.frame = CGRectMake(0,kScaleSize(120)+_positionY, size.width, kScaleSize(500));
    imgView.userInteractionEnabled = YES;
    return imgView;
}

#pragma mark  -  代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/self.view.frame.size.width;
    CGFloat msAlpha =  1-(scrollView.contentOffset.x - index*self.view.bounds.size.width)/self.view.bounds.size.width;
    if([_msBgViewArr count] >index){
        UIView * view = [_msBgViewArr objectAtIndex:index];
        if(view){
            view.alpha = msAlpha;
        }
    }
    [_msPageControl setCurrentPage:[self msGetCurrentPage]];
    [self msPageControlChangePage:scrollView];
    if(scrollView.isTracking){
        [self msStopTimer];
    }else{
        if(!_msTimer){
            [self msStartTimer];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if([scrollView.panGestureRecognizer translationInView:scrollView.superview].x<0){
        if(![self msIsGoOnNext:_msPageControl]){
//            [self msEnter:nil];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/self.view.frame.size.width;
    if (index!=_msCurrentIndex) {
        if (index<self.msTitlelabelArr.count) {
            UILabel *titlelabel = self.msTitlelabelArr[index];
            [self addLineAnimationWithView:titlelabel fromPoint:CGPointMake(CGRectGetMidX(titlelabel.frame)+200, CGRectGetMidY(titlelabel.frame)) toPoint:CGPointMake(CGRectGetMidX(titlelabel.frame), CGRectGetMidY(titlelabel.frame))];
        }
        if (index<self.msDesclabelArr.count) {
            UILabel *desclabel = self.msDesclabelArr[index];
            [self addLineAnimationWithView:desclabel fromPoint:CGPointMake(CGRectGetMidX(desclabel.frame)-200, CGRectGetMidY(desclabel.frame)) toPoint:CGPointMake(CGRectGetMidX(desclabel.frame), CGRectGetMidY(desclabel.frame))];
        }
    }
    if (index<self.msTitlelabelArr.count&&index!=_msCurrentIndex) {
        UILabel *titlelabel = self.msTitlelabelArr[_msCurrentIndex];
        [UIView animateWithDuration:0.75 animations:^{
            titlelabel.alpha = 0;
        }];
    }
    if (index<self.msDesclabelArr.count&&index!=_msCurrentIndex) {
        UILabel *desclabel = self.msDesclabelArr[_msCurrentIndex];
        [UIView animateWithDuration:0.75 animations:^{
            desclabel.alpha = 0;
        }];
    }
    _msCurrentIndex = index;
}

-(void)addLineAnimationWithView:(UIView *)view fromPoint:(CGPoint)fromePoint toPoint:(CGPoint)toPoint {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            view.alpha = 1;
        }];
        CABasicAnimation* moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        moveAnimation.fromValue = [NSValue valueWithCGPoint:fromePoint];
        moveAnimation.toValue = [NSValue valueWithCGPoint:toPoint];
        moveAnimation.duration = 0.35;
        moveAnimation.removedOnCompletion = NO;
        moveAnimation.repeatCount = 1;
        [view.layer addAnimation:moveAnimation forKey:@"singleLineAnimation"];
    });
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self msStopTimer];
    self.view = nil;
}
@end
