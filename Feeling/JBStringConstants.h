//
//  JBStringConstants.h
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/6/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#define localize(key, default) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], default, nil)

#pragma mark - Labels

#define kJBStringLabelHowAreYouFeeling localize(@"label.how.are.you.feeling", @"How are you feeling?")
#define kJBStringLabelMm localize(@"label.mm", @"mm")
