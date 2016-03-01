//
//  JYTVideoLoadingView.m
//  JYTVideoPlayerDemo
//
//  Created by amaker on 15/10/20.
//  Copyright © 2015年 amaker. All rights reserved.
//

#import "JYTVideoLoadingView.h"

@interface JYTVideoLoadingView ()

@property (nonatomic,assign) kLoadType type;

@end

@implementation JYTVideoLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView:frame];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame andLoadType:(kLoadType)type{
    self.type = type;
    self = [self initWithFrame:frame];
    return self;
}

-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        if (self.type == kLoadNomal) {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            _indicatorView.frame = CGRectMake(self.frame.size.width / 5, self.frame.size.height / 10, 20, 44);
        }else{
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            _indicatorView.frame = CGRectMake(self.frame.size.width / 5, self.frame.size.height / 10, 44, 44);
        }
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UILabel *)netWorkLabel{
    if (!_netWorkLabel) {
        _netWorkLabel = [[UILabel alloc] init];
        _netWorkLabel.frame = CGRectMake(CGRectGetMaxX(self.indicatorView.frame) + self.frame.size.width / 20, self.frame.size.height / 10, self.frame.size.height, 44);
        _netWorkLabel.textColor = [UIColor whiteColor];
        if (self.type == kLoadLarge) {
            _netWorkLabel.font = [UIFont systemFontOfSize:16];
        }else{
            _netWorkLabel.font = [UIFont systemFontOfSize:12];
        }
        [self addSubview:_netWorkLabel];
    }
    return _netWorkLabel;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        NSLog(@"%.f",CGRectGetMaxY(self.indicatorView.frame));
        if (self.type == kLoadNomal) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 10, 30, self.frame.size.width - 20, 40)];
        }else{
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 10, CGRectGetMaxY(self.indicatorView.frame), self.frame.size.width - 20, 40)];
        }
        _titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        if (self.type == kLoadLarge) {
            _titleLabel.font = [UIFont systemFontOfSize:17];
        }else{
            _titleLabel.font = [UIFont systemFontOfSize:13];
        }
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)retryBtn{
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 - 25, self.frame.size.width, 50)];
        [_retryBtn setImage:[UIImage imageNamed:@"movie_retry"] forState:UIControlStateNormal];
        [_retryBtn addTarget:self action:@selector(clickRetry) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryBtn];
    }
    return _retryBtn;
}

- (void)setUpView:(CGRect)frame{
    self.layer.cornerRadius = 10;
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.indicatorView startAnimating];
    self.netWorkLabel.text = @"0KB/s";
    self.titleLabel.text = @"正在缓冲，请稍后...";
}

- (void)showLoading{
    self.hidden = NO;
    self.indicatorView.hidden = NO;
    self.netWorkLabel.hidden = NO;
    self.titleLabel.hidden = NO;
    self.retryBtn.hidden = YES;
    self.netWorkLabel.text = @"0KB/s";
}

- (void)showRetry:(BOOL)isError{
    self.hidden = NO;
    self.retryBtn.hidden = NO;
    self.indicatorView.hidden = YES;
    self.netWorkLabel.hidden = YES;
    self.titleLabel.hidden = YES;
    if (isError) {
        [self.retryBtn setTitle:@"视频播放失败，点击重试" forState:UIControlStateNormal];
        self.retryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }else{
        [self.retryBtn setTitle:@"点击重新播放" forState:UIControlStateNormal];
        self.retryBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    }
}

- (void)hide{
    self.hidden = YES;
    
}

- (void)clickRetry{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRetry)]) {
        [self.delegate clickRetry];
    }
}

@end
