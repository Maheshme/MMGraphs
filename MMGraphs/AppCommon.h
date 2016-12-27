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

#define COLOR(r,g,b,a)                  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define BUBBLE_VALUE_FONT_SIZE          20

#define SECONDS_IN_A_DAY                24*60*60

#define DATE_FORMAT_M_D                 @"MMM dd"
#define DATE_FORMAT_WEEK                @"eeeeee"
#define DATE_FORMAT_DAY                 @"d"
#define DATE_FORMAT_MONTH               @"MMM"
#define DATE_MONTH_YEAR_FORMAT          @"dd/MM/yy"
#define DATE_FORMAT_MMM_DD_YYYY         @"MMM dd, yyyy"
#define DATE_FORMAT_MMMM_DD_YYYY        @"MMMM dd, yyyy"
#define DATE_FORMAT_MMM_DD              @"MM/dd"


#endif /* AppCommon_h */
