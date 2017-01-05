//
//  MultiScatterGraph.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/28/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "MultiScatterGraph.h"
#import "GraphPlotObj.h"
#import "XAxisGraphLabel.h"
#import "BubbleView.h"

#define STARTING_Y                      self.frame.size.height*0.9
#define ENDING_Y                        0
#define STARTING_X                      self.frame.size.width*0
#define MAX_HEIGHT_OF_BAR               (STARTING_Y - ENDING_Y)
#define BAR_WIDTH                       10.0
#define SPACING                         40.0
#define TOTAL_BAR_WIDTH                 (BAR_WIDTH + SPACING)
#define PERCENTAGE_OF_BAR               (BAR_WIDTH/TOTAL_BAR_WIDTH)
#define LABEL_Y_ORIGIN                  self.frame.size.height*0.9

@interface MultiScatterGraph ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *firstPlotArray, *secondPlotArray;
@property (nonatomic) float yMax;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic) BOOL isScrolling;

@property (nonatomic, strong) UIView *xAxisSeperator, *labelSeperator;
@property (nonatomic, strong) UIBezierPath *firstGraphPath, *secondGraphPath;
@property (nonatomic, strong) CAShapeLayer *firstGraphLayer, *secondGraphLayer;
@property (nonatomic, strong) BubbleView *firstGraphBubble, *secondGraphBubble;

@end

@implementation MultiScatterGraph

- (instancetype)initWithFirstPlotArray:(NSArray *)firstPlotArray andSecondPlotArray:(NSArray *)secondPlotArray
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        _firstPlotArray = [NSArray arrayWithArray:firstPlotArray];
        _secondPlotArray = [NSArray arrayWithArray:secondPlotArray];
        _labelArray = [[NSMutableArray alloc]init];
        
        _isScrolling = NO;
        
        _yMax = ([[firstPlotArray valueForKeyPath:@"@max.value"] floatValue] > [[secondPlotArray valueForKeyPath:@"@max.value"] floatValue]) ? [[firstPlotArray valueForKeyPath:@"@max.value"] floatValue] : [[secondPlotArray valueForKeyPath:@"@max.value"] floatValue];
        
        [self allocateRequirments];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xAxisSeperator.frame = CGRectMake(STARTING_X, STARTING_Y, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width, 1);
    _labelSeperator.frame = CGRectMake(STARTING_X, LABEL_Y_ORIGIN, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width, 1);
    _firstGraphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    _secondGraphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    
    if(_secondGraphBubble.frame.size.width <= 0)
        _secondGraphBubble.frame = CGRectMake(_secondGraphBubble.frame.origin.x, _secondGraphBubble.frame.origin.y, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.12);
    if(_firstGraphBubble.frame.size.width <= 0)
        _firstGraphBubble.frame = CGRectMake(_firstGraphBubble.frame.origin.x, _firstGraphBubble.frame.origin.y, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.12);
    
    if(!_isScrolling)
        for (XAxisGraphLabel *xAxisxLabel in _labelArray)
        {
            xAxisxLabel.frame = CGRectMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, LABEL_Y_ORIGIN, SCREEN_WIDTH*0.2, self.frame.size.height*0.1);
            xAxisxLabel.center = CGPointMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, LABEL_Y_ORIGIN+xAxisxLabel.frame.size.height/2);
            [self bringSubviewToFront:xAxisxLabel];
        }
    
    self.contentSize = CGSizeMake((self.contentSize.width > self.frame.size.width) ? self.contentSize.width : self.frame.size.width, self.frame.size.height);
}

