//
//  AKBrushButton.m
//  ASCIIboardContainer
//
//  Created by Matt Condon on 12/13/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "AKBrushButton.h"

@implementation AKBrushButton

- (AKBrushButton *)initWithBrushSize:(float)size andRadius:(float)radius
{
    self = [[[self class] alloc] initWithImage:nil andRadius:radius];
    if (self) {
        [self setStyle:MCBouncyButtonStyleSelected animated:NO];
        // add brush circle to button
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size*1.2, size*1.2)];
        circle.layer.cornerRadius = (size*1.2)/2;
        circle.backgroundColor = [UIColor whiteColor];
        circle.center = CGPointMake(radius, radius);
        circle.userInteractionEnabled = NO;
        [self addSubview:circle];
    }
    return self;
}

@end
