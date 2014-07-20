//
//  Photo+addon.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Photo+addon.h"
#import "FlickrFetcher.h"
#import "Location+addon.h"

@implementation Photo (addon)

-(void)setDocument:(UIManagedDocument *) document
{
    self.document=document;
}
-(UIManagedDocument *)document
{
    return self.document;
}

+(void) addPhoto:(NSDictionary *) d onDocument:(UIManagedDocument *) doc
{
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSString *pID=[d valueForKey:FLICKR_PHOTO_ID];
    //CCLog(@"d=%@",d);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photoID" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"photoID=%@",pID];
    NSError *error;
    NSArray *pIDResults = [context executeFetchRequest:request error:&error];
    if((!pIDResults) || (pIDResults.count==0)) {
        CCLog(@"Creating entity for photo");
        Photo *photo =[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.title=[d valueForKey:FLICKR_PHOTO_TITLE];
        photo.photoID=[d valueForKey:FLICKR_PHOTO_ID];
        photo.photoDictionary=[NSKeyedArchiver archivedDataWithRootObject:d];
        photo.ofLocation=[Location getLocation:[d valueForKey:FLICKR_PHOTO_PLACE_ID] onDocument:doc];
        if (!photo.ofLocation) [Location addLocation:d onDocument:doc];
        CCLog(@"Photo %@ has been added",pID);
        [context save:NULL];

    } else {
        CCLog(@"Photo %@ already exists",pID);
    }
}

+(void) LoadPhotosFromFlickrArray:(NSArray *)photos onDocument:(UIManagedDocument *) doc
{
    CCLog(@"Loading photo array");
    CCLog(@"photos=%@",photos);
    for(NSDictionary *photo in photos) {
        [self addPhoto:photo onDocument:doc];
    }
}

@end
