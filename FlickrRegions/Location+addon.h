//
//  Location+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Location.h"

@interface Location (addon)
+(Location *) addLocation:(NSDictionary *)d onDocument:(UIManagedDocument *)doc;

@end
