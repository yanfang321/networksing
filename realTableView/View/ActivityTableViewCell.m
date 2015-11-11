//
//  ActivityTableViewCell.m
//  realTableView
//
//  Created by ZIYAO YANG on 15/8/6.
//  Copyright (c) 2015年 ZIYAO YANG. All rights reserved.
//

#import "ActivityTableViewCell.h"

@implementation ActivityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}

-(void)layoutSubviews {
    [super layoutSubviews];
    _applicationButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _applicationButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

@end
