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
#import "Location.h"
#import "Photo.h"
#import "Photo+addon.h"
#import "FRViewController.h"
#import "FRPhotoTVC.h"
#import "FlickrFetcher.h"

@interface FRRegionTVC ()
@property (nonatomic,strong) NSMutableArray *regions;
@property (nonatomic,strong) NSString *regionName;
@property (nonatomic,strong) NSMutableArray *photos;
@end

@implementation FRRegionTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FRViewController *myFRVC=(FRViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    self.document=myFRVC.document;
    NSManagedObjectContext *context=self.document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"countOfPictures" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
//    request.predicate=[NSPredicate predicateWithFormat:@"regionName=%@",rName];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        CCLog(@"Error no regions found %@",error);
    } else {
        self.regions=[regionResults mutableCopy];
    }
    self.tableView.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
   return [self.regions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Region *reg=[self.regions objectAtIndex:indexPath.row];
    cell.textLabel.text=reg.regionName;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d Pictures",reg.countOfPictures.integerValue];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Region *reg=[self.regions objectAtIndex:indexPath.row];
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
        [self fetchPhotos:self.document];
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
    } else {
        Region *rr=[regionResults objectAtIndex:0];
        for(Location *loc in rr.hasLocations) {
            CCLog(@"Location=%@",loc.locationName );
            NSURL *url=[FlickrFetcher URLforPhotosInPlace:loc.locationID maxResults:100];
                CCLog(@"in Queue (not really) about to query flickr");
                NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                NSDictionary *photoResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
                self.photos=[[photoResults valueForKeyPath:FLICKR_RESULTS_PHOTOS] mutableCopy];
                //CCLog(@"About to go through photos %@",self.photos);
                for(NSDictionary *p in self.photos) {
                    CCLog(@"Photo=%@",[p objectForKey:FLICKR_PHOTO_TITLE]);
                    [Photo addPhoto:p onDocument:self.document];
                }
                
/*
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
                NSError *error;
                NSArray *regionResults = [context executeFetchRequest:request error:&error];
                if((!regionResults) || (regionResults.count==0))
                {
                    CCLog(@"Error %@",error);
                } else {
                    for(Region *reg in regionResults)
                        [Region updateNumberOfPicturesInRegion:reg.regionName onDocument:self.document];
                }
                [self stopSpinner];
                self.doneAddingData=YES;
 */

        }
    }
}

@end
