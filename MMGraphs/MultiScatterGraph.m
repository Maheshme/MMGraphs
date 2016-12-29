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
    _firstGraphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _secondGraphLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
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
    _firstGraphLayer.path = [_firstGraphPath CGPath];
    [self.layer addSublayer:_firstGraphLayer];
    
    //CAShapeLayer for graph
    _secondGraphLayer = [CAShapeLayer layer];
    _secondGraphLayer.fillColor = [[UIColor clearColor] CGColor];
    _secondGraphLayer.strokeColor = COLOR(255.0, 215.0, 71.0, 1).CGColor;
    _secondGraphLayer.lineWidth = TOTAL_BAR_WIDTH*PERCENTAGE_OF_BAR;
    _secondGraphLayer.lineCap = @"round";
    _secondGraphLayer.lineJoin = @"round";
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
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
    
    for (GraphPlotObj *barData in _secondPlotArray)
        barData.barHeight = (MAX_HEIGHT_OF_BAR)*(1 - barData.value/_yMax) + ENDING_Y;
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
        [_firstGraphPath moveToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
        [_firstGraphPath addLineToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
    }
    
    for (GraphPlotObj *barSource in _secondPlotArray)
    {
        [_secondGraphPath moveToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
        [_secondGraphPath addLineToPoint:CGPointMake((barSource.position *TOTAL_BAR_WIDTH)+(TOTAL_BAR_WIDTH/2)+STARTING_X, barSource.barHeight)];
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

//Getting point when user touches graph
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint location = [touch locationInView:self];
//    [self getValueWith:location];
}
//Get value for the touched point on Button
-(void)getValueWith:(CGPoint)touchPoint
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.position == %d", (int)(touchPoint.x/TOTAL_BAR_WIDTH)];
    NSArray *firstResultArray = [_firstPlotArray filteredArrayUsingPredicate:predicate];
    NSArray *secondResultArray = [_secondPlotArray filteredArrayUsingPredicate:predicate];
    
    GraphPlotObj *firstResult, *secondResult;
    
    if((firstResultArray.count > 0)&& (secondResultArray.count > 0))
    {
        firstResult = (GraphPlotObj *)[firstResultArray firstObject];
        secondResult = (GraphPlotObj *)[secondResultArray firstObject];
        //Display bubble if touch is in between symmetry graph
        if ((touchPoint.y >= firstResult.barHeight && touchPoint.y <= secondResult.barHeight) || (touchPoint.y >= firstResult.barHeight && secondResult == nil) || (touchPoint.y <= secondResult.barHeight && firstResult == nil))
        {
            if (firstResult.value >= 0)//If values are positive
                [self createFirstBubbleWithValueToBeDisplayed:firstResult.value andCenter:CGPointMake((firstResult.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, firstResult.barHeight)];
            else
                [self createFirstBubbleWithValueToBeDisplayed:firstResult.value andCenter:CGPointMake((firstResult.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, STARTING_Y)];
            
            if (secondResult.value >= 0)//If values are positive
                [self createSecondBubbleWithValueToBeDisplayed:secondResult.value andCenter:CGPointMake((secondResult.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, secondResult.barHeight)];
            else
                [self createSecondBubbleWithValueToBeDisplayed:secondResult.value andCenter:CGPointMake((secondResult.position*TOTAL_BAR_WIDTH)+TOTAL_BAR_WIDTH/2, STARTING_Y)];
        }
        else
            [self removeBubble];
    }
    else
        [self removeBubble];
}

-(void)removeBubble
{
    _firstGraphBubble.alpha = 0;
    _secondGraphBubble.alpha = 0;
}
-(void)allocateBubble
{
    //BubbleView creation
    _firstGraphBubble = [[BubbleView alloc]initWithGraphType:Graph_Type_Vertical];
    _firstGraphBubble.userInteractionEnabled = NO;
    [self addSubview:_firstGraphBubble];
    
    _secondGraphBubble = [[BubbleView alloc]initWithGraphType:Graph_Type_Vertical];
    _secondGraphBubble.userInteractionEnabled = NO;
    [self addSubview:_secondGraphBubble];
    
    _firstGraphBubble.mainView.backgroundColor = COLOR(160.0, 85.0, 89.0, 1);
    _firstGraphBubble.indicationView.backgroundColor = COLOR(160.0, 85.0, 89.0, 1);;
    _secondGraphBubble.mainView.backgroundColor = COLOR(160.0, 85.0, 89.0, 1);;
    _secondGraphBubble.indicationView.backgroundColor = COLOR(160.0, 85.0, 89.0, 1);;
    
    _firstGraphBubble.alpha = 0;
    _secondGraphBubble.alpha = 0;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)createFirstBubbleWithValueToBeDisplayed:(float)value andCenter:(CGPoint)center
{
    //BubbleView creation
    if (_firstGraphBubble == nil)
        [self allocateBubble];
    
    _firstGraphBubble.valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
    CGSize size = [[NSString stringWithFormat:@"%d", (int)value] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    //Animating the bubble positions
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _firstGraphBubble.alpha = 1;
                         _firstGraphBubble.frame = CGRectMake(_firstGraphBubble.frame.origin.x, _firstGraphBubble.frame.origin.y, size.width*1.5, _firstGraphBubble.frame.size.height);
                         _firstGraphBubble.indicationView.center =  CGPointMake((size.width*1.5)/2, _firstGraphBubble.indicationView.center.y);
                         
                         float newYCenter = center.y;
                         float newXcenter = center.x;
                         //Shifting indicator and bubble center (y) if bubble is going above grap
                         if (center.y-_firstGraphBubble.frame.size.height <= 0)
                         {
                             newYCenter = center.y+_firstGraphBubble.frame.size.height;
                             _firstGraphBubble.mainView.center = CGPointMake(_firstGraphBubble.frame.size.width/2, _firstGraphBubble.mainView.frame.size.height/2+_firstGraphBubble.indicationView.frame.size.height/2);
                             _firstGraphBubble.indicationView.center = CGPointMake(_firstGraphBubble.indicationView.center.x, 0);
                         }//Shifting indicator and bubble center (y) nor normal conditions
                         else if(_firstGraphBubble.mainView.center.y != _firstGraphBubble.mainView.frame.size.height/2)
                         {
                             _firstGraphBubble.mainView.center = CGPointMake(_firstGraphBubble.frame.size.width/2, _firstGraphBubble.mainView.frame.size.height/2);
                             _firstGraphBubble.indicationView.center = CGPointMake(_firstGraphBubble.indicationView.center.x, _firstGraphBubble.mainView.frame.size.height);
                         }
                         
                         //Shifting indicator and bubble center (x) if bubble is going to -x axis
                         if (center.x - _firstGraphBubble.frame.size.width/2 <= 0)
                         {
                             _firstGraphBubble.indicationView.center = CGPointMake(_firstGraphBubble.frame.size.width*0.25, _firstGraphBubble.indicationView.center.y);
                             newXcenter = newXcenter + _firstGraphBubble.frame.size.width*0.25;
                         }//Shifting indicator and bubble center (x) if bubble is going beyond width of graph
                         else if (center.x + _firstGraphBubble.frame.size.width/2 >= self.contentSize.width)
                         {
                             _firstGraphBubble.indicationView.center = CGPointMake(_firstGraphBubble.frame.size.width*0.75, _firstGraphBubble.indicationView.center.y);
                             newXcenter = newXcenter - _firstGraphBubble.frame.size.width*0.25;
                         }//Shifting indicator and bubble center (x) if bubble for normal conditions
                         else if(_firstGraphBubble.indicationView.center.x != _firstGraphBubble.frame.size.width*0.5)
                         {
                             _firstGraphBubble.indicationView.center = CGPointMake(_firstGraphBubble.frame.size.width*0.5, _firstGraphBubble.indicationView.center.y);
                         }
                         
                         _firstGraphBubble.center = CGPointMake(newXcenter, newYCenter-_firstGraphBubble.frame.size.height/2);
                         _firstGraphBubble.alpha = 1;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)createSecondBubbleWithValueToBeDisplayed:(float)value andCenter:(CGPoint)center
{
    //Updating date and value for bubble
    _secondGraphBubble.valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
    CGSize size = [[NSString stringWithFormat:@"%d", (int)value] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    //Animating the bubble positions
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         _secondGraphBubble.alpha = 1;
         
         _secondGraphBubble.frame = CGRectMake(_secondGraphBubble.frame.origin.x, _secondGraphBubble.frame.origin.y, size.width*1.5, _secondGraphBubble.frame.size.height);
         _secondGraphBubble.indicationView.center =  CGPointMake((size.width*1.5)/2, _secondGraphBubble.indicationView.center.y);
         float newYCenter = center.y;
         float newXcenter = center.x;
         
         //Shifting indicator and bubble center (y) if bubble is going above grap
         if (center.y+_secondGraphBubble.frame.size.height < (self.frame.size.height*0.9))
         {
             newYCenter = center.y+_secondGraphBubble.frame.size.height;
             _secondGraphBubble.mainView.center = CGPointMake(_secondGraphBubble.frame.size.width/2, _secondGraphBubble.mainView.frame.size.height/2+_secondGraphBubble.indicationView.frame.size.height/2);
             _secondGraphBubble.indicationView.center = CGPointMake(_secondGraphBubble.indicationView.center.x, 0);
         }//Shifting indicator and bubble center (y) nor normal conditions
         else if(_secondGraphBubble.mainView.center.y != _secondGraphBubble.mainView.frame.size.height/2)
         {
             _secondGraphBubble.mainView.center = CGPointMake(_secondGraphBubble.frame.size.width/2, _secondGraphBubble.mainView.frame.size.height/2);
             _secondGraphBubble.indicationView.center = CGPointMake(_secondGraphBubble.indicationView.center.x, _secondGraphBubble.mainView.frame.size.height);
         }
         
         //Shifting indicator and bubble center (x) if bubble is going to -x axis
         if (center.x - _secondGraphBubble.frame.size.width/2 <= 0)
         {
             _secondGraphBubble.indicationView.center = CGPointMake(_secondGraphBubble.frame.size.width*0.25, _secondGraphBubble.indicationView.center.y);
             newXcenter = newXcenter + _secondGraphBubble.frame.size.width*0.25;
         }//Shifting indicator and bubble center (x) if bubble is going beyond width of graph
         else if (center.x + _secondGraphBubble.frame.size.width/2 >= self.contentSize.width)
         {
             _secondGraphBubble.indicationView.center = CGPointMake(_secondGraphBubble.frame.size.width*0.75, _secondGraphBubble.indicationView.center.y);
             newXcenter = newXcenter - _secondGraphBubble.frame.size.width*0.25;
         }//Shifting indicator and bubble center (x) if bubble for normal conditions
         else if(_secondGraphBubble.indicationView.center.x != _secondGraphBubble.frame.size.width*0.5)
         {
             _secondGraphBubble.indicationView.center = CGPointMake(_secondGraphBubble.frame.size.width*0.5, _secondGraphBubble.indicationView.center.y);
         }
         
         _secondGraphBubble.center = CGPointMake(newXcenter, newYCenter-_secondGraphBubble.frame.size.height/2);
         _secondGraphBubble.alpha = 1;
     } completion:^(BOOL finished) {
         
     }];
}
@end
