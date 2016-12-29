//
//  ScatterPlotGraph.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/28/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "ScatterPlotGraph.h"
#import "GraphPlotObj.h"
#import "XAxisGraphLabel.h"
#import "BubbleView.h"

#define STARTING_Y                      self.frame.size.height*0.9
#define ENDING_Y                        11.0
#define STARTING_X                      self.frame.size.width*0
#define MAX_HEIGHT_OF_BAR               (STARTING_Y - ENDING_Y)
#define BAR_WIDTH                       10.0
#define SPACING                         40.0
#define TOTAL_BAR_WIDTH                 (BAR_WIDTH + SPACING)
#define PERCENTAGE_OF_BAR               (BAR_WIDTH/TOTAL_BAR_WIDTH)

@interface ScatterPlotGraph ()

@property (nonatomic, strong) NSArray *plotArray;
@property (nonatomic) float yMax;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic) BOOL isScrolling;

@property (nonatomic, strong) UIView *xAxisSeperator;
@property (nonatomic, strong) UIBezierPath *graphPath;
@property (nonatomic, strong) CAShapeLayer *graphLayer;
@property (nonatomic, strong) UIButton *xAxisScrollButton;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation ScatterPlotGraph

- (instancetype)initWithPlotArray:(NSArray *)plotArray
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        _plotArray = [NSArray arrayWithArray:plotArray];
        _labelArray = [[NSMutableArray alloc]init];
        
        _isScrolling = NO;
        
        _yMax = [[plotArray valueForKeyPath:@"@max.value"] floatValue];
        
        [self allocateRequirments];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xAxisSeperator.frame = CGRectMake(STARTING_X, STARTING_Y, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width, 1);
    _graphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if(!_isScrolling)
        for (XAxisGraphLabel *xAxisxLabel in _labelArray)
        {
            xAxisxLabel.frame = CGRectMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, STARTING_Y, SCREEN_WIDTH*0.2, self.frame.size.height*0.1);
            xAxisxLabel.center = CGPointMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, STARTING_Y+xAxisxLabel.frame.size.height/2);
            [self bringSubviewToFront:xAxisxLabel];
        }
    
    if (_valueLabel.frame.size.width <= 0)
    {
        _valueLabel.frame = CGRectMake(0, 0, MINIMUM_WIDTH_OF_BUTTON, MINIMUM_HEIGHT_OF_BUTTON);
        _valueLabel.transform = CGAffineTransformMakeScale(PERCENTAGE_OF_BAR, PERCENTAGE_OF_BAR);
        _valueLabel.alpha = 0;
    }
    
    _valueLabel.layer.cornerRadius = _valueLabel.frame.size.width/2;
    [self bringSubviewToFront:_valueLabel];
    
    _xAxisScrollButton.frame = CGRectMake(_xAxisScrollButton.frame.origin.x, _xAxisScrollButton.frame.origin.y, MINIMUM_WIDTH_OF_BUTTON*0.7, MINIMUM_HEIGHT_OF_BUTTON*0.7);
    _xAxisScrollButton.layer.cornerRadius = _xAxisScrollButton.frame.size.width/2;
    _xAxisScrollButton.center = CGPointMake(_xAxisScrollButton.center.x, STARTING_Y);
    
}

-(void)drawRect:(CGRect)rect
{
    [self alterHeights];
    _graphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    
    if (_labelArray.count == 0)
        [self labelCreation];
    
    [self drawBarGraph];
}

//Scroll view delegates to restrict layout subviews during scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _isScrolling = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isScrolling = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        _isScrolling = NO;
}


