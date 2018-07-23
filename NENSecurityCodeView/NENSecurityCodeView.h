//
//  NENSecurityCodeView.h
//  NENSecurityCodeView
//
//  Created by weuse_hao on 2018/7/20.
//  Copyright © 2018 weuse_hao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NENCodeDidChangeBlock)(NSString *codeString);

@interface NENSecurityCodeView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                andLabelCount:(NSInteger)labelCount
             andLabelDistance:(CGFloat)labelDistance;

/// 回调的 block , 获取输入的数字
@property (nonatomic, copy) NENCodeDidChangeBlock codeBlock;
/// 是否显示光标，默认显示.
@property (nonatomic, assign) BOOL showCursor;
@end

@interface NENTextField : UITextField

@end

@interface NENLabel : UILabel

@end

NS_ASSUME_NONNULL_END
