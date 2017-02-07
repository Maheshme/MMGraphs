//
//  InteractiveBar.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "InteractiveBar.h"
#import "GraphPlotObj.h"
#import "XAxisGraphLabel.h"
#import "BubbleView.h"


@interface InteractiveBar ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *plotArray;
@property (nonatomic) float yMax;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic) BOOL isScrolling;

@property (nonatomic, strong) UIView *xAxisSeperator;
@property (nonatomic, strong) UIBezierPath *graphPath;
@property (nonatomic, strong) CAShapeLayer *graphLayer;
@property (nonatomic, strong) BubbleView *bubble;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CABasicAnimation *drawAnimation;

@property (nonatomic, strong) GraphConfig *layoutConfig;
@end

@implementation InteractiveBar

- (instancetype)initWithConfigData:(GraphConfig *)configData
{
    self = [super init];
    
    if (self)
    {
        [configData needCalluculator];
        
        _layoutConfig = configData;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        _plotArray = [NSArray arrayWithArray:configData.firstPlotAraay];
        _labelArray = [[NSMutableArray alloc]init];
        
        _isScrolling = NO;
        
        _yMax = [[configData.firstPlotAraay valueForKeyPath:@"@max.value"] floatValue];
        
        [self allocateRequirments];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _xAxisSeperator.frame = CGRectMake(_layoutConfig.startingX, _layoutConfig.startingY, (self.frame.size.width > self.contentSize.width)?self.frame.size.width:self.contentSize.width-_layoutConfig.startingX, 1);
    _graphLayer.frame = CGRectMake(0, _layoutConfig.endingY, self.frame.size.width, _layoutConfig.maxHeightOfBar);
    
    if(_bubble.frame.size.width <= 0)
        _bubble.frame = CGRectMake(_bubble.frame.origin.x, _bubble.frame.origin.y, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.12);
    
    _gradientLayer.frame = CGRectMake(0, _layoutConfig.endingY, self.contentSize.width, _layoutConfig.maxHeightOfBar);
    
    if(!_isScrolling && _layoutConfig.xAxisLabelsEnabled)
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
    
    if (_labelArray.count == 0 && _layoutConfig.xAxisLabelsEnabled)
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
    [_graphPath setLineWidth:_layoutConfig.totalBarWidth];
    [[UIColor blackColor] setStroke];
    
    //CAShapeLayer for graph
    _graphLayer = [CAShapeLayer layer];
    _graphLayer.fillColor = [[UIColor clearColor] CGColor];
    _graphLayer.strokeColor = COLOR(210.0, 211.0, 211.0, 1).CGColor;
    _graphLayer.geometryFlipped = YES;
    _graphLayer.lineWidth = _layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot;
    _graphLayer.path = [_graphPath CGPath];
    [self.layer addSublayer:_graphLayer];
    
    //Animation for drawing the path
    _drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _drawAnimation.duration = 3.0;
    _drawAnimation.repeatCount = 1.0;
    
    if (_layoutConfig.colorsArray != nil)
    {
        if(_layoutConfig.colorsArray.count == 1)
            _graphLayer.strokeColor = (__bridge CGColorRef _Nullable)[_layoutConfig.colorsArray firstObject];
        else
        {
            _gradientLayer = [CAGradientLayer layer];
            _gradientLayer.colors = _layoutConfig.colorsArray;
            _gradientLayer.startPoint = CGPointMake(0,0.0);
            _gradientLayer.endPoint = CGPointMake(0,1.0);
        }
    }
    
    [self.layer addSublayer:_gradientLayer];
}

//Alter heights for change in orientation
-(void)alterHeights
{
    _bubble.alpha = 0;
    
    for (GraphPlotObj *barData in _plotArray)
    {
        barData.barHeight = (_layoutConfig.maxHeightOfBar)*(barData.value/_yMax);
        barData.coordinate.x = (barData.position *_layoutConfig.totalBarWidth)+(_layoutConfig.totalBarWidth/2)+_layoutConfig.startingX;
        barData.coordinate.y = barData.barHeight;
    }
}

-(void)drawBarGraph
{
    _bubble.alpha = 0;
    [_graphPath removeAllPoints];
    _graphPath = nil;
    
    //Bezier path for ploting graph
    if (_graphPath == nil)
        _graphPath = [[UIBezierPath alloc]init];
    [_graphPath setLineWidth:_layoutConfig.totalBarWidth*_layoutConfig.percentageOfPlot];
    [[UIColor blackColor] setStroke];
    
    self.contentSize = CGSizeMake(_layoutConfig.totalBarWidth*_plotArray.count+_layoutConfig.startingX, self.frame.size.height);
    
    for (GraphPlotObj *barSource in _plotArray)
    {
        [_graphPath moveToPoint:CGPointMake(barSource.coordinate.x, 0)];
        [_graphPath addLineToPoint:CGPointMake(barSource.coordinate.x, barSource.coordinate.y)];
    }
    
    _graphLayer.path = [_graphPath CGPath];
    
    if(_layoutConfig.colorsArray.count > 1)
        _gradientLayer.mask = _graphLayer;
    
    _drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    _drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    [_graphLayer addAnimation:_drawAnimation forKey:@"drawCircleAnimation"];
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
    [self getValueWith:location];
}


//Get value for the touched point on Button
-(void)getValueWith:(CGPoint)touchPoint
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.position == %d", (int)((touchPoint.x-_layoutConfig.startingX)/_layoutConfig.totalBarWidth)];
    NSArray *resultArray = [_plotArray filteredArrayUsingPredicate:predicate];
    
    GraphPlotObj *result;
    
    if (resultArray.count > 0)
    {
        result = (GraphPlotObj *)[resultArray firstObject];
        //Display bubble if touch is on bar
        if ((touchPoint.y >= _layoutConfig.endingY+ (_layoutConfig.startingY - result.barHeight) && touchPoint.y < _layoutConfig.startingY) || result.value < 0)
        {
            if (result.value >= 0)//If values are positive
                [self createBubbleWithValueToBeDisplayed:result.value andCenter:CGPointMake((result.position*_layoutConfig.totalBarWidth)+_layoutConfig.totalBarWidth/2+_layoutConfig.startingX, _layoutConfig.endingY+ (_layoutConfig.startingY - result.barHeight))];
            else if(touchPoint.y >= _layoutConfig.startingY)//If values are negative
                [self createBubbleWithValueToBeDisplayed:result.value andCenter:CGPointMake((result.position*_layoutConfig.totalBarWidth)+_layoutConfig.totalBarWidth/2+_layoutConfig.startingX, _layoutConfig.startingY)];
            [self bringSubviewToFront:_bubble];
        }
        else //On touch of graph above bar height
            _bubble.alpha = 0;
    }
    else //On touch of graph above bar height
        _bubble.alpha = 0;
}

