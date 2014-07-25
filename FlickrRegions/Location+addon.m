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
    CCLog(@"lName=%@",lName);
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
        CCLog(@"Location %@ has been added",lName);
        location.isInRegion=[Region addRegion:d onDocument:doc];
        [context save:NULL];
        
    } else {
        CCLog(@"Location %@ already exists",lName);
        return locationResults[0];
    }
    return location;
}

+(Location *)getLocation:(NSString *)locationID onDocument:(UIManagedDocument *)doc
{
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationName" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"locationID=%@",locationID];
    CCLog(@"locationID=%@",locationID);
    NSError *error;
    NSArray *locationResults = [context executeFetchRequest:request error:&error];
    if((!locationResults) || (locationResults.count==0)) {
        CCLog(@"LocationID %@ does not exist",locationID);
        return nil;
    }
    return [locationResults objectAtIndex:0];
}

+(void) loadLocationsFromFlickrArray:(NSArray *)locations onDocument:(UIManagedDocument *) doc
{
    CCLog(@"Loading location array");
    for(NSDictionary *location in locations) {
        [self addLocation:location onDocument:doc];
    }
}

@end
