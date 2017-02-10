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

@interface AreaGraph ()<UIScrollViewDelegate>

@property (nonatomic) float yMax, firstMax, secondMax, thirdMax;;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic) BOOL isScrolling;

@property (nonatomic, strong) UIView *xAxisSeperator;
@property (nonatomic, strong) UIBezierPath *graphPath, *graphPath2, *graphPath3;
@property (nonatomic, strong) CAShapeLayer *graphLayer, *graphLayer2, *graphLayer3;
@property (nonatomic, strong) CAGradientLayer *gradientLayer, *gradientLayer2, *gradientLayer3;

@property (nonatomic, strong) GraphConfig *layoutConfig;

@end

@implementation AreaGraph

- (instancetype)initWithConfigData:(GraphConfig *)configData
{
    self = [super init];
    if (self)
    {
        [configData needCalluculator];
        _layoutConfig = configData;
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.bounces  = NO;
                
        _labelArray = [[NSMutableArray alloc]init];
        _isScrolling = NO;
        
        //Finding max of all area graphs as this graph is plotted 0 - max
        _firstMax = [[_layoutConfig.firstPlotAraay valueForKeyPath:@"@max.value"] floatValue];
        _secondMax = [[_layoutConfig.secondPlotArray valueForKeyPath:@"@max.value"] floatValue];
        _thirdMax = [[_layoutConfig.thirdPlotArray valueForKeyPath:@"@max.value"] floatValue];
        
        _yMax = _firstMax > _secondMax ? _firstMax : _secondMax;
        _yMax = _yMax > _thirdMax ? _yMax : _thirdMax;
        
        [self allocateRequirments];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xAxisSeperator.frame = CGRectMake(_layoutConfig.startingX, _layoutConfig.startingY, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width, 1);
    _graphLayer.frame = CGRectMake(0, _layoutConfig.endingY, self.frame.size.width, _layoutConfig.maxHeightOfBar);
    _graphLayer2.frame = CGRectMake(0, _layoutConfig.endingY, self.frame.size.width, _layoutConfig.maxHeightOfBar);
    _graphLayer2.frame = CGRectMake(0, _layoutConfig.endingY, self.frame.size.width, _layoutConfig.maxHeightOfBar);
    
    _gradientLayer.frame = CGRectMake(0, _layoutConfig.endingY, self.contentSize.width, _layoutConfig.maxHeightOfBar);
    _gradientLayer2.frame = CGRectMake(0, _layoutConfig.endingY, self.contentSize.width, _layoutConfig.maxHeightOfBar);
    _gradientLayer3.frame = CGRectMake(0, _layoutConfig.endingY, self.contentSize.width, _layoutConfig.maxHeightOfBar);
    
    if(!_isScrolling)
        for (XAxisGraphLabel *xAxisxLabel in _labelArray)
        {
            xAxisxLabel.frame = CGRectMake((xAxisxLabel.position*_layoutConfig.totalBarWidth)+_layoutConfig.totalBarWidth/2+_layoutConfig.startingX, _layoutConfig.startingY, SCREEN_WIDTH*0.2, self.frame.size.height*0.1);
            xAxisxLabel.center = CGPointMake((xAxisxLabel.position*_layoutConfig.totalBarWidth)+_layoutConfig.totalBarWidth/2+_layoutConfig.startingX, _layoutConfig.startingY+xAxisxLabel.frame.size.height/2);
            [self bringSubviewToFront:xAxisxLabel];
        }
}

-(void)drawRect:(CGRect)rect
{
    [self alterHeights];
    _graphLayer.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer2.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer3.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
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
    [_graphPath setLineWidth:_layoutConfig.totalBarWidth];
    [[UIColor blackColor] setStroke];
    
    //Bezier path for ploting graph
    _graphPath2 = [[UIBezierPath alloc]init];
    [_graphPath2 setLineWidth:_layoutConfig.totalBarWidth];
    [[UIColor blackColor] setStroke];
    
    //Bezier path for ploting graph
    _graphPath3 = [[UIBezierPath alloc]init];
    [_graphPath3 setLineWidth:_layoutConfig.totalBarWidth];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graphs
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = COLOR(211.0, 104.0, 41.0, 1).CGColor;
    _graphLayer.strokeColor = COLOR(211.0, 104.0, 41.0, 1).CGColor;
    _graphLayer.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    _graphLayer2 = [CAShapeLayer layer];
    _graphLayer2.fillColor = COLOR(73.0, 209.0, 225.0, 1).CGColor;
    _graphLayer2.strokeColor = COLOR(73.0, 209.0, 225.0, 1).CGColor;
    _graphLayer2.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer2.path = [_graphPath2 CGPath];
    [self.layer addSublayer:_graphLayer2];
    
    _graphLayer3 = [CAShapeLayer layer];
    _graphLayer3.fillColor = COLOR(224.0, 49.0, 113.0, 1).CGColor;
    _graphLayer3.strokeColor = COLOR(224.0, 49.0, 113.0, 1).CGColor;
    _graphLayer3.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer3.path = [_graphPath3 CGPath];
    [self.layer addSublayer:_graphLayer3];
    
    //Gradients for different graphs
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[(__bridge id)COLOR(211.0, 104.0, 41.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer.startPoint = CGPointMake(0, (_yMax -_firstMax)/_yMax);
    _gradientLayer.endPoint = CGPointMake(0,(_yMax - [[_layoutConfig.firstPlotAraay valueForKeyPath:@"@min.value"] floatValue])/_yMax+0.1);
    [self.layer addSublayer:_gradientLayer];
    
    _gradientLayer2 = [CAGradientLayer layer];
    _gradientLayer2.colors = @[(__bridge id)COLOR(73.0, 209.0, 225.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer2.startPoint = CGPointMake(0, (_yMax -_secondMax)/_yMax);
    _gradientLayer2.endPoint = CGPointMake(0,(_yMax - [[_layoutConfig.secondPlotArray valueForKeyPath:@"@min.value"] floatValue])/_yMax+0.1);
    [self.layer addSublayer:_gradientLayer2];
    
    _gradientLayer3 = [CAGradientLayer layer];
    _gradientLayer3.colors = @[(__bridge id)COLOR(224.0, 49.0, 113.0, 1).CGColor, (__bridge id)[UIColor clearColor].CGColor ];
    _gradientLayer3.startPoint = CGPointMake(0, (_yMax - _thirdMax)/_yMax);
    _gradientLayer3.endPoint = CGPointMake(0,(_yMax - [[_layoutConfig.thirdPlotArray valueForKeyPath:@"@min.value"] floatValue])/_yMax+0.1);
    [self.layer addSublayer:_gradientLayer3];
    
}

//Alter heights for change in orientation
-(void)alterHeights
{
    /*Here we are giving a gap ENDING_Y from origin. So for calluculated height of the bar we add ENDING_Y, because we plot in inverce compared to coordinate geometry.*/
    for (GraphPlotObj *barData in _layoutConfig.firstPlotAraay)
    {
        barData.barHeight = (_layoutConfig.maxHeightOfBar)*(1 - barData.value/_yMax) + _layoutConfig.endingY;
        barData.coordinate.x = (barData.position *_layoutConfig.totalBarWidth)+(_layoutConfig.totalBarWidth/2)+_layoutConfig.startingX;
        barData.coordinate.y = barData.barHeight;
    }
    
    for (GraphPlotObj *barData in _layoutConfig.secondPlotArray)
    {
        barData.barHeight = (_layoutConfig.maxHeightOfBar)*(1 - barData.value/_yMax) + _layoutConfig.endingY;
        barData.coordinate.x = (barData.position *_layoutConfig.totalBarWidth)+(_layoutConfig.totalBarWidth/2)+_layoutConfig.startingX;
        barData.coordinate.y = barData.barHeight;
    }
    
    for (GraphPlotObj *barData in _layoutConfig.thirdPlotArray)
    {
        barData.barHeight = (_layoutConfig.maxHeightOfBar)*(1 - barData.value/_yMax) + _layoutConfig.endingY;
        barData.coordinate.x = (barData.position *_layoutConfig.totalBarWidth)+(_layoutConfig.totalBarWidth/2)+_layoutConfig.startingX;
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
    [_graphPath setLineWidth:_layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot];
    
    _graphPath2 = [[UIBezierPath alloc]init];
    [_graphPath2 setLineWidth:_layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot];
    
    _graphPath3 = [[UIBezierPath alloc]init];
    [_graphPath3 setLineWidth:_layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot];
    
    //Content size of scroll view based on number plot Array count
    int maxXCount = (_layoutConfig.firstPlotAraay.count > _layoutConfig.secondPlotArray.count) ? (int)_layoutConfig.firstPlotAraay.count : (int)_layoutConfig.secondPlotArray.count;
    maxXCount = (maxXCount > _layoutConfig.thirdPlotArray.count) ? maxXCount : (int)_layoutConfig.thirdPlotArray.count;
    self.contentSize = CGSizeMake(_layoutConfig.totalBarWidth*maxXCount+_layoutConfig.startingX, self.frame.size.height);
    
    [_graphPath moveToPoint:CGPointMake(_layoutConfig.startingX , _layoutConfig.startingY)];
    
    for (GraphPlotObj *barSource in _layoutConfig.firstPlotAraay)
        [_graphPath addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-_layoutConfig.totalBarWidth*0.5, barSource.coordinate.y)];
        
    [_graphPath addCurveToPoint:CGPointMake(self.contentSize.width+_layoutConfig.totalBarWidth, _layoutConfig.startingY) controlPoint1:CGPointMake(_graphPath.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-_layoutConfig.totalBarWidth*0.5, _layoutConfig.startingY)];
    
    [_graphPath2 moveToPoint:CGPointMake(_layoutConfig.startingX , _layoutConfig.startingY)];
    
    for (GraphPlotObj *barSource in _layoutConfig.secondPlotArray)
        [_graphPath2 addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-_layoutConfig.totalBarWidth*0.5, barSource.coordinate.y)];
    
    [_graphPath2 addCurveToPoint:CGPointMake(self.contentSize.width+_layoutConfig.totalBarWidth, _layoutConfig.startingY) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-_layoutConfig.totalBarWidth*0.5, _layoutConfig.startingY)];
    
    [_graphPath3 moveToPoint:CGPointMake(_layoutConfig.startingX , _layoutConfig.startingY)];
    
    for (GraphPlotObj *barSource in _layoutConfig.thirdPlotArray)
        [_graphPath3 addCurveToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y) controlPoint1:CGPointMake(_graphPath3.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath3.currentPoint.y) controlPoint2:CGPointMake(barSource.coordinate.x-_layoutConfig.totalBarWidth*0.5, barSource.coordinate.y)];
    
    [_graphPath3 addCurveToPoint:CGPointMake(self.contentSize.width+_layoutConfig.totalBarWidth, _layoutConfig.startingY) controlPoint1:CGPointMake(_graphPath2.currentPoint.x+_layoutConfig.totalBarWidth*0.5, _graphPath2.currentPoint.y) controlPoint2:CGPointMake(self.contentSize.width-_layoutConfig.totalBarWidth*0.5, _layoutConfig.startingY)];
    
    _graphLayer.path = [_graphPath CGPath];
    _graphLayer2.path = [_graphPath2 CGPath];
    _graphLayer3.path = [_graphPath3 CGPath];
    
    _gradientLayer.mask = _graphLayer;
    _gradientLayer2.mask = _graphLayer2;
    _gradientLayer3.mask = _graphLayer3;
}

-(void)labelCreation
{
    for (GraphPlotObj *barSource in _layoutConfig.firstPlotAraay)
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
