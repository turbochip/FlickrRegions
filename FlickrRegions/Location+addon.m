//
//  Location+addon.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Location+addon.h"
#import "FlickrFetcher.h"
#import "Region+addon.h"

@implementation Location (addon)

+(Location *) addLocation:(NSDictionary *)d onDocument:(UIManagedDocument *)doc
{
    Location *location;
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSString *lName=[d valueForKey:FLICKR_PLACE_WOE_NAME];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationName" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"locationName=%@",lName];
    NSError *error;
    NSArray *locationResults = [context executeFetchRequest:request error:&error];
    if((!locationResults) || (locationResults.count==0)) {
        location =[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        location.locationName =lName;
        location.pictureQty=[NSNumber numberWithInteger:[[d objectForKey:FLICKR_PLACE_PHOTO_COUNT] intValue]];
        location.locationID=[d objectForKey:FLICKR_PLACE_ID];
        NSLog(@"Location %@ has been added",lName);
        location.isInRegion=[Region addRegion:d onDocument:doc];
        
    } else {
        NSLog(@"Location %@ already exists",lName);
        return locationResults[0];
    }
    return location;
}

@end
