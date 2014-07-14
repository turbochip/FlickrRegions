//
//  Region+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Region.h"

@interface Region (addon)
+(Region *) addRegion:(NSDictionary *)d onDocument:(UIManagedDocument *) doc;
+(void) updateNumberOfPicturesInRegion: (NSString *)rName onDocument: (UIManagedDocument *)doc;

@end
