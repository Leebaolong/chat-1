//
//  MIMMessageCommonCell.m
//  MyIM
//
//  Created by Jonathan on 15/8/20.
//  Copyright (c) 2015年 Jonathan. All rights reserved.
//

#import "MIMMessageCommonCell.h"

@interface MIMMessageCommonCell ()

@end

@implementation MIMMessageCommonCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageContentView:(UIView *)messageContentView
{
    if (_messageContentView == messageContentView) {
        return;
    }
    else{
        if (_messageContentView) {
            [_messageContentView removeFromSuperview];
        }
    }
    _messageContentView = messageContentView;
    
    [self.contentView addSubview:messageContentView];

    [messageContentView setTranslatesAutoresizingMaskIntoConstraints:NO];

    //创建约束
    NSLayoutConstraint *leadingCt = [NSLayoutConstraint constraintWithItem:messageContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    NSLayoutConstraint *trailingCt = [NSLayoutConstraint constraintWithItem:messageContentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];

    NSLayoutConstraint *topCt = [NSLayoutConstraint constraintWithItem:messageContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomCt = [NSLayoutConstraint constraintWithItem:messageContentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];


    [self.contentView addConstraints:@[leadingCt, trailingCt, topCt, bottomCt]];
}
@end
