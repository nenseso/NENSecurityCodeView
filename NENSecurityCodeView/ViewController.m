//
//  ViewController.m
//  NENSecurityCodeView
//
//  Created by weuse_hao on 2018/7/20.
//  Copyright © 2018 weuse_hao. All rights reserved.
//

#import "ViewController.h"
#import "NENSecurityCodeView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat labelWidth = 28;
    CGFloat labelDistance = 15;
    NSInteger labelCount = 6;
    CGFloat width = labelWidth * labelCount + labelDistance * (labelCount - 1);
    CGFloat height = labelWidth;
    CGFloat centerY = self.view.bounds.size.height * 0.5;
    CGRect frame = CGRectMake(0, 0, width, height);
    NENSecurityCodeView *codeView = [[NENSecurityCodeView alloc] initWithFrame:frame andLabelCount:labelCount andLabelDistance:labelDistance];
    codeView.center = CGPointMake(self.view.bounds.size.width * 0.5, centerY);
    [self.view addSubview:codeView];
    codeView.showCursor = YES;
    codeView.codeBlock = ^(NSString *codeString) {
        NSLog(@"验证码:%@", codeString);
    };
}


@end
