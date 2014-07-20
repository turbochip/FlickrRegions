//
//  FRHistoryTVC.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/17/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRHistoryTVC.h"
#import "History.h"
#import "FRPhotoInfoVC.h"
#import "Photo.h"
#import "FRPhotoVC.h"
#import "History+addon.h"

@interface FRHistoryTVC ()
@property (nonatomic,strong) NSMutableArray *history;
@end

@implementation FRHistoryTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *) history
{
    if (!_history) _history=[[NSMutableArray alloc] init];
    return _history;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CCLog(@"in viewdidload");
    FRHistoryTVC *myFRHTVC=(FRHistoryTVC *)[self.tabBarController.viewControllers objectAtIndex:0];
    self.document=myFRHTVC.document;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.history=[[History listHistoryonDocument:self.document] mutableCopy];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.history.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text=((History *)[self.history objectAtIndex:indexPath.row]).hasPhotos.title;
    return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLog(@"Selected row at indexpath %d - %@",indexPath.row,[self.history objectAtIndex:indexPath.row]);
    self.transferPhoto=((History *)[self.history objectAtIndex:indexPath.row]).hasPhotos;
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
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Photo *p = ((History *)[self.history objectAtIndex:indexPath.row]).hasPhotos;
        CCLog(@"transferPhoto2=%@",self.transferPhoto);
        FRPhotoInfoVC *dVC = segue.destinationViewController;
        dVC.transferPhoto=p;
        dVC.document=self.document;
    }
}


@end
