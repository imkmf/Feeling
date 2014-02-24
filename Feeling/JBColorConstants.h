//
//  JBColorConstants.h
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Navigation

#define kJBColorNavigationBarTint UIColorFromHex(0xFFFFFF)
#define kJBColorNavigationTint UIColorFromHex(0x000000)

#pragma mark - Line Chart

#define kJBColorLineChartControllerBackground UIColorFromHex(0x000000)
#define kJBColorLineChartBackground UIColorFromHex(0x000000)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
