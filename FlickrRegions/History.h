//
//  History.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/17/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface History : NSManagedObject

@property (nonatomic, retain) NSDate * timeViewed;
@property (nonatomic, retain) Photo *hasPhotos;

@end
