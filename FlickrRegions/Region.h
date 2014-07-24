//
//  Region.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/24/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * countOfPictures;
@property (nonatomic, retain) NSString * regionName;
@property (nonatomic, retain) NSSet *hasLocations;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addHasLocationsObject:(Location *)value;
- (void)removeHasLocationsObject:(Location *)value;
- (void)addHasLocations:(NSSet *)values;
- (void)removeHasLocations:(NSSet *)values;

@end