-(void)drawRect:(CGRect)rect
{
    [self alterHeights];
    _firstGraphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _secondGraphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    
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
    
    _labelSeperator = [[UIView alloc]init];
    _labelSeperator.backgroundColor = [UIColor blackColor];
    [self addSubview:_labelSeperator];
    
    //Bezier path for ploting graph
    _firstGraphPath = [[UIBezierPath alloc]init];
    [_firstGraphPath setLineWidth:TOTAL_BAR_WIDTH];
    [[UIColor blackColor] setStroke];
    
    _secondGraphPath = [[UIBezierPath alloc]init];
    [_secondGraphPath setLineWidth:TOTAL_BAR_WIDTH];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graph
    _firstGraphLayer = [CAShapeLayer layer];
    _firstGraphLayer.fillColor = [[UIColor clearColor] CGColor];
    _firstGraphLayer.strokeColor = COLOR(168.0, 183.0, 137.0, 1).CGColor;
    _firstGraphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _firstGraphLayer.lineCap = @"round";
    _firstGraphLayer.lineJoin = @"round";
    _firstGraphLayer.geometryFlipped = YES;
    _firstGraphLayer.path = [_firstGraphPath CGPath];
    [self.layer addSublayer:_firstGraphLayer];
    
    //CAShapeLayer for graph
    _secondGraphLayer = [CAShapeLayer layer];
    _secondGraphLayer.fillColor = [[UIColor clearColor] CGColor];
    _secondGraphLayer.strokeColor = COLOR(255.0, 215.0, 71.0, 1).CGColor;
    _secondGraphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _secondGraphLayer.lineCap = @"round";
    _secondGraphLayer.lineJoin = @"round";
    _secondGraphLayer.geometryFlipped = YES;
    _secondGraphLayer.path = [_secondGraphPath CGPath];
    [self.layer addSublayer:_secondGraphLayer];
    
    for (CALayer *layer in self.blurrView.layer.sublayers)
        if ([layer isEqual:_firstGraphLayer] || [layer isEqual:_secondGraphLayer])
            [layer removeFromSuperlayer];
    
}

//Alter heights for change in orientation
-(void)alterHeights
{
    _firstGraphBubble.alpha = 0;
    _secondGraphBubble.alpha = 0;
    
    /*Here we are giving a gap 10% of screen height from origin. So for calluculated height of the bar we add 10% of height, because we plot in inverce compared to coordinate geometry.*/
    for (GraphPlotObj *barData in _firstPlotArray)
    {
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(barData.value/_yMax);
        barData.coordinate.x = (barData.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X;
        barData.coordinate.y = barData.barHeight;
    }
    
    for (GraphPlotObj *barData in _secondPlotArray)
    {
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(barData.value/_yMax);
        barData.coordinate.x = (barData.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X;
        barData.coordinate.y = barData.barHeight;
    }
}

-(void)drawBarGraph
{
    _firstGraphBubble.alpha = 0;
    _secondGraphBubble.alpha = 0;
    
    [_firstGraphPath removeAllPoints];
    _firstGraphPath = nil;
    
    [_secondGraphPath removeAllPoints];
    _secondGraphPath = nil;
    
    //Bezier path for ploting graph
    if (_firstGraphPath == nil)
        _firstGraphPath = [[UIBezierPath alloc]init];
    [_firstGraphPath setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    [[UIColor blackColor] setStroke];
    
    if (_secondGraphPath == nil)
        _secondGraphPath = [[UIBezierPath alloc]init];
    [_secondGraphPath setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    [[UIColor blackColor] setStroke];
    
    
    for (GraphPlotObj *barSource in _firstPlotArray)
    {
        [_firstGraphPath moveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y)];
        [_firstGraphPath addLineToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y)];
    }
    
    for (GraphPlotObj *barSource in _secondPlotArray)
    {
        [_secondGraphPath moveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y)];
        [_secondGraphPath addLineToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y)];
    }
    
    _firstGraphLayer.path = [_firstGraphPath CGPath];
    
    _secondGraphLayer.path = [_secondGraphPath CGPath];
    
    self.contentSize = CGSizeMake(TOTAL_BAR_WIDTH*_firstPlotArray.count, self.frame.size.height);
}

-(void)labelCreation
{
    for (GraphPlotObj *barSource in _firstPlotArray)
    {
        XAxisGraphLabel *label = [[XAxisGraphLabel alloc] initWithText:barSource.labelName textAlignement:NSTextAlignmentCenter andTextColor:COLOR(210.0, 211.0, 211.0, 1)];
        [self addSubview:label];
        label.numberOfLines = 0;
        label.dotView.alpha = 0;
        label.position = barSource.position;
        
        [_labelArray addObject:label];
    }
}

@end
