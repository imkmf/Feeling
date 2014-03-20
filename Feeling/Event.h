//
//  Event.h
//  Feeling
//
//  Created by Kristian Freeman on 2/24/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * userDeleted;

- (NSString *)formattedDate;

@end
