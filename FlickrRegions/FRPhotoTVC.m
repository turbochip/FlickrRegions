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

@interface FRPhotoTVC ()
@property (nonatomic,strong) NSMutableArray *photos;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSManagedObjectContext *context=self.document.managedObjectContext;
    NSLog(@"Fetching regionName=%@",self.regionName);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
   // request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    request.predicate=[NSPredicate predicateWithFormat:@"regionName==%@",self.regionName];
//    request.predicate=[NSPredicate predicateWithFormat:@"ofLocation.isInRegion.regionName=%@",self.regionName];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    if((!regionResults) || (regionResults.count==0))
    {
        NSLog(@"Error no regions found %@",error);
    } else {
        Region *reg=[regionResults objectAtIndex:0];
        for(Location *loc in [reg.hasLocations allObjects]){
            request=nil;
            request=[NSFetchRequest fetchRequestWithEntityName:@"Location"];
            NSLog(@"LocationName=%@",loc.locationName);
            request.predicate=[NSPredicate predicateWithFormat:@"locationName==%@",loc.locationName];
            NSArray *locationResults = [context executeFetchRequest:request error:&error];
            NSLog(@"locationResults %@",locationResults);
            if((!locationResults) || (locationResults.count==0)) {
                NSLog(@"No Pictures found for location %@",loc.locationName);
            } else {
                for(Location *l in locationResults) {
                    NSLog(@"location=%@",l.locationName);
                    for(Photo *p in [l.hasPhotosof allObjects]) {
                        NSLog(@"Photo=%@",p.title);
                        [self.photos addObject:p.title];
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text=[self.photos objectAtIndex:indexPath.row];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
