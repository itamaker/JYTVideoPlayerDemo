//
//  SunnyVideoLoadingView.h
//  SunnyVideoPlayer
//
//  Created by amaker on 15/10/20.
//  Copyright © 2015年 amaker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kLoadLarge,
    kLoadNomal,
    kLoadnone,
} kLoadType;

@protocol SunnyVideoLoadingViewDelegate <NSObject>
@optional
- (void)clickRetry;

@end

@interface SunnyVideoLoadingView : UIView

/**
 *  菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView * indicatorView;

/**
 *  网速
 */
@property (nonatomic, strong) UILabel * netWorkLabel;

/**
 *  标题
 */
@property (nonatomic, strong) UILabel * titleLabel;

/**
 *  重试按钮
 */
@property (nonatomic, strong) UIButton * retryBtn;

@property (nonatomic, weak) id<SunnyVideoLoadingViewDelegate>  delegate;

-(instancetype)initWithFrame:(CGRect)frame andLoadType:(kLoadType)type;

- (void)showLoading;
- (void)showRetry:(BOOL)isError;
- (void)hide;

@end
