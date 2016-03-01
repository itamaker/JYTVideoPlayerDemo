//
//  JYTVideoTopBar.m
//  JYTVideoPlayerDemo
//
//  Created by amaker on 15/10/14.
//  Copyright © 2015年 amaker. All rights reserved.
//

#import "JYTVideoTopBar.h"

@implementation JYTVideoTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.backBtn setImage:[UIImage imageNamed:@"common_back_arrow"] forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.backBtn setTitle:@"" forState:UIControlStateNormal];
        self.backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self addSubview:self.backBtn];
        
        self.starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.starBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.starBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        self.starBtn.backgroundColor = [UIColor clearColor];
        [self.starBtn setImage:[UIImage imageNamed:@"star_button"] forState:UIControlStateNormal];
        [self.starBtn setImage:[UIImage imageNamed:@"stared_button"] forState:UIControlStateSelected];
        self.starBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.starBtn setTitle:@"0" forState:UIControlStateNormal];
        [self.starBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.starBtn setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
        [self addSubview:self.starBtn];
        
    }
    return self;
}

-(void)layoutSubviews{
    self.backBtn.frame = CGRectMake(15, 0, self.frame.size.width / 3 * 2, 50);
    self.starBtn.frame = CGRectMake(self.frame.size.width - 15 - self.frame.size.width / 3, 0, self.frame.size.width / 3, 50);
}

@end
