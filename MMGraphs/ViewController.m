//
//  ViewController.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/20/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "ViewController.h"
#import "MenuView.h"
#import "GraphModel.h"

#import "InteractiveBar.h"
#import "HorizantalGraph.h"
#import "SymmetryBarGraph.h"
#import "ScatterPlotGraph.h"
#import "MultiScatterGraph.h"
#import "InteractiveLineGraph.h"
#import "AreaGraph.h"
#import "DynamicGraphs.h"
#import "GraphConfig.h"

#define INTERACTIVE_LINE_GRAPH              @"Interactive Line"
#define INTERACTIVE_BAR_GRAPH               @"Interactive Bar"
#define INTERACTIVE_HORIZANTAL_BAR_GRAPH    @"Interactive Horizontal bar"
#define INTERACTIVE_SYMMETRY_GRAPH          @"Interactive Symmetry"
#define INTERACTIVE_SCATTER_PLOT_GRAPH      @"Interactive Scattert Plot"
#define MULTI_SCATTER_PLOT_GRAPH            @"Multi scatter Plot"
#define AREA_GRAPH                          @"Area graph"
#define DYNAMIC_LINE_GRAPH                  @"Dynamic line"
#define DYNAMIC_BAR_GRAPH                   @"Dynamic Bar"
#define DYNAMIC_SCATTER_GRAPH               @"Dynamic Scattert"

@interface ViewController ()

@property (nonatomic, strong) UIButton *menuButton, *removeGraph;
@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, strong) NSArray *arrayOfGraphs;
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) UIScrollView *graphView;

@end

@implementation ViewController

-(void)loadView
{
    self.view = [[UIView alloc]init];
    
    _backGroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgimage"]];
    [self.view addSubview:_backGroundImageView];
    
    _arrayOfGraphs = [[NSArray alloc]initWithObjects:INTERACTIVE_LINE_GRAPH, INTERACTIVE_BAR_GRAPH, INTERACTIVE_HORIZANTAL_BAR_GRAPH, INTERACTIVE_SYMMETRY_GRAPH, INTERACTIVE_SCATTER_PLOT_GRAPH, MULTI_SCATTER_PLOT_GRAPH, AREA_GRAPH, DYNAMIC_LINE_GRAPH, DYNAMIC_BAR_GRAPH, DYNAMIC_SCATTER_GRAPH,nil];
    
    _menuButton = [[UIButton alloc]init];
    [_menuButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    _menuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [_menuButton.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_menuButton.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_menuButton.layer setShadowOpacity:1];
    [self.view addSubview:_menuButton];
    
    _removeGraph = [[UIButton alloc]init];
    [_removeGraph addTarget:self  action:@selector(removeCurrentGraph) forControlEvents:UIControlEventTouchUpInside];
    _removeGraph.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [_removeGraph.titleLabel setTextColor:[UIColor whiteColor]];
    [_removeGraph.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_removeGraph setTitle:@"X" forState:UIControlStateNormal];
    [_removeGraph.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_removeGraph.layer setShadowOpacity:1];
    [self.view addSubview:_removeGraph];
    
    _removeGraph.hidden = YES;
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
    _backGroundImageView.frame = self.view.bounds;
    _menuButton.frame = CGRectMake(0, 0, MENU_SIZE.width, MENU_SIZE.height);
    _menuButton.layer.cornerRadius = _menuButton.frame.size.width/2;
    _menuButton.center = MENU_CENTER;
    _menuView.frame = self.view.bounds;
    
    _graphView.frame = CGRectMake(0, self.view.frame.size.height*0.25, self.view.frame.size.width, self.view.frame.size.height*0.5);
    _graphView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + MENU_CENTER.y);
    
    _removeGraph.frame = CGRectMake(0, _graphView.frame.origin.y - MINIMUM_WIDTH_OF_BUTTON*0.75, MINIMUM_WIDTH_OF_BUTTON, MINIMUM_HEIGHT_OF_BUTTON);
    _removeGraph.layer.cornerRadius = MINIMUM_WIDTH_OF_BUTTON/2;
    
    
    [self.view bringSubviewToFront:_menuButton];
}

-(void)menuClicked
{
    if (_menuView == nil)
    {
        _menuView = [[MenuView alloc]initWithArrayOfLabels:_arrayOfGraphs andBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self.view addSubview:_menuView];
        
        [_menuView.backgroundButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIButton *graphsButtons in _menuView.arrayOfGraphButtons)
            [graphsButtons addTarget:self action:@selector(graphSelectedWith:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_menuView removePath];
                             for (UIButton *menu in _menuView.arrayOfGraphButtons)
                                 menu.center = CGPointMake(-2*MENU_SIZE.width, menu.center.y);
                             
                         } completion:^(BOOL finished) {
                             [_menuView removeFromSuperview];
                             _menuView = nil;
                         }];
    }
}

