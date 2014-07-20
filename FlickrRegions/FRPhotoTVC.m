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
#import "CoreDataTableViewController.h"

@interface FRPhotoTVC ()
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate=self;
    NSManagedObjectContext *context=self.document.managedObjectContext;
    CCLog(@"Fetching photos for regionName=%@",self.regionName);
    
    NSFetchRequest *request =[NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate=[NSPredicate predicateWithFormat:@"ofLocation.isInRegion.regionName=%@",self.regionName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]];
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Photo *p=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=p.title;
    return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CCLog(@"Selected row at indexpath %d - %@",indexPath.row,[self.fetchedResultsController objectAtIndexPath:indexPath]);
    self.transferPhoto=[self.fetchedResultsController objectAtIndexPath:indexPath];
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
        //CCLog(@"transferPhoto for picture=%@",self.transferPhoto);
        dVC.transferPhoto=self.transferPhoto;
        dVC.document=self.document;
    } else {
        // this is the info segue.  We have to determine what cell we were on when the button was pressed
        //CCLog(@"transferPhoto for info=%@",self.transferPhoto);
        FRPhotoInfoVC *dVC = segue.destinationViewController;
        dVC.transferPhoto=self.transferPhoto;
        dVC.document=self.document;
    }
}



@end
