//
//  Photographer.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/24/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Photo;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tookPhotos;
@property (nonatomic, retain) NSSet *tookPhotosInLocation;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addTookPhotosObject:(Photo *)value;
- (void)removeTookPhotosObject:(Photo *)value;
- (void)addTookPhotos:(NSSet *)values;
- (void)removeTookPhotos:(NSSet *)values;

- (void)addTookPhotosInLocationObject:(Location *)value;
- (void)removeTookPhotosInLocationObject:(Location *)value;
- (void)addTookPhotosInLocation:(NSSet *)values;
- (void)removeTookPhotosInLocation:(NSSet *)values;

@end
