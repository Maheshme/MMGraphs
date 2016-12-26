//
//  ViewController.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/20/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "ViewController.h"
#import "MenuView.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, strong) NSArray *arrayOfGraphs;
@property (nonatomic, strong) UIImageView *backGroundImageView;

@end

@implementation ViewController

-(void)loadView
{
    self.view = [[UIView alloc]init];
    
    _backGroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgimage"]];
    [self.view addSubview:_backGroundImageView];
    
    _arrayOfGraphs = [[NSArray alloc]initWithObjects:@"Interactive Line",@"Interactive Bar", @"Interactive Symmetry", @"Scattert Plot",@"Multi scatter Plot", @"Stacked bar", @"Area graph", @"Horizontal bar", @"Dynamic line", @"Dynamic Bar", @"Dynamic sctter",nil];
    
    _menuButton = [[UIButton alloc]init];
    [_menuButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    _menuButton.backgroundColor = [UIColor whiteColor];
    [_menuButton.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_menuButton.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_menuButton.layer setShadowOpacity:1];
    [self.view addSubview:_menuButton];
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
    _backGroundImageView.frame = self.view.bounds;
    _menuButton.frame = CGRectMake(0, 0, MENU_SIZE.width, MENU_SIZE.height);
    _menuButton.layer.cornerRadius = _menuButton.frame.size.width/2;
    _menuButton.center = MENU_CENTER;
    _menuView.frame = self.view.bounds;
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
                             
                             for (UIButton *menu in _menuView.arrayOfGraphButtons)
                                 menu.center = CGPointMake(-2*MENU_SIZE.width, menu.center.y);
                             
                         } completion:^(BOOL finished) {
                             [_menuView removeFromSuperview];
                             _menuView = nil;
                         }];
    }
}

-(void)graphSelectedWith:(id)sender
{

}

@end
