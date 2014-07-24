//
//  Photographer+addon.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Photographer+addon.h"
#import "FRExtras.h"
#import "FlickrFetcher.h"

@implementation Photographer (addon)

+(Photographer *) addPhotographer:(NSDictionary *) d onDocument:(UIManagedDocument *) doc
{
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSString *pID=[d valueForKey:FLICKR_PHOTO_OWNER];
    //CCLog(@"d=%@",d);
    Photographer *photographer;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"name=%@",pID];
    NSError *error;
    NSArray *pIDResults = [context executeFetchRequest:request error:&error];
    if((!pIDResults) || (pIDResults.count==0)) {
        CCLog(@"Creating entity for photo");
        photographer =[NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
        photographer.name=[d valueForKey:FLICKR_PHOTO_OWNER];
        CCLog(@"Photo %@ has been added",pID);
        [context save:NULL];
        
    } else {
        CCLog(@"Photographer %@ already exists",pID);
        photographer=[pIDResults objectAtIndex:0];
    }
    return photographer;
}


@end