-(void) allocateRequirments
{
    _xAxisSeperator = [[UIView alloc]init];
    _xAxisSeperator.backgroundColor = [UIColor blackColor];
    [self addSubview:_xAxisSeperator];
    
    //Bezier path for ploting graph
    _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:TOTAL_BAR_WIDTH];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graph
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = [[UIColor clearColor] CGColor];
    _graphLayer.strokeColor = COLOR(233.0, 245.0, 252.0, 1).CGColor;
    _graphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _graphLayer.lineCap = @"round";
    _graphLayer.lineJoin = @"round";
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    _xAxisScrollButton = [[UIButton alloc]init];
    _xAxisScrollButton.backgroundColor = COLOR(238.0, 211.0, 105.0, 1);
    [_xAxisScrollButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_xAxisScrollButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_xAxisScrollButton setTitle:@"--" forState:UIControlStateNormal];
    [_xAxisScrollButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:_xAxisScrollButton];

    _valueLabel = [[UILabel alloc]init];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [_valueLabel setClipsToBounds:YES];
    _valueLabel.backgroundColor = COLOR(170.0, 204.0, 225.0, 0.6);
    [_valueLabel setTextColor:COLOR(8.0, 48.0, 69.0, 1)];
    [self addSubview:_valueLabel];
}

//Alter heights for change in orientation
-(void)alterHeights
{
    /*Here we are giving a gap 10% of screen height from origin. So for calluculated height of the bar we add 10% of height, because we plot in inverce compared to coordinate geometry.*/
    for (GraphPlotObj *barData in _plotArray)
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
}

-(void)drawBarGraph
{
    [_graphPath removeAllPoints];
    _graphPath = nil;
    
    //Bezier path for ploting graph
    if (_graphPath == nil)
        _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    [[UIColor blackColor] setStroke];
    
    for (GraphPlotObj *barSource in _plotArray)
    {
        [_graphPath moveToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
        [_graphPath addLineToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
    }
    
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    self.contentSize = CGSizeMake(TOTAL_BAR_WIDTH*_plotArray.count, self.frame.size.height);
}

-(void)labelCreation
{
    for (GraphPlotObj *barSource in _plotArray)
    {
        XAxisGraphLabel *label = [[XAxisGraphLabel alloc] initWithText:barSource.labelName textAlignement:NSTextAlignmentCenter andTextColor:COLOR(210.0, 211.0, 211.0, 1)];
        [self addSubview:label];
        label.numberOfLines = 0;
        label.dotView.alpha = 0;
        label.position = barSource.position;
        
        [_labelArray addObject:label];
    }
}

//Getting point when user touches graph
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    [self getValueWith:location fromButton:NO];
}

//Getting values based on move of Scroll button
- (void) dragMoving:(UIControl *)c withEvent:ev
{
    float xPos;
    if ([[[ev allTouches] anyObject] locationInView:self].x >= STARTING_X)
        xPos =[[[ev allTouches] anyObject] locationInView:self].x;
    else
        xPos = STARTING_X;
    
    if (xPos > self.contentSize.width)
        c.center =  CGPointMake(self.contentSize.width,  STARTING_Y);
    else
        c.center =  CGPointMake(xPos,  STARTING_Y);
    
    [self getValueWith:[[[ev allTouches] anyObject] locationInView:self] fromButton:YES];
    
}


//Get value for the touched point on Button
-(void)getValueWith:(CGPoint)touchPoint fromButton:(BOOL)fromButton
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.position == %d", (int)(touchPoint.x/TOTAL_BAR_WIDTH)];
    NSArray *resultArray = [_plotArray filteredArrayUsingPredicate:predicate];

    GraphPlotObj *result;
    
    
    if (resultArray.count > 0)
    {
        result = (GraphPlotObj *)[resultArray firstObject];
        if (_valueLabel.center.x != (result.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2)
        {
            _valueLabel.transform = CGAffineTransformMakeScale(PERCENTAGE_OF_BAR, PERCENTAGE_OF_BAR);
            _valueLabel.center = CGPointMake((result.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, result.barHeight);
            //Display bubble if touch is on bar
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [_valueLabel setText:[NSString stringWithFormat:@"%d",(int)result.value]];
                                 _valueLabel.alpha = 1;
                                 if (!fromButton)
                                     _xAxisScrollButton.center = CGPointMake((result.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, STARTING_Y);
                                 _valueLabel.transform = CGAffineTransformMakeScale(1, 1);
                                 _valueLabel.layer.cornerRadius = _valueLabel.frame.size.width/2;
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    else //On touch of graph above bar height
        _valueLabel.alpha = 0;
}

@end
