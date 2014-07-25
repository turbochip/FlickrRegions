//
//  FRViewController.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRViewController.h"
#import "FRExtras.h"
#import "FlickrFetcher.h"
#import "Location.h"
#import "Location+addon.h"
#import "Region.h"
#import "Region+addon.h"
#import "FRRegionTVC.h"
#import "FRHistoryTVC.h"
#import "FRAppDelegate.h"
#import "PhotoDatabaseAvailability.h"

@interface FRViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong,nonatomic) NSMutableArray* flickrLocations;
@end

@implementation FRViewController

- (void) awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.document = note.userInfo [PhotoDatabaseAvailabilityDocument];
    }];
}


-(void) setDoneAddingData:(BOOL)doneAddingData
{
    _doneAddingData=doneAddingData;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_doneAddingData) {
            [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if(success)
                    CCLog(@"Document saved");
                else
                    CCLog(@"Couldn't create document %@",self.url);
            }];
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}
/*
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[FRRegionTVC class]])
    {
        FRRegionTVC *regTVC=segue.destinationViewController;
        regTVC.document=self.document;
    } else {
        if ([segue.destinationViewController isKindOfClass:[FRHistoryTVC class]])
        {
            FRHistoryTVC *histTVC=segue.destinationViewController;
            histTVC.document=self.document;
        }
    }
}
*/
@end
