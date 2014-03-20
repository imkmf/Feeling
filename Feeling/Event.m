//
//  Event.m
//  Feeling
//
//  Created by Kristian Freeman on 2/24/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic timestamp;
@dynamic rating;
@dynamic image;
@dynamic note;
@dynamic userDeleted;

- (NSString *)formattedDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    return [formatter stringFromDate:self.timestamp];
}

@end
