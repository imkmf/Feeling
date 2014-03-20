//
//  AddEventViewController.h
//  Feeling
//
//  Created by Kristian Freeman on 2/24/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface AddEventViewController : UIViewController
@property (nonatomic, assign) Event *event;
- (void)editMode;
- (void)addImage:(NSData *)data;
- (void)setReadOnly;
- (void)setSliderValue:(Event*)event;
@end
