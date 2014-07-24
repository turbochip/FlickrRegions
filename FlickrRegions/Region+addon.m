//
//  Region+addon.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "Region+addon.h"
#import "FlickrFetcher.h"
#import "Location.h"

@implementation Region (addon)

+(Region *) addRegion:(NSDictionary *)d onDocument:(UIManagedDocument *)doc
{
    Region *region;
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSString *rName=[self getRegionName:d];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"regionName=%@",rName];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        region =[NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
        region.regionName = rName;
        CCLog(@"Added region %@",rName);
    } else {
        CCLog(@"Region %@ already exists",rName);
        region=regionResults[0];
    }
    return region;
}

+(NSString *) getRegionName:(NSDictionary *) d
{
    NSURL *url= [FlickrFetcher URLforInformationAboutPlace:[d valueForKey:FLICKR_PLACE_ID]];
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
    CCLog(@"Flickr results = %@", propertyListResults);
    NSString *region=[FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
    CCLog(@"region=%@",region);
    return region;
}
/*
+(void) updateNumberOfPicturesInRegion: (NSString *)rName onDocument: (UIManagedDocument *)doc
{
    if(rName) {
        NSManagedObjectContext *context=doc.managedObjectContext;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
        request.predicate=[NSPredicate predicateWithFormat:@"regionName=%@",rName];
        NSError *error;
        NSArray *regionResults = [context executeFetchRequest:request error:&error];
        if((!regionResults) || (regionResults.count==0))
        {
            CCLog(@"Error region %@ does not exist!",rName);
        } else {
            Region *rr=regionResults[0];
            NSInteger regionQty=0;
            CCLog(@"Region     location     pictures     total");
            for(Location *loc in rr.hasLocations) {
                regionQty=regionQty+loc.pictureQty.integerValue;
                CCLog(@"%d, %d, %@ - %@",loc.pictureQty.integerValue,regionQty,rName,loc.locationName);
            }
            rr.countOfPictures=[NSNumber numberWithInteger:regionQty];
            [context save:NULL];

        }
    }
}
 */

+ (void) updateNumberOfPicturesInRegion:(NSString *)rName onDocument:(UIManagedDocument *)doc
{
    NSManagedObjectContext *context =doc.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Region" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"hasLocations.hasPhotosof.takenBy"]];
    
    // Execute the fetch.
    NSError *error;
    id requestedValue = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        CCLog(@"Error fetching records to update photographer count");
    }
    CCLog(@"objects=%@",objects);

}

+(void) loadRegionsFromFlickrArray:(NSArray *)regions onDocument:(UIManagedDocument *) doc
{
    CCLog(@"Loading region array");
    //CCLog(@"regions=%@",regions);
    for(NSDictionary *region in regions) {
        [self addRegion:region onDocument:doc];
    }
}

@end
