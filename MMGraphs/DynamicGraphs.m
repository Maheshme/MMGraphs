//
//  DynamicGraphs.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/29/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "DynamicGraphs.h"

#import "XAxisGraphLabel.h"
#import "GraphPlotObj.h"
#import "GraphModel.h"

#define MAX_X_AXIS_LABELS                               7
#define TIME_INTERVAL                                   5     //Minutes
#define X_AXIS_LABELS_FONT                              11
#define SEPERATOR_HEIGHT                                1
#define STARTING_Y                                      (self.frame.size.height*0.9)
#define ENDING_Y                                        (self.frame.size.height*0.1)
#define STARTING_X                                      (self.frame.size.width*0.0)
#define MAX_HEIGHT_OF_GRAPH                             (STARTING_Y - ENDING_Y)
#define LINE_CAP_ROUND                                  @"round"

@interface DynamicGraphs ()

@property (nonatomic, strong) UIBezierPath *graphPath;
@property (nonatomic, strong) CAShapeLayer *graphLayer;
@property (nonatomic, strong) CABasicAnimation *drawAnimation;
@property (nonatomic, strong) UIView *separator;

@property (nonatomic) float maxY, minX, maxX, rangeOfX,totalDistanceCovered, xUnit, latestLabel;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) BOOL isScrolling;
@property (nonatomic, strong) NSMutableArray *dynamicPlotArray;
@property (nonatomic) NSInteger typeOfGraph;


@end

@implementation DynamicGraphs

- (instancetype)initWithTypeOfGraph:(Graph_Type)typeOfGraph
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        _typeOfGraph = typeOfGraph;
        _dynamicPlotArray = [[NSMutableArray alloc]init];
        
        //Range of Y axis
        _maxY = 0;
        
        //Range of X axis
        _maxX = (MAX_X_AXIS_LABELS-1) * 5 * 60;
        _minX = 0;
        _rangeOfX = _maxX-_minX;
        
        _isScrolling = NO;
        
        _totalDistanceCovered = 0;
        
        [self allocateRequirments];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xUnit = ((self.frame.size.width - STARTING_X) / MAX_X_AXIS_LABELS)/TIME_INTERVAL;
    _separator.frame = CGRectMake(STARTING_X, STARTING_Y, (self.contentSize.width > self.frame.size.width) ? self.contentSize.width : self.frame.size.width, SEPERATOR_HEIGHT);
    _graphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    
    if (!_isScrolling)
    {
        NSArray *labelsArray = [[self subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.class == %@",[XAxisGraphLabel class]]];
        for (XAxisGraphLabel *xAxisLabel in labelsArray)
        {
            xAxisLabel.frame = CGRectMake((xAxisLabel.position*_xUnit*TIME_INTERVAL)+STARTING_X, STARTING_Y, _xUnit*TIME_INTERVAL, self.frame.size.height*0.14);
            if(xAxisLabel.position != 0)
                xAxisLabel.center = CGPointMake(xAxisLabel.position*_xUnit+STARTING_X, xAxisLabel.center.y);
            [self bringSubviewToFront:xAxisLabel];
        }
        self.contentSize = CGSizeMake((self.frame.size.width > self.contentSize.width) ? self.frame.size.width : self.contentSize.width, self.frame.size.height);
    }
}

-(void)drawRect:(CGRect)rect
{
    if (_typeOfGraph == Graph_Type_Line)
    {
        _graphLayer.lineWidth = 2;
        _graphPath.lineWidth = 2;
    }
    else
    {
        _graphLayer.lineWidth = _xUnit*0.9;
        _graphPath.lineWidth = _xUnit*0.9;
    }
    
    [self checkForRangeChanges];
}

//Allocate needs for grah
-(void)allocateRequirments
{
    //Seperator line view
    _separator = [[UIView alloc]init];
    _separator.backgroundColor = [UIColor blackColor];
    [self addSubview:_separator];
    
    //Time Label creation in x-axis
    for (int i = 0; i < MAX_X_AXIS_LABELS  ; i++)
        [self createLabelsWithLabelCount:i*TIME_INTERVAL];
    
    //Bezier path for ploting graph
    _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:10];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graph allocation
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = [[UIColor clearColor] CGColor];
    _graphLayer.geometryFlipped = YES;
    _graphLayer.strokeColor = COLOR(210.0, 211.0, 211.0, 1).CGColor;
    _graphLayer.lineWidth = 2;
    if (_typeOfGraph == Graph_Type_Line || _typeOfGraph == Graph_Type_Scatter)
    {
        _graphLayer.lineCap = LINE_CAP_ROUND;
        _graphLayer.lineJoin = LINE_CAP_ROUND;
    }
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    for (CALayer *layer in self.blurrView.layer.sublayers)
        if ([layer isEqual:_graphLayer])
            [layer removeFromSuperlayer];
    
    //Animation for drawing the path
    _drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _drawAnimation.duration = 0.5;
    _drawAnimation.repeatCount = 1.0;
    
    _lastPoint = CGPointMake(0, 0);
}

