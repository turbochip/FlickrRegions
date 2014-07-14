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
        NSLog(@"Added region %@",rName);
    } else {
        NSLog(@"Region %@ already exists",rName);
        region=regionResults[0];
    }
    return region;
}

+(NSString *) getRegionName:(NSDictionary *) d
{
    NSURL *url= [FlickrFetcher URLforInformationAboutPlace:[d valueForKey:FLICKR_PLACE_ID]];
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
    //    NSLog(@"Flickr results = %@", propertyListResults);
    NSString *region=[FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
    NSLog(@"region=%@",region);
    return region;
}

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
            NSLog(@"Error region %@ does not exist!",rName);
        } else {
            Region *rr=regionResults[0];
            NSInteger regionQty=0;
            for(Location *loc in rr.hasLocations) {
                regionQty=regionQty+loc.pictureQty.integerValue;
                NSLog(@"region=%@ locations %@ have %d pictures for %d total",rName,loc.locationName,loc.pictureQty.integerValue,regionQty);
            }
            rr.countOfPictures=[NSNumber numberWithInteger:regionQty];
        }
    }
}
@end
