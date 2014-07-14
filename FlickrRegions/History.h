//
//  History.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/14/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface History : NSManagedObject

@property (nonatomic, retain) NSDate * timeViewed;
@property (nonatomic, retain) NSSet *hasPhotos;
@end

@interface History (CoreDataGeneratedAccessors)

- (void)addHasPhotosObject:(Photo *)value;
- (void)removeHasPhotosObject:(Photo *)value;
- (void)addHasPhotos:(NSSet *)values;
- (void)removeHasPhotos:(NSSet *)values;

@end
