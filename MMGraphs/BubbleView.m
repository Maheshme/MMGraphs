//
//  BubbleView.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "BubbleView.h"

#define DATE_FONT_SIZE            14

@interface BubbleView ()

@property (nonatomic) BOOL firstTime, isVertical;

@end

@implementation BubbleView

-(instancetype)initWithGraphType:(Graph_Type)graphType
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        if (graphType == Graph_Type_Vertical)
            _isVertical =YES;
        
        //View which holds date and value labels
        _mainView = [[UIView alloc]init];
        _mainView.backgroundColor = [UIColor blackColor];
        [self addSubview:_mainView];
        
        //View for creating indicator (i.e.., arrow)
        _indicationView = [[UIView alloc]init];
        _indicationView.backgroundColor = [UIColor blackColor];
        [_mainView addSubview:_indicationView];

        //Label to display value
        _valueLabel = [[UILabel alloc]init];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.backgroundColor = [UIColor clearColor];
        [_valueLabel setTextColor:[UIColor whiteColor]];
        [_mainView addSubview:_valueLabel];
        
        _firstTime = YES;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_isVertical)
    {
        _mainView.frame = CGRectMake(0, _mainView.frame.origin.y, self.frame.size.width, self.frame.size.height*0.9);
        _mainView.layer.cornerRadius = _mainView.frame.size.width/7;
        if (_firstTime)
        {
            _indicationView.frame = CGRectMake(0, 0, (self.frame.size.height*0.1)*(sqrt(2.0)),  (self.frame.size.height*0.1)*(sqrt(2.0)));
            _indicationView.center = CGPointMake(_mainView.frame.size.width*0.5, _mainView.frame.size.height);
            _indicationView.transform = CGAffineTransformMakeRotation(M_PI/4);
            _firstTime = NO;
        }
        _valueLabel.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }
    else
    {
        _mainView.frame = CGRectMake(_mainView.frame.origin.x, 0, self.frame.size.width*0.9, self.frame.size.height);
        _mainView.layer.cornerRadius = _mainView.frame.size.width/7;
        if (_firstTime)
        {
            _indicationView.frame = CGRectMake(0, 0, (self.frame.size.height*0.1)*(sqrt(2.0)),  (self.frame.size.height*0.1)*(sqrt(2.0)));
            _indicationView.center = CGPointMake(_mainView.frame.origin.x, _mainView.frame.size.height*0.5);
            _indicationView.transform = CGAffineTransformMakeRotation(M_PI/4);
            _firstTime = NO;
        }
        _valueLabel.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }
}


@end
