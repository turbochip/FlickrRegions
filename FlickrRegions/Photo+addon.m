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

+(void) addPhoto:(NSDictionary *) d onDocument:(UIManagedDocument *) doc
{
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSString *pID=[d valueForKey:FLICKR_PHOTO_ID];
    NSLog(@"Photo-id=%@",pID);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photoID" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"photoID=%@",pID];
    NSError *error;
    NSArray *pIDResults = [context executeFetchRequest:request error:&error];
    if((!pIDResults) || (pIDResults.count==0)) {
        Photo *photo =[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.title=[d valueForKey:FLICKR_PHOTO_TITLE];
        photo.photoID=[d valueForKey:FLICKR_PHOTO_ID];
        [Location addLocation:d onDocument:doc];
        NSLog(@"Photo %@ has been added",pID);
    } else {
        NSLog(@"Photo %@ already exists",pID);
    }
}

@end
