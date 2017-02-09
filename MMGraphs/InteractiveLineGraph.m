//
//  InteractiveLineGraph.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/28/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "InteractiveLineGraph.h"
#import "XAxisGraphLabel.h"
#import "GraphPlotObj.h"
#import "GraphModel.h"
#import "Coordinates.h"

#define MAX_X_AXIS_LABELS                               5
#define TIME_INTERVAL                                   10    //Minutes
#define X_AXIS_LABELS_FONT                              11
#define SEPERATOR_HEIGHT                                1
#define STARTING_Y                                      (self.frame.size.height*0.9)
#define ENDING_Y                                        (self.frame.size.height*0.1)
#define STARTING_X                                      (self.frame.size.width*0.0)
#define MAX_HEIGHT_OF_GRAPH                             (STARTING_Y - ENDING_Y)
#define LINE_CAP_ROUND                                  @"round"
#define GRAPH_WIDTH                                     2

@interface InteractiveLineGraph ()

@property (nonatomic, strong) UIBezierPath *graphPath;
@property (nonatomic, strong) CAShapeLayer *graphLayer;
@property (nonatomic) float maxY, minY, minX, maxX, rangeOfY/*, xUnit*/, slope, labelCount;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic) BOOL isScrolling, labelAllocated;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NSArray *plotArray;
@property (nonatomic, strong) UIButton *graphButton, *scroller;
@property (nonatomic, strong) Coordinates *previousCoord, *nextCoord;
@property (nonatomic, strong) CABasicAnimation *drawAnimation;
@property (nonatomic, strong) CAGradientLayer *grad;

@property (nonatomic, strong) GraphConfig *layoutConfig;

@end

@implementation InteractiveLineGraph

- (instancetype)initWithConfigData:(GraphConfig *)configData
{
    self = [super init];
    if (self)
    {
        [configData needCalluculator];
        _layoutConfig = configData;
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.bounces = NO;
        
        _plotArray = [NSArray arrayWithArray:_layoutConfig.firstPlotAraay];
        
        _maxY = [[_layoutConfig.firstPlotAraay valueForKeyPath:@"@max.value"] floatValue];
        _minY = [[_layoutConfig.firstPlotAraay valueForKeyPath:@"@min.value"] floatValue];
        
        _maxX =[[_layoutConfig.firstPlotAraay valueForKeyPath:@"@max.position"] floatValue];
        _minX = [[_layoutConfig.firstPlotAraay valueForKeyPath:@"@min.position"] floatValue];
        
        _previousCoord = [[Coordinates alloc]init];
        _nextCoord = [[Coordinates alloc]init];
        
        _rangeOfY = _maxY - _minY;
        
        _isScrolling = NO;
        _labelAllocated = NO;
        
        [self allocateRequirments];
    }
    return self;
}

