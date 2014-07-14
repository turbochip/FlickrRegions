//
//  Photo+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Photo.h"

@interface Photo (addon)

+(void) addPhoto:(NSDictionary *) d onDocument:(UIManagedDocument *) doc;

@end