-(void)createBubbleWithValueToBeDisplayed:(float)value andCenter:(CGPoint)center
{
    if (_bubble == nil)
    {
        //BubbleView creation
        _bubble = [[BubbleView alloc]initWithGraphType:Graph_Type_Vertical];
        _bubble.userInteractionEnabled = NO;
        _bubble.mainView.backgroundColor = COLOR(238.0, 211.0, 105.0, 1);
        _bubble.indicationView.backgroundColor = COLOR(238.0, 211.0, 105.0, 1);
        [_bubble.valueLabel setTextColor: COLOR(8.0, 48.0, 69.0, 1)];
        [self addSubview:_bubble];
        
        _bubble.alpha = 0;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    //Updating date and value for bubble
    _bubble.valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
    CGSize size = [[NSString stringWithFormat:@"%d", (int)value] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:BUBBLE_VALUE_FONT_SIZE]}];
    
    //Animating the bubble positions
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _bubble.alpha = 1;
                         _bubble.frame = CGRectMake(_bubble.frame.origin.x, _bubble.frame.origin.y, size.width*1.5, _bubble.frame.size.height);
                         _bubble.indicationView.center =  CGPointMake((size.width*1.5)/2, _bubble.indicationView.center.y);
                         float newYCenter = center.y;
                         float newXcenter = center.x;
                         //Shifting indicator and bubble center (y) if bubble is going above grap
                         if (center.y-_bubble.frame.size.height <= 0)
                         {
                             newYCenter = center.y+_bubble.frame.size.height;
                             _bubble.mainView.center = CGPointMake(_bubble.frame.size.width/2, _bubble.mainView.frame.size.height/2+_bubble.indicationView.frame.size.height/2);
                             _bubble.indicationView.center = CGPointMake(_bubble.indicationView.center.x, 0);
                         }//Shifting indicator and bubble center (y) nor normal conditions
                         else if(_bubble.mainView.center.y != _bubble.mainView.frame.size.height/2)
                         {
                             _bubble.mainView.center = CGPointMake(_bubble.frame.size.width/2, _bubble.mainView.frame.size.height/2);
                             _bubble.indicationView.center = CGPointMake(_bubble.indicationView.center.x, _bubble.mainView.frame.size.height);
                         }
                         
                         //Shifting indicator and bubble center (x) if bubble is going to -x axis
                         if (center.x - _bubble.frame.size.width/2 <= 0)
                         {
                             _bubble.indicationView.center = CGPointMake(_bubble.frame.size.width*0.25, _bubble.indicationView.center.y);
                             newXcenter = newXcenter + _bubble.frame.size.width*0.25;
                         }//Shifting indicator and bubble center (x) if bubble is going beyond width of graph
                         else if (center.x + _bubble.frame.size.width/2 >=  self.contentSize.width)
                         {
                             _bubble.indicationView.center = CGPointMake(_bubble.frame.size.width*0.75, _bubble.indicationView.center.y);
                             newXcenter = newXcenter - _bubble.frame.size.width*0.25;
                         }//Shifting indicator and bubble center (x) if bubble for normal conditions
                         else if(_bubble.indicationView.center.x != _bubble.frame.size.width*0.5)
                             _bubble.indicationView.center = CGPointMake(_bubble.frame.size.width*0.5, _bubble.indicationView.center.y);
                         
                         _bubble.center = CGPointMake(newXcenter, newYCenter-_bubble.frame.size.height/2);
                         _bubble.alpha = 1;
                     } completion:^(BOOL finished) {
                     }];
}

@end
