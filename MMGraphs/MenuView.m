//
//  MenuView.m
//  GraphMenu
//
//  Created by Mahesh.me on 12/23/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "MenuView.h"


@interface MenuView ()

@property (nonatomic, strong) UIBezierPath *linePath;
@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CABasicAnimation *drawAnimation;
@property (nonatomic) BOOL menuOpen;
@property (nonatomic) float seperationHeight;


@end

@implementation MenuView

-(instancetype)initWithArrayOfLabels:(NSArray *)arrayOfLabels andBlurEffect:(UIBlurEffect *)blurrEffect
{
    self = [super initWithEffect:blurrEffect];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        _menuOpen = NO;
        _arrayOfGraphButtons = [[NSMutableArray alloc]init];
        
        _backgroundButton = [[UIButton alloc]init];
        _backgroundButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_backgroundButton];
        
        //Bezier path for ploting graph
        if (_linePath == nil)
            _linePath = [[UIBezierPath alloc]init];
        [_linePath setLineWidth:2];
        [[UIColor colorWithWhite:1 alpha:0.4] setStroke];
        
        //Left CAShapeLayer for graph allocation
        if (_lineLayer == nil)
            _lineLayer = [CAShapeLayer layer];
        _lineLayer.fillColor = [[UIColor clearColor] CGColor];
        _lineLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
        _lineLayer.lineWidth = 2;
        _lineLayer.lineJoin = @"round";
        _lineLayer.path = [_linePath CGPath];
        [self.layer addSublayer:_lineLayer];
        
        //Animation for drawing the path
        if (_drawAnimation == nil)
            _drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _drawAnimation.duration = 0.5;
        _drawAnimation.repeatCount = 1.0;
        
        for (int i = 0; i < arrayOfLabels.count ; i++)
        {
            UIButton *menuButton = [[UIButton alloc]init];
            menuButton.tag = i;
            [menuButton setTitle:[arrayOfLabels objectAtIndex:i] forState:UIControlStateNormal];
            [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.contentView addSubview:menuButton];
            [_arrayOfGraphButtons addObject:menuButton];
        }        
    }
    return  self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (!_menuOpen)
    {
        _seperationHeight = (self.frame.size.height - (MENU_SIZE.width/2+MENU_CENTER.y))/(_arrayOfGraphButtons.count+1);
        for (UIButton *menu in _arrayOfGraphButtons)
        {
            menu.frame = CGRectMake(0, 0, self.frame.size.width*0.5, MINIMUM_HEIGHT_OF_BUTTON/2);
            menu.center = CGPointMake(-2*MENU_SIZE.width, (menu.tag+1)*_seperationHeight + (MENU_SIZE.width/2+MENU_CENTER.y));
        }
    }
    
    [self.contentView sendSubviewToBack:_backgroundButton];
}

-(void)drawRect:(CGRect)rect
{
    [self menuClicked];
}


-(void)menuClicked
{
    _menuOpen = YES;
    [_linePath moveToPoint:CGPointMake(MENU_CENTER.x, MENU_CENTER.y+MENU_SIZE.height/2)];

    for (UIButton *menu in _arrayOfGraphButtons)
    {
        [_linePath addLineToPoint:CGPointMake(MENU_CENTER.x, menu.center.y - menu.frame.size.height/2)];
        [_linePath moveToPoint:CGPointMake(MENU_CENTER.x, menu.center.y + menu.frame.size.height/2)];
    }
    [_linePath addLineToPoint:CGPointMake(MENU_CENTER.x, self.frame.size.height)];
    
    _drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    _drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    _lineLayer.path = [_linePath CGPath];
    [_lineLayer addAnimation:_drawAnimation forKey:@"drawCircleAnimation"];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         for (UIButton *menu in _arrayOfGraphButtons)
                             menu.center = CGPointMake(MENU_CENTER.x, menu.center.y);
                         
                     } completion:^(BOOL finished) {
                     }];
}

-(void)removePath
{
    [_linePath removeAllPoints];
    [_lineLayer removeFromSuperlayer];
}

@end