//- (instancetype)initWithPlotArray:(NSArray *)plotArray
//{
//    self = [super init];
//    if (self)
//    {
//        self.backgroundColor = [UIColor clearColor];
//        self.delegate = self;
//        self.bounces = NO;
//
//        _plotArray = [NSArray arrayWithArray:plotArray];
//        
//        _maxY = [[plotArray valueForKeyPath:@"@max.value"] floatValue];
//        _minY = [[plotArray valueForKeyPath:@"@min.value"] floatValue];
//        
//        _maxX =[[plotArray valueForKeyPath:@"@max.position"] floatValue];
//        _minX = [[plotArray valueForKeyPath:@"@min.position"] floatValue];
//        
//        _previousCoord = [[Coordinates alloc]init];
//        _nextCoord = [[Coordinates alloc]init];
//        
//        _rangeOfY = _maxY - _minY;
//        
//        _isScrolling = NO;
//        _labelAllocated = NO;
//
//        [self allocateRequirments];
//    }
//    return self;
//}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _separator.frame = CGRectMake(_layoutConfig.startingX, _layoutConfig.startingY, (self.contentSize.width > self.frame.size.width) ? self.contentSize.width : self.frame.size.width, SEPERATOR_HEIGHT);
    _graphLayer.frame = CGRectMake(0, _layoutConfig.endingY, self.frame.size.width, _layoutConfig.maxHeightOfBar);
    
    if (_valueLabel.frame.size.width <= 0)
        _valueLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.1);
    
    if (!_isScrolling)
    {
        NSArray *labelsArray = [[self subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.class == %@",[XAxisGraphLabel class]]];
        for (XAxisGraphLabel *xAxisLabel in labelsArray)
        {
            xAxisLabel.frame = CGRectMake((xAxisLabel.position*_layoutConfig.totalBarWidth*TIME_INTERVAL)+_layoutConfig.startingX, _layoutConfig.startingY, self.frame.size.width*0.1, self.frame.size.height*0.14);
            if(xAxisLabel.position != 0)
                xAxisLabel.center = CGPointMake((xAxisLabel.position*_layoutConfig.totalBarWidth)+_layoutConfig.startingX, xAxisLabel.center.y);
            [self bringSubviewToFront:xAxisLabel];
        }
    }
    _scroller.frame = CGRectMake(_scroller.frame.origin.x, _scroller.frame.origin.y, MINIMUM_WIDTH_OF_BUTTON, MINIMUM_HEIGHT_OF_BUTTON);
    _scroller.layer.cornerRadius = _scroller.frame.size.width/2;
    _scroller.center = CGPointMake(_scroller.center.x, _layoutConfig.startingY);
    
    if (_graphButton.frame.size.width <= 0)
    {
        _graphButton.frame = CGRectMake(0, 0, MINIMUM_WIDTH_OF_BUTTON*0.3, MINIMUM_HEIGHT_OF_BUTTON*0.3);
        _scroller.center = CGPointMake(_layoutConfig.startingX, _layoutConfig.startingY);
    }
    
    _graphButton.layer.cornerRadius = _graphButton.frame.size.width/2;
    [self bringSubviewToFront:_graphButton];
    
   

    [self bringSubviewToFront:_scroller];
    [self bringSubviewToFront:_graphButton];
    
    self.contentSize = CGSizeMake((self.frame.size.width > self.contentSize.width) ? self.frame.size.width : self.contentSize.width, self.frame.size.height);
}

-(void)drawRect:(CGRect)rect
{
    if (!_labelAllocated)
        [self createLabels];
    [self alterCoordinates];
    [self drawGraph];
}

//Scroll view delegates to restrict layout subviews during scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _isScrolling = YES;
    _valueLabel.center = CGPointMake(scrollView.contentOffset.x + SCREEN_WIDTH/2, _valueLabel.center.y);
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


//Allocate needs for grah
-(void)allocateRequirments
{
    //Seperator line view
    _separator = [[UIView alloc]init];
    _separator.backgroundColor = [UIColor blackColor];
    [self addSubview:_separator];
    
    //Bezier path for ploting graph
    _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:_layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graph allocation
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = [[UIColor clearColor] CGColor];
    _graphLayer.strokeColor = COLOR(210.0, 211.0, 211.0, 1).CGColor;
    _graphLayer.lineWidth = GRAPH_WIDTH;
    _graphLayer.lineCap = LINE_CAP_ROUND;
    _graphLayer.lineJoin = LINE_CAP_ROUND;
    _graphLayer.geometryFlipped = YES;
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    for (CALayer *layer in self.blurrView.layer.sublayers)
        if ([layer isEqual:_graphLayer])
            [layer removeFromSuperlayer];
    
    _scroller = [[UIButton alloc]init];
    _scroller.backgroundColor = COLOR(238.0, 211.0, 105.0, 1);
    [_scroller setTitleColor:COLOR(8.0, 48.0, 69.0, 1) forState:UIControlStateNormal];
    [_scroller.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_scroller setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_scroller setTitle:@"--" forState:UIControlStateNormal];
    [_scroller addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:_scroller];
    
    _graphButton = [[UIButton alloc]init];
    _graphButton.backgroundColor = COLOR(13.0, 60.0, 85.0, 1);
    [self addSubview:_graphButton];

    //Animation for drawing the path
    _drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _drawAnimation.duration = 2.5;
    _drawAnimation.repeatCount = 1.0;
    [_drawAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];//[CAMediaTimingFunction functionWithControlPoints:0.0 :0.25 :0.56 :0.73]

    _grad = [[CAGradientLayer alloc]init];
    _grad.colors = @[(__bridge id)COLOR(210.0, 181.0, 59.0, 1).CGColor, (__bridge id)COLOR(241.0, 108.0, 32.0, 1).CGColor, (__bridge id)COLOR(192.0, 49.0, 32.0, 1).CGColor ];
    _grad.startPoint = CGPointMake(0,0.0);
    _grad.endPoint = CGPointMake(0,1.0);
    [self.layer addSublayer:_grad];
    
    _valueLabel = [[UILabel alloc]init];
    _valueLabel.backgroundColor = [UIColor clearColor];
    [_valueLabel setTextAlignment:NSTextAlignmentCenter];
    [_valueLabel setTextColor:[UIColor blackColor]];
    [_valueLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:_valueLabel];
    
}


-(void)alterCoordinates
{
    for (GraphPlotObj *graphData in _plotArray)
    {
        graphData.barHeight = ((graphData.value/_rangeOfY)*_layoutConfig.maxHeightOfBar);
        graphData.coordinate.y = graphData.barHeight;
        graphData.coordinate.x = (graphData.position *_layoutConfig.totalBarWidth)+_layoutConfig.startingX;//_xUnit*graphData.position+_layoutConfig.startingX;
    }
}

-(void)createLabels
{
    //Time Label creation in x-axis
    _labelCount = ((_maxX/TIME_INTERVAL) > MAX_X_AXIS_LABELS) ? ((_maxX/TIME_INTERVAL) + 1) : MAX_X_AXIS_LABELS;
    for (int i = 0; i < _labelCount  ; i++)
        [self createLabelsWithLabelCount:i*TIME_INTERVAL];
    
    _labelAllocated = YES;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//Creating x-axis time labels
-(void)createLabelsWithLabelCount:(int)labelNumber
{
    XAxisGraphLabel *label = [[XAxisGraphLabel alloc]initWithText:[NSString stringWithFormat:@"%d",labelNumber] textAlignement:(labelNumber == 0) ? NSTextAlignmentLeft : NSTextAlignmentCenter andTextColor:[UIColor blackColor]];
    label.position = labelNumber;
    [self addSubview:label];
}

-(void)drawGraph
{
    //Remove complete plot
    [_graphPath removeAllPoints];
    self.contentSize = CGSizeMake(_layoutConfig.totalBarWidth*(_plotArray.count-1)+_layoutConfig.startingX, self.frame.size.height);
    
    float curvatureFactor = 0.2;
    
    for (GraphPlotObj *graphData  in _plotArray)
    {
        if ([graphData isEqual:[_plotArray firstObject]])
            [_graphPath moveToPoint:CGPointMake(graphData.coordinate.x, graphData.coordinate.y)];
        else
        {
        /*If u need jst line but not curve then comment the line below and uncomment the line below that(i.e.., addLineToPoint) or make curvatureFactor = 0. Then u will get line graph. If u need to increase the curvature, then increase the factor to 0.5. Play arround by changing curvatureFactor. But recommend curvatureFactor shoubd be (0 - 0.5). But if u make curvatureFactor to 0.5 grah will be more curvy, so the graph button will not stick to graph. If there is no curvature then graph button will work correctly. Recommend curvatureFactor is 0.2 so we can get both.*/
//            [_graphPath addCurveToPoint:CGPointMake(graphData.coordinate.x, graphData.coordinate.y) controlPoint1:CGPointMake(_graphPath.currentPoint.x+_xUnit*curvatureFactor, _graphPath.currentPoint.y) controlPoint2:CGPointMake(graphData.coordinate.x-_xUnit*curvatureFactor, graphData.coordinate.y)];
        
            [_graphPath addLineToPoint:CGPointMake(graphData.coordinate.x, graphData.coordinate.y)];
        }
    }
    
    _drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    _drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    _graphLayer.path = [_graphPath CGPath];
    _grad.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    _grad.mask = _graphLayer;

    [_graphLayer addAnimation:_drawAnimation forKey:@"drawCircleAnimation"];
}

//Getting values based on move of Scroll button
- (void) dragMoving:(UIControl *)c withEvent:ev
{
    float xPos;

   if ([[[ev allTouches] anyObject] locationInView:self].x > _layoutConfig.startingX)
       xPos =[[[ev allTouches] anyObject] locationInView:self].x;
    else
        xPos = _layoutConfig.startingX;
    
    [_scroller setTitle:[self getTimeWithXPosition:xPos] forState:UIControlStateNormal];
    
    if (xPos > self.contentSize.width)
        c.center =  CGPointMake(self.contentSize.width,  _layoutConfig.startingY);
    else
        c.center =  CGPointMake(xPos,  _layoutConfig.startingY);
    
    if (c.center.x < [(GraphPlotObj *)[_plotArray lastObject] coordinate].x)
    {
        if ((xPos > _nextCoord.x) || (xPos < _previousCoord.x))
        {
            [self getSlopeForCurrentXPosition:xPos];
        }
        
        float y = (_slope * (xPos-_previousCoord.x))+_previousCoord.y;
        if (!isnan(y))
            _graphButton.center = CGPointMake(c.center.x, y);
    }
    else
    {
        GraphPlotObj *lastPoint = (GraphPlotObj *)[_plotArray lastObject];
        if(!isnan(lastPoint.coordinate.y))
            _graphButton.center = CGPointMake(lastPoint.coordinate.x, _layoutConfig.maxHeightOfBar - lastPoint.coordinate.y);
    }
}

#pragma  mark - Slope calluculation for movement of interactive buttons
-(void)getSlopeForCurrentXPosition:(float)xPos
{
    NSPredicate *predicateForLowest =[NSPredicate predicateWithFormat:@"coordinate.x <= %f", xPos];
    NSSortDescriptor *discriptor = [NSSortDescriptor sortDescriptorWithKey:@"coordinate.x" ascending:NO];
    GraphPlotObj *cord = [[[_plotArray filteredArrayUsingPredicate:predicateForLowest] sortedArrayUsingDescriptors:@[discriptor]] firstObject];
    
    _previousCoord.x = cord.coordinate.x;
    _previousCoord.y = _layoutConfig.endingY +_layoutConfig.maxHeightOfBar - cord.coordinate.y;
    
    NSPredicate *predicateForNext =[NSPredicate predicateWithFormat:@"coordinate.x > %f", xPos];
    NSSortDescriptor *discriptorNe = [NSSortDescriptor sortDescriptorWithKey:@"coordinate.x" ascending:YES];
    GraphPlotObj *cordNext = [[[_plotArray filteredArrayUsingPredicate:predicateForNext] sortedArrayUsingDescriptors:@[discriptorNe]] firstObject];
    
    _nextCoord.x = cordNext.coordinate.x;
    _nextCoord.y = /*self.frame.size.height*0.9 -*/_layoutConfig.endingY +_layoutConfig.maxHeightOfBar - cordNext.coordinate.y;
    
    [_valueLabel setText:[NSString stringWithFormat:@"Value : %d", (int)cord.value]];
    
    _slope = (_nextCoord.y - _previousCoord.y)/(_nextCoord.x - _previousCoord.x);
}

#pragma  mark - Time calluculation based on movement of scroll buttton
//Get timer acc to x value
-(NSString *)getTimeWithXPosition:(float)xPos
{
    float time = ((xPos - _layoutConfig.startingX)/(self.contentSize.width - _layoutConfig.startingX)) * (TIME_INTERVAL*(((_maxX/TIME_INTERVAL) > MAX_X_AXIS_LABELS) ?_labelCount - 1 : _labelCount)) * 60;
    int timeInMin = (int)time / 60;
    int timeLeft = (int)time%60;
    int timeInHr = timeInMin /60;
    timeInMin = timeInMin % 60;
    return [NSString stringWithFormat:@"%d:%02d:%02d", timeInHr, timeInMin, timeLeft];
}

@end
