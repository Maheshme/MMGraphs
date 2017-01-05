//
//  XAxisGraphLabel.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//


#import "XAxisGraphLabel.h"

#define DOT_DIA                         self.frame.size.width * 0.20
#define DOT_BACKGROUND_COLOR            [UIColor whiteColor]

#define LABEL_FONT                      12
#define LABEL_TEXT_COLOR                [UIColor whiteColor]

@interface XAxisGraphLabel ()
@property (nonatomic) NSTextAlignment alignment;
@end

@implementation XAxisGraphLabel


-(instancetype)initWithText:(NSString *)labelText textAlignement:(NSTextAlignment)textAlignment andTextColor:(UIColor *)textColor
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _dotPading = 0;
        
        _dotView = [[UIView alloc]init];
        _dotView.backgroundColor = textColor;
        [self addSubview:_dotView];

        _alignment = textAlignment;
        [self setText:labelText];
        [self setTextColor:textColor];
        [self setFont:[UIFont systemFontOfSize:LABEL_FONT]];
        self.textAlignment = textAlignment;
        self.numberOfLines = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dotView.frame = CGRectMake(0, 0, DOT_DIA/2.5, DOT_DIA/2.5);
    _dotView.layer.cornerRadius = DOT_DIA/5;
    
    if (_alignment == NSTextAlignmentLeft)
        _dotView.center = CGPointMake(0+_dotPading, 0);
    else if(_alignment == NSTextAlignmentCenter)
        _dotView.center = CGPointMake(self.frame.size.width/2+_dotPading, 0);
    else
        _dotView.center = CGPointMake(self.frame.size.width, 0);

}

@end
