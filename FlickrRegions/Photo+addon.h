//
//  Photo+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Photo.h"
#import "FRExtras.h"

@interface Photo (addon)
@property (nonatomic,strong) UIManagedDocument *document;

+(void) addPhoto:(NSDictionary *) d onDocument:(UIManagedDocument *) doc;
+(void) LoadPhotosFromFlickrArray:(NSArray *)photos onDocument:(UIManagedDocument *) doc;

@end
