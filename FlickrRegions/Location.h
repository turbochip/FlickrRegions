//
//  Location.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/18/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * locationID;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * pictureQty;
@property (nonatomic, retain) NSSet *hasPhotosof;
@property (nonatomic, retain) Region *isInRegion;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addHasPhotosofObject:(Photo *)value;
- (void)removeHasPhotosofObject:(Photo *)value;
- (void)addHasPhotosof:(NSSet *)values;
- (void)removeHasPhotosof:(NSSet *)values;

@end
