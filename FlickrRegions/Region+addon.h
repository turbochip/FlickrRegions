//
//  Region+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Region.h"
#import "FRExtras.h"

@interface Region (addon)
+(Region *) addRegion:(NSDictionary *)d onDocument:(UIManagedDocument *) doc;
+(void) updateNumberOfPicturesInRegion: (NSString *)rName onDocument: (UIManagedDocument *)doc;
+(void) loadRegionsFromFlickrArray:(NSArray *)regions onDocument:(UIManagedDocument *) doc;

@end
