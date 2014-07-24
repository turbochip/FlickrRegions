//
//  Photographer+addon.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Photographer.h"
#import "FRExtras.h"

@interface Photographer (addon)
+(Photographer *) addPhotographer:(NSDictionary *) d onDocument:(UIManagedDocument *) doc;
@end