-(void)removeCurrentGraph
{
    if (_updateTimer != nil)
    {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
    
    if (_graphView != nil)
    {
        [_graphView removeFromSuperview];
        _graphView =  nil;
        
        _removeGraph.hidden = YES;
    }
}


-(void)graphSelectedWith:(id)sender
{
    [self menuClicked];
    
    [self removeCurrentGraph];
    
    UIButton *clickedButton = (UIButton *)sender;
    
    if([clickedButton.titleLabel.text isEqualToString:INTERACTIVE_LINE_GRAPH])
    {
        InteractiveLineGraph *interactiveLine = [[InteractiveLineGraph alloc]initWithPlotArray:[GraphModel getMinuteDataFor:76]];
        _graphView = interactiveLine;
    }
    else if ([clickedButton.titleLabel.text isEqualToString:INTERACTIVE_BAR_GRAPH])
    {
        GraphConfig* config = [[GraphConfig alloc]init];
        config.startingX = 0;
        config.endingX = 375;
        config.startingY = (self.view.frame.size.height*0.5)*0.9;
        config.endingY = 0;
        config.widthOfPath = 40;
        config.unitSpacing = 5;
        config.colorsArray = @[(__bridge id)COLOR(174.0, 189.0, 161.0, 1).CGColor, (__bridge id)COLOR(0.0, 3.0, 3.0, 1).CGColor];
        config.firstPlotAraay = [GraphModel getDataForDays:20 withUpperLimit:100 andLowerlimit:0];
        config.xAxisLabelsEnabled = YES;
        config.labelFont = [UIFont systemFontOfSize:14];
        
        InteractiveBar *interaciveBar = [[InteractiveBar alloc]initWithConfigData:config];
        _graphView = interaciveBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:INTERACTIVE_SYMMETRY_GRAPH])
    {
        GraphConfig* config = [[GraphConfig alloc]init];
        config.startingX = 0;
        config.endingX = 375;
        config.startingY = (self.view.frame.size.height*0.5)*0.9;
        config.endingY = 0;
        config.widthOfPath = 40;
        config.unitSpacing = 5;
        config.colorsArray = @[(__bridge id)COLOR(174.0, 189.0, 161.0, 1).CGColor, (__bridge id)COLOR(0.0, 3.0, 3.0, 1).CGColor];
        config.firstPlotAraay = [GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0];
        config.secondPlotArray = [GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0];
        config.xAxisLabelsEnabled = YES;
        config.labelFont = [UIFont systemFontOfSize:14];
        
        SymmetryBarGraph *interaciveSymmetryBar = [[SymmetryBarGraph alloc]initWithFirstPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0] andSecondPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0]];
        _graphView = interaciveSymmetryBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:INTERACTIVE_HORIZANTAL_BAR_GRAPH])
    {
        HorizantalGraph *interaciveHorizantalBar = [[HorizantalGraph alloc]initWithPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0]];
        _graphView = interaciveHorizantalBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:INTERACTIVE_SCATTER_PLOT_GRAPH])
    {
        ScatterPlotGraph *scatterPlotGraph = [[ScatterPlotGraph alloc]initWithPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0]];
        _graphView = scatterPlotGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:MULTI_SCATTER_PLOT_GRAPH])
    {
        MultiScatterGraph *multiScatterPlotGraph = [[MultiScatterGraph alloc]initWithFirstPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0] andSecondPlotArray:[GraphModel getDataForDays:365 withUpperLimit:100 andLowerlimit:0]];
        _graphView = multiScatterPlotGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:AREA_GRAPH])
    {
        AreaGraph *areaGraph = [[AreaGraph alloc]initWithPlotArray:[GraphModel getDataForDays:30 withUpperLimit:100 andLowerlimit:50]withecondPlotArray:[GraphModel getDataForDays:30 withUpperLimit:80 andLowerlimit:30] andThirdPlotArray:[GraphModel getDataForDays:30 withUpperLimit:50 andLowerlimit:0]];
        _graphView = areaGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:DYNAMIC_LINE_GRAPH])
    {
        DynamicGraphs *dynamicLine = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Line];
        _graphView = dynamicLine;
        [self createTimer];
    }
    else if([clickedButton.titleLabel.text isEqualToString:DYNAMIC_BAR_GRAPH])
    {
        DynamicGraphs *dynamicBar = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Bar];
        _graphView = dynamicBar;
        [self createTimer];
    }
    else if([clickedButton.titleLabel.text isEqualToString:DYNAMIC_SCATTER_GRAPH])
    {
        DynamicGraphs *dynamicScattert = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Scatter];
        _graphView = dynamicScattert;
        [self createTimer];
    }
    
   
    if (_graphView != nil)
    {
        [self.view addSubview:_graphView];
        _removeGraph.hidden = NO;
    }
}

//Trigger timer at start of minute
-(void)createTimer
{
    if (_updateTimer == nil)
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(createData)
                                                      userInfo:nil
                                                       repeats:YES];
}

-(void)createData
{
    [((DynamicGraphs *)_graphView) createDataWithPlotObj:[GraphModel getMinuteDataInBetween:0 upper:100]] ;
}


@end
