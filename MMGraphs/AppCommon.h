//
//  AppCommon.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/26/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#ifndef AppCommon_h
#define AppCommon_h

#define SCREEN_WIDTH                    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT                   [UIScreen mainScreen].bounds.size.height
#define SCREEN_BOUNDS                   [[UIScreen mainScreen]bounds]

#define MINIMUM_HEIGHT_OF_BUTTON        (44*SCREEN_WIDTH)/375
#define MINIMUM_WIDTH_OF_BUTTON         (44*SCREEN_WIDTH)/375

#define MENU_SIZE                       CGSizeMake(MINIMUM_WIDTH_OF_BUTTON*1.3, MINIMUM_HEIGHT_OF_BUTTON*1.3)
#define MENU_CENTER                     CGPointMake(SCREEN_WIDTH*0.25, SCREEN_HEIGHT*0.1)


#endif /* AppCommon_h */
