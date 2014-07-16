//
//  Photo.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/15/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class History, Location, Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * photoDictionary;
@property (nonatomic, retain) History *lastViewed;
@property (nonatomic, retain) Location *ofLocation;
@property (nonatomic, retain) Photographer *takenBy;

@end
