//
//  AKBrushButton.m
//  ASCIIboardContainer
//
//  Created by Matt Condon on 12/13/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "AKBrushButton.h"

@implementation AKBrushButton

- (AKBrushButton *)initWithBrushSize:(float)size andDiamter:(float)diameter
{
    self = [[[self class] alloc] initWithImage:nil andDiameter:diameter];
    if (self) {
        [self setStyle:AKButtonStyleSelected];
        // add brush circle to button
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        circle.layer.cornerRadius = size/2;
        circle.backgroundColor = [UIColor whiteColor];
        circle.center = CGPointMake(diameter/2, diameter/2);
        [self addSubview:circle];
    }
    return self;
}

@end
