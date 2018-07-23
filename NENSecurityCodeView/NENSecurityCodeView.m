//
//  NENSecurityCodeView.m
//  NENSecurityCodeView
//
//  Created by weuse_hao on 2018/7/20.
//  Copyright © 2018 weuse_hao. All rights reserved.
//

#import "NENSecurityCodeView.h"

#define NENCodeViewHeight self.frame.size.height

@interface NENSecurityCodeView ()<UITextFieldDelegate>

/// 存放 label 的数组
@property (nonatomic, strong) NSMutableArray *labelArr;
/// label 的数量
@property (nonatomic, assign) NSInteger labelCount;
/// label 之间的距离
@property (nonatomic, assign) CGFloat labelDistance;
/// label 的宽度
@property (nonatomic, assign) CGFloat sideLength;
/// 输入文本框
@property (nonatomic, strong) NENTextField *codeTextField;

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@end

@implementation NENSecurityCodeView

- (instancetype)initWithFrame:(CGRect)frame
                andLabelCount:(NSInteger)labelCount
             andLabelDistance:(CGFloat)labelDistance
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.labelCount = labelCount;
        self.labelDistance = labelDistance;
        self.showCursor = YES;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGFloat labelX;
    CGFloat labelY = 0;
    CGFloat labelWidth = self.codeTextField.frame.size.width / self.labelCount;
    CGFloat sideLength = labelWidth < NENCodeViewHeight ? labelWidth : NENCodeViewHeight;
    self.sideLength = sideLength;
    for (int i = 0; i < self.labelCount; i++) {
        if (i == 0) {
            labelX = 0;
        } else {
            labelX = i * (sideLength + self.labelDistance);
        }
        NENLabel *label = [[NENLabel alloc] initWithFrame:CGRectMake(labelX, labelY, sideLength, sideLength)];
        [self addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        [self.labelArr addObject:label];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSInteger i = textField.text.length;
    if (i == 0) {
        ((UILabel *)[self.labelArr objectAtIndex:0]).text = @"";
    } else {
        ((UILabel *)[self.labelArr objectAtIndex:i - 1]).text = [NSString stringWithFormat:@"%C", [textField.text characterAtIndex:i - 1]];
        if (self.labelCount > i) {
            ((UILabel *)[self.labelArr objectAtIndex:i]).text = @"";
        }
    }
    CGRect frame = self.lineLayer.frame;
    frame.origin.x = i * (self.sideLength + self.labelDistance);
    self.lineLayer.frame = frame;
    if (self.codeBlock) {
        self.codeBlock(textField.text);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    !self.showCursor ?:[self.layer addSublayer:self.lineLayer];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.lineLayer removeFromSuperlayer];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    } else if (string.length == 0) {
        return YES;
    } else if (textField.text.length >= self.labelCount) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 懒加载
- (NENTextField *)codeTextField {
    if (!_codeTextField) {
        _codeTextField = [[NENTextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, NENCodeViewHeight)];
        [_codeTextField becomeFirstResponder];
        _codeTextField.delegate = self;
        [_codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_codeTextField];
    }
    return _codeTextField;
}

- (NSMutableArray *)labelArr {
    if (!_labelArr) {
        _labelArr = [NSMutableArray array];
    }
    return _labelArr;
}

- (CAShapeLayer *)lineLayer
{
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.frame = CGRectMake(0, 0, 2, self.bounds.size.height);
        _lineLayer.backgroundColor = [UIColor blueColor].CGColor;
        [_lineLayer addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
    return _lineLayer;
}

- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 1.2;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}

@end

@implementation NENTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor clearColor];
        self.tintColor = [UIColor clearColor];
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

/// 重写 UITextFiled 子类, 解决长按复制粘贴的问题
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end


@interface NENLabel ()

@property (nonatomic, strong) UIView *placeView;

@end


@implementation NENLabel : UILabel

static char NENLabelKVOContext = 0;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.placeView];
        [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&NENLabelKVOContext];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self] && (context == &NENLabelKVOContext) && [keyPath isEqualToString:@"text"]) {
        if ([change[@"new"] isEqualToString:@""]) {
            [self addSubview:self.placeView];
        } else {
            [self.placeView removeFromSuperview];
        }
    }
}

- (UIView *)placeView
{
    if (!_placeView) {
        _placeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2 - 1, self.bounds.size.width, 2)];
        _placeView.backgroundColor = [UIColor blackColor];
        _placeView.layer.cornerRadius = 1;
    }
    return _placeView;
}


@end
