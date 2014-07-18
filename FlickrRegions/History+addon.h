//
//  History+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "History.h"
#import "FRExtras.h"

@interface History (addon)
+(History *) addHistory:(Photo *)p onDocument:(UIManagedDocument *)doc;
+(NSArray *) listHistoryonDocument:(UIManagedDocument *) doc;

@end
