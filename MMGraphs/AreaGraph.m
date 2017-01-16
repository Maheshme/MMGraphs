//
//  AreaGraph.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/29/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "AreaGraph.h"
#import "GraphPlotObj.h"
#import "XAxisGraphLabel.h"

#define STARTING_Y                      self.frame.size.height*0.9
#define ENDING_Y                        11.0
#define STARTING_X                      self.frame.size.width*0
#define MAX_HEIGHT_OF_BAR               (STARTING_Y - ENDING_Y)
#define BAR_WIDTH                       2.0
#define SPACING                         40.0
#define TOTAL_BAR_WIDTH                 (BAR_WIDTH + SPACING)
#define PERCENTAGE_OF_BAR               (BAR_WIDTH/TOTAL_BAR_WIDTH)

@interface AreaGraph ()

@property (nonatomic, strong) NSArray *plotArray, *secondPlotArray, *thirdPlotArray;
@property (nonatomic) float yMax;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic) BOOL isScrolling;

@property (nonatomic, strong) UIView *xAxisSeperator;
@property (nonatomic, strong) UIBezierPath *graphPath, *graphPath2, *graphPath3;
@property (nonatomic, strong) CAShapeLayer *graphLayer, *graphLayer2, *graphLayer3;
@property (nonatomic, strong) CAGradientLayer *gradientLayer, *gradientLayer2, *gradientLayer3;

@end

@implementation AreaGraph

- (instancetype)initWithPlotArray:(NSArray *)plotArray withecondPlotArray:(NSArray *)secondPlotArray andThirdPlotArray:(NSArray *)thirdPlotArray
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.bounces  = NO;
        
        //Plot array of three diff area graphs
        _plotArray = [NSArray arrayWithArray:plotArray];
        _secondPlotArray = [NSArray arrayWithArray:secondPlotArray];
        _thirdPlotArray = [NSArray arrayWithArray:thirdPlotArray];
        
        _labelArray = [[NSMutableArray alloc]init];
        _isScrolling = NO;
        
        //Finding max of all area graphs as this graph is plotted 0 - max
        _yMax = [[plotArray valueForKeyPath:@"@max.value"] floatValue] > [[secondPlotArray valueForKeyPath:@"@max.value"] floatValue] ? [[plotArray valueForKeyPath:@"@max.value"] floatValue] : [[secondPlotArray valueForKeyPath:@"@max.value"] floatValue];
        
        _yMax = _yMax > [[thirdPlotArray valueForKeyPath:@"@max.value"] floatValue] ? _yMax : [[thirdPlotArray valueForKeyPath:@"@max.value"] floatValue];
        
        [self allocateRequirments];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xAxisSeperator.frame = CGRectMake(STARTING_X, STARTING_Y, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width, 1);
    _graphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    _graphLayer2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    _graphLayer2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.9);
    
    _gradientLayer.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height*0.9);
    _gradientLayer2.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height*0.9);
    _gradientLayer3.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height*0.9);
    
    if(!_isScrolling)
        for (XAxisGraphLabel *xAxisxLabel in _labelArray)
        {
            xAxisxLabel.frame = CGRectMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, STARTING_Y, SCREEN_WIDTH*0.2, self.frame.size.height*0.1);
            xAxisxLabel.center = CGPointMake((xAxisxLabel.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2+STARTING_X, STARTING_Y+xAxisxLabel.frame.size.height/2);
            [self bringSubviewToFront:xAxisxLabel];
        }
}

