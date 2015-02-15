//
//  AKFullWidthButton.m
//  ASCIIboardContainer
//
//  Created by Matt Condon on 1/3/15.
//  Copyright (c) 2015 Shrugs. All rights reserved.
//

#import "AKLargeButton.h"
#import <Masonry/Masonry.h>
#import "Config.h"

@implementation AKLargeButton

- (id)initWithText:(NSString *)text
{
    self = [[self class] buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.layer.backgroundColor = [ASKEY_BUTTON_BODY_COLOR CGColor];
//        self.layer.shadowColor = [ASKEY_BUTTON_SHADOW_COLOR CGColor];
        [self setTitle:text forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:ASKEY_BUTTON_FONT size:25];
        [self setTitleColor:ASKEY_BUTTON_TEXT_COLOR forState:UIControlStateNormal];

        self.layer.cornerRadius = 4.0f;
//        self.layer.masksToBounds = NO;
//        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
//        self.layer.shadowOpacity = 1.0f;
//        self.layer.shadowRadius = 0.0f;

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

@end