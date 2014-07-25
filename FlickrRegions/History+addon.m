//
//  History+addon.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "History+addon.h"
#import "FRExtras.h"
#import "FlickrFetcher.h"
#import "Photo.h"

@implementation History (addon)
+(History *) addHistory:(Photo *)p onDocument:(UIManagedDocument *)doc
{
    History *hist;
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.predicate=[NSPredicate predicateWithFormat:@"hasPhotos=%@",p];
    NSError *error;
    NSArray *historyResults = [context executeFetchRequest:request error:&error];
    if((!historyResults) || (historyResults.count==0)) {
        hist =[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        NSLocale* currentLocale = [NSLocale currentLocale];
        [[NSDate date] descriptionWithLocale:currentLocale];
        hist.timeViewed=[NSDate date];
        hist.hasPhotos=p;
        CCLog(@"Photo %@ has been added",p.title );
    } else {
        CCLog(@"Location %@ already exists",p.title);
        return hist;
    }
    return hist;
}

+(NSArray *) listHistoryonDocument:(UIManagedDocument *) doc
{
    NSManagedObjectContext *context=doc.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeViewed" ascending:YES]];
    NSError *error;
    NSArray *historyResults = [context executeFetchRequest:request error:&error];
    if((!historyResults) || (historyResults.count==0)) {
        CCLog(@"No history found");
        return nil;
    } else {
        return historyResults;
    }
}

@end