-(void)drawRect:(CGRect)rect
{
    [self alterHeights];
    _graphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    
    if (_labelArray.count == 0)
        [self labelCreation];
    
    [self drawAreaGraph];
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
    
    //Bezier path for ploting graph
    _graphPath2 = [[UIBezierPath alloc]init];
    [_graphPath2 setLineWidth:TOTAL_BAR_WIDTH];
    [[UIColor blackColor] setStroke];
    
    //Bezier path for ploting graph
    _graphPath3 = [[UIBezierPath alloc]init];
    [_graphPath3 setLineWidth:TOTAL_BAR_WIDTH];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graphs
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = COLOR(211.0, 104.0, 41.0, 1).CGColor;
    _graphLayer.strokeColor = COLOR(211.0, 104.0, 41.0, 1).CGColor;
    _graphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    _graphLayer2 = [CAShapeLayer layer];
    _graphLayer2.fillColor = COLOR(73.0, 209.0, 225.0, 1).CGColor;
    _graphLayer2.strokeColor = COLOR(73.0, 209.0, 225.0, 1).CGColor;
    _graphLayer2.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _graphLayer2.path = [_graphPath2 CGPath];
    [self.layer addSublayer:_graphLayer2];
    
    _graphLayer3 = [CAShapeLayer layer];
    _graphLayer3.fillColor = COLOR(224.0, 49.0, 113.0, 1).CGColor;
    _graphLayer3.strokeColor = COLOR(224.0, 49.0, 113.0, 1).CGColor;
    _graphLayer3.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _graphLayer3.path = [_graphPath3 CGPath];
    [self.layer addSublayer:_graphLayer3];
    
    //Gradients for different graphs
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[(__bridge id)COLOR(211.0, 104.0, 41.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer.startPoint = CGPointMake(0, 1-[[_plotArray valueForKeyPath:@"@max.value"] floatValue]/100);
    _gradientLayer.endPoint = CGPointMake(0,1 - [[_plotArray valueForKeyPath:@"@min.value"] floatValue]/100+0.1);
    [self.layer addSublayer:_gradientLayer];
    
    _gradientLayer2 = [CAGradientLayer layer];
    _gradientLayer2.colors = @[(__bridge id)COLOR(73.0, 209.0, 225.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer2.startPoint = CGPointMake(0, 1-[[_secondPlotArray valueForKeyPath:@"@max.value"] floatValue]/100);
    _gradientLayer2.endPoint = CGPointMake(0,1 - [[_secondPlotArray valueForKeyPath:@"@min.value"] floatValue]/100+0.1);
    [self.layer addSublayer:_gradientLayer2];
    
    _gradientLayer3 = [CAGradientLayer layer];
    _gradientLayer3.colors = @[(__bridge id)COLOR(224.0, 49.0, 113.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer3.startPoint = CGPointMake(0, 1-[[_thirdPlotArray valueForKeyPath:@"@max.value"] floatValue]/100);
    _gradientLayer3.endPoint = CGPointMake(0,1 - [[_thirdPlotArray valueForKeyPath:@"@min.value"] floatValue]/100+0.1);
    [self.layer addSublayer:_gradientLayer3];
    
}

//Alter heights for change in orientation
-(void)alterHeights
{
    /*Here we are giving a gap ENDING_Y from origin. So for calluculated height of the bar we add ENDING_Y, because we plot in inverce compared to coordinate geometry.*/
    for (GraphPlotObj *barData in _plotArray)
    {
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
        barData.coordinate.x = (barData.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X;
        barData.coordinate.y = barData.barHeight;
    }
    
    for (GraphPlotObj *barData in _secondPlotArray)
    {
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
        barData.coordinate.x = (barData.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X;
        barData.coordinate.y = barData.barHeight;
    }
    
    for (GraphPlotObj *barData in _thirdPlotArray)
    {
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
        barData.coordinate.x = (barData.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X;
        barData.coordinate.y = barData.barHeight;
    }

}

//Plot Graph
-(void)drawAreaGraph
{
    [_graphPath removeAllPoints];
    _graphPath = nil;
    
    [_graphPath2 removeAllPoints];
    _graphPath2 = nil;
    
    [_graphPath3 removeAllPoints];
    _graphPath3 = nil;
    
    //Bezier path for ploting graph
    _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    
    _graphPath2 = [[UIBezierPath alloc]init];
    [_graphPath2 setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    
    _graphPath3 = [[UIBezierPath alloc]init];
    [_graphPath3 setLineWidth:TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR];
    
    //Content size of scroll view based on number plot Array count
    int maxXCount = (_plotArray.count > _secondPlotArray.count) ? (int)_plotArray.count : (int)_secondPlotArray.count;
    maxXCount = (maxXCount > _thirdPlotArray.count) ? maxXCount : (int)_thirdPlotArray.count;
    self.contentSize = CGSizeMake(TOTAL_BAR_WIDTH*maxXCount, self.frame.size.height);
    
    [_graphPath moveToPoint:CGPointMake(STARTING_X - TOTAL_BAR_WIDTH, STARTING_Y)];
    
    for (GraphPlotObj *barSource in _plotArray)
        [_graphPath addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-TOTAL_BAR_WIDTH*0.5, barSource.coordinate.y)];
        
    [_graphPath addCurveToPoint:CGPointMake(self.contentSize.width+TOTAL_BAR_WIDTH, STARTING_Y) controlPoint1:CGPointMake(_graphPath.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-TOTAL_BAR_WIDTH*0.5, STARTING_Y)];
    
    [_graphPath2 moveToPoint:CGPointMake(STARTING_X - TOTAL_BAR_WIDTH, STARTING_Y)];
    
    for (GraphPlotObj *barSource in _secondPlotArray)
        [_graphPath2 addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-TOTAL_BAR_WIDTH*0.5, barSource.coordinate.y)];
    
    [_graphPath2 addCurveToPoint:CGPointMake(self.contentSize.width+TOTAL_BAR_WIDTH, STARTING_Y) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-TOTAL_BAR_WIDTH*0.5, STARTING_Y)];
    
    [_graphPath3 moveToPoint:CGPointMake(STARTING_X - TOTAL_BAR_WIDTH, STARTING_Y)];
    
    for (GraphPlotObj *barSource in _thirdPlotArray)
        [_graphPath3 addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath3.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath3.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-TOTAL_BAR_WIDTH*0.5, barSource.coordinate.y)];
    
    [_graphPath3 addCurveToPoint:CGPointMake(self.contentSize.width+TOTAL_BAR_WIDTH, STARTING_Y) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+TOTAL_BAR_WIDTH*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-TOTAL_BAR_WIDTH*0.5, STARTING_Y)];
    
    _graphLayer.path = [_graphPath CGPath];
    _graphLayer2.path = [_graphPath2 CGPath];
    _graphLayer3.path = [_graphPath3 CGPath];
    
    _gradientLayer.mask = _graphLayer;
    _gradientLayer2.mask = _graphLayer2;
    _gradientLayer3.mask = _graphLayer3;
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


@end
