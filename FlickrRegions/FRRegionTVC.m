//
//  FRRegionTVC.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//
#import "FRExtras.h"
#import "FRRegionTVC.h"
#import "Region.h"
#import "Region+addon.h"
#import "Location.h"
#import "Photo.h"
#import "Photo+addon.h"
#import "FRViewController.h"
#import "FRPhotoTVC.h"
#import "FlickrFetcher.h"
#import "CoreDataTableViewController.h"
#import "PhotoDatabaseAvailability.h"

@interface FRRegionTVC ()
@property (nonatomic,strong) NSMutableArray *regions;
@property (nonatomic,strong) NSString *regionName;
@property (nonatomic,strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *ActivityView;
@end

@implementation FRRegionTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.document = note.userInfo [PhotoDatabaseAvailabilityDocument];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSManagedObjectContext *context=self.document.managedObjectContext;
    
    [self updatePhotoCount:context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"countOfPictures" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
    request.predicate=nil;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:context
                                     sectionNameKeyPath:nil
                                     cacheName:nil];

    self.tableView.delegate=self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSManagedObjectContext *context=self.document.managedObjectContext;

    [self updatePhotoCount:context];
}

- (void) updateNumberOfPicturesInRegion:(NSString *)rName onDocument:(UIManagedDocument *)doc
{
    NSManagedObjectContext *context =doc.managedObjectContext;
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = nil;
    NSError *error;

    request.predicate=[NSPredicate predicateWithFormat:@"regionName=%@", rName];
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        CCLog(@"Error fetching records to update photographer count");
    }
    NSInteger numPics=0;
    for (Region *object in objects)
    {
        for(Location *loc in object.hasLocations) {
            CCLog(@"loc=%@ - %d",loc, loc.hasPhotographers.count  );
            numPics=numPics+loc.hasPhotographers.count;
        }
        object.countOfPictures=[NSNumber numberWithInteger:numPics];
    }
 
}

-(void) updatePhotoCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:NO]];
    request.predicate=nil;
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        CCLog(@"No Regions found");
    } else {
        for(Region *region in regionResults) {
            [self updateNumberOfPicturesInRegion:region.regionName onDocument:self.document];
        }
    }
    [Region regionCleanupOnDocument:self.document];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionCell" forIndexPath:indexPath];
    // Configure the cell...
    Region *reg=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=reg.regionName;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d Pictures",reg.countOfPictures.integerValue];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Region *reg=[self.fetchedResultsController objectAtIndexPath:indexPath];
    self.regionName=reg.regionName;
    CCLog(@"region %@ was selected now go prepare for segue",self.regionName);
    return indexPath;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.destinationViewController isKindOfClass:[FRPhotoTVC class]]){
        self.spinner=[FRExtras startSpinner:self.spinner ];
        [self fetchPhotos:self.document];
        [FRExtras stopSpinner:self.spinner];
        FRPhotoTVC *photoSegue=[segue destinationViewController];
        photoSegue.document=self.document;
        photoSegue.regionName=self.regionName;
    }
}

- (void) fetchPhotos:(UIManagedDocument *)doc
{
    CCLog(@"In fetchPhotos");
    // Execute query for all location id's in the given area.
    NSManagedObjectContext *context=self.document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate=[NSPredicate predicateWithFormat:@"regionName=%@",self.regionName];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        CCLog(@"Region %@ not found",self.regionName);
    } 
}

@end
