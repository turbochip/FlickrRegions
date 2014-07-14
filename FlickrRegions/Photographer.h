//
//  Photographer.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tookPhotos;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addTookPhotosObject:(Photo *)value;
- (void)removeTookPhotosObject:(Photo *)value;
- (void)addTookPhotos:(NSSet *)values;
- (void)removeTookPhotos:(NSSet *)values;

@end
