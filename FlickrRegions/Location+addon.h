//
//  Location+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Location.h"
#import "FRExtras.h"

@interface Location (addon)
+(Location *) addLocation:(NSDictionary *)d onDocument:(UIManagedDocument *)doc;
+(Location *)getLocation:(NSString *)locationID onDocument:(UIManagedDocument *)doc;
+(void) loadLocationsFromFlickrArray:(NSArray *)locations onDocument:(UIManagedDocument *) doc;

@end
