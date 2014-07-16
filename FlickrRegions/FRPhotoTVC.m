//
//  FRPhotoTVC.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/14/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRPhotoTVC.h"
#import "Photo.h"
#import "Region.h"
#import "Location.h"
#import "FlickrFetcher.h"
#import "FRPhotoVC.h"
#import "FRPhotoInfoVC.h"

@interface FRPhotoTVC ()
@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic,strong) NSMutableArray *photoLocations;
@property (nonatomic,strong) Photo *transferPhoto;
@end

@implementation FRPhotoTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *) photos
{
    if(!_photos) _photos=[[NSMutableArray alloc] init];
    return _photos;
}

- (NSMutableArray *) photoLocations
{
    if(!_photoLocations) _photoLocations=[[NSMutableArray alloc] init];
    return _photoLocations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate=self;
    CCLog(@"calling plog");
    NSManagedObjectContext *context=self.document.managedObjectContext;
    CCLog(@"Fetching regionName=%@",self.regionName);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
   // request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    request.predicate=[NSPredicate predicateWithFormat:@"regionName==%@",self.regionName];
//    request.predicate=[NSPredicate predicateWithFormat:@"ofLocation.isInRegion.regionName=%@",self.regionName];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        CCLog(@"Error no regions found %@",error);
    } else {
        Region *reg=[regionResults objectAtIndex:0];
        self.photoLocations=[[reg.hasLocations allObjects] mutableCopy];
        for(Location *loc in self.photoLocations){
            request=nil;
            request=[NSFetchRequest fetchRequestWithEntityName:@"Location"];
            CCLog(@"LocationName=%@",loc.locationName);
            request.predicate=[NSPredicate predicateWithFormat:@"locationName==%@",loc.locationName];
            NSArray *locationResults = [context executeFetchRequest:request error:&error];
            //CCLog(@"locationResults %@",locationResults);
            if((!locationResults) || (locationResults.count==0)) {
                CCLog(@"No Pictures found for location %@",loc.locationName);
            } else {
                for(Location *l in locationResults) {
                    CCLog(@"location=%@",l.locationName);
                    for(Photo *p in [l.hasPhotosof allObjects]) {
                        CCLog(@"Photo=%@",p.title);
                        [self.photos addObject:p];
                    }
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    CCLog(@"self.photos.count=%d",self.photos.count);
    return self.photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Photo *p=[self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text=p.title;
    return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLog(@"Selected row at indexpath %d - %@",indexPath.row,[self.photos objectAtIndex:indexPath.row]);
    self.transferPhoto=[self.photos objectAtIndex:indexPath.row];
    return indexPath;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CCLog(@"Preparing for segue");
    if([segue.destinationViewController isKindOfClass:[FRPhotoVC class]]) {
        FRPhotoVC *dVC = segue.destinationViewController;
        CCLog(@"transferPhoto1=%@",self.transferPhoto);
        dVC.transferPhoto=self.transferPhoto;
        dVC.document=self.document;
    } else {
        // this is the info segue.  We have to determine what cell we were on when the button was pressed
        CCLog(@"transferPhoto2=%@",self.transferPhoto);
        FRPhotoInfoVC *dVC = segue.destinationViewController;
        dVC.transferPhoto=self.transferPhoto;
        dVC.document=self.document;
    }
}



@end