//Creating x-axis time labels
-(void)createLabelsWithLabelCount:(int)labelNumber
{
    XAxisGraphLabel *label = [[XAxisGraphLabel alloc]initWithText:[NSString stringWithFormat:@"%d",labelNumber] textAlignement:(labelNumber == 0) ? NSTextAlignmentLeft : NSTextAlignmentCenter andTextColor:[UIColor blackColor]];
    label.dotView.alpha = 1;
    label.position = labelNumber;
    [self addSubview:label];
    _latestLabel = labelNumber;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//Check of changes in limits i.e.., max and min Y
-(BOOL)checkForRangeChanges
{
    BOOL rangeChanged = NO;
    //Get maximum and minimum value and check with current
    float newYMax = [[_dynamicPlotArray valueForKeyPath:@"@max.value"] floatValue];
    
    if (newYMax > _maxY)
    {
        _maxY = newYMax;
        rangeChanged = YES;
    }
    
    return rangeChanged;
}

-(void)createDataWithPlotObj:(GraphPlotObj *)plotObj
{
    plotObj.position = (int)[_dynamicPlotArray count];
    
    [_dynamicPlotArray addObject:plotObj];
    
    [self updateGraph];
}

//Update graph on every start of new minute, triggered by timer
-(void)updateGraph
{
    if ([self checkForRangeChanges])
    {
        _lastPoint = CGPointMake(0, 0);
        _totalDistanceCovered = 0;
        
        //Remove complete plot
        [_graphPath removeAllPoints];

        //Complete plot. Called when complete plot is requried i.e.., when limits changes or on opening of graph for first time
        [self plotGraphWithArrayOfPlotPoints:_dynamicPlotArray];
    }
    else
    {
        //Last point to be ploted
        GraphPlotObj *plotObject = [_dynamicPlotArray lastObject];
        [self plotGraphWithArrayOfPlotPoints:@[plotObject]];
    }
}


-(void)plotGraphWithArrayOfPlotPoints:(NSArray *)arrayOfPlotPoints
{
    float animationStartPercentage = 0;
    for (GraphPlotObj *plotObject in arrayOfPlotPoints)
    {
        float timStamp = plotObject.position;
        
        CGPoint plotPoint = [self calculatePointwithXValue:plotObject.position andYvalue:plotObject.value];
        
        if (_typeOfGraph == Graph_Type_Line)
        {
            if (plotObject.position == 0)
                [_graphPath moveToPoint:plotPoint];
            else
                [_graphPath addLineToPoint:plotPoint];
            NSLog(@"plotObject : %f",plotObject.value);
        }
        else if(_typeOfGraph == Graph_Type_Scatter)
        {
            [_graphPath moveToPoint:plotPoint];
            [_graphPath addLineToPoint:plotPoint];
            NSLog(@"plotObject : %f",plotObject.value);
        }
        else if(_typeOfGraph == Graph_Type_Bar)
        {
            [_graphPath moveToPoint:CGPointMake(plotPoint.x, 0)];
            [_graphPath addLineToPoint:plotPoint];
            NSLog(@"plotObject : %f",plotObject.value);
        }
       
        
        //If plot exceeds content size
        if (plotPoint.x >= self.contentSize.width)
            [self increaseContentSizeForValue:timStamp];
        
        if (plotObject.position != 0)
        {
            float distanceCovered = sqrtf(powf((plotPoint.y-_lastPoint.y), 2) + powf((plotPoint.x-_lastPoint.x), 2));
            _totalDistanceCovered = _totalDistanceCovered + distanceCovered;
            if (arrayOfPlotPoints.count <= 1)
                animationStartPercentage = 1 - (distanceCovered/_totalDistanceCovered);
        }
        _lastPoint = plotPoint;
    }
    
    _graphLayer.path = [_graphPath CGPath];
    
    _drawAnimation.fromValue = [NSNumber numberWithFloat:animationStartPercentage];
    _drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    [_graphLayer addAnimation:_drawAnimation forKey:@"drawCircleAnimation"];
}


-(void)increaseContentSizeForValue:(float)xValue
{
    self.contentSize = CGSizeMake((xValue+TIME_INTERVAL)*_xUnit+STARTING_X, self.frame.size.height);
    [self setContentOffset:CGPointMake(self.contentSize.width - self.frame.size.width, 0) animated:YES];
    
    int missedLabels =  (((int)xValue - (int)_latestLabel)%5 == 0) ? ((xValue - _latestLabel)/5) : ((xValue - _latestLabel)/5)+1;
    for (int i = 0; i < missedLabels; i++)
        [self createLabelsWithLabelCount:_latestLabel+TIME_INTERVAL]; //call layout
}

//To calculate the x and y points based on X and Y axis length
-(CGPoint)calculatePointwithXValue:(float)xValue andYvalue:(float)yValue
{
    CGPoint pointInGraph;
    /**/float plotPercent = (yValue/_maxY);
    plotPercent = isnan(plotPercent) ? 1 : plotPercent;
    pointInGraph.y = (plotPercent*MAX_HEIGHT_OF_GRAPH);
    pointInGraph.x = (xValue * _xUnit) +  STARTING_X;
    
    if (_maxY == 0)
        pointInGraph.y = MAX_HEIGHT_OF_GRAPH;
    
    return pointInGraph;
}

@end
