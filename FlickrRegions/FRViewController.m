//
//  FRViewController.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRViewController.h"
#import "Flickr Fetcher/FlickrFetcher.h"
#import "Location.h"
#import "Location+addon.h"
#import "Region.h"
#import "Region+addon.h"
#import "FRRegionTVC.h"
#import "FRAppDelegate.h"

@interface FRViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong,nonatomic) NSMutableArray* flickrLocations;
@property (nonatomic) NSInteger spinnerCount;
@end

@implementation FRViewController

-(void) setDoneAddingData:(BOOL)doneAddingData
{
    _doneAddingData=doneAddingData;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_doneAddingData) {
            [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if(success)
                    NSLog(@"Document saved");
                else
                    NSLog(@"Couldn't create document %@",self.url);
            }];
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // in here we are going to setup our database if it doesn't exist
    // then we will kickoff a thread to bring in our flickrdata and populate our tables.
    NSLog(@"In View Did load, about to start spinner");
    [self startSpinner];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory =[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"FlickrRegions";
    self.url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    // Setup my document here
    self.document = [[UIManagedDocument alloc] initWithFileURL:self.url];
    // print out the url path just for fun.
    NSLog(@"url=%@ \n filePathURL=%@",[self.url path], [self.url pathComponents]);
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.url path]];
    if(fileExists){
        // open file
        [self.document openWithCompletionHandler:^(BOOL success) {
            if(success) [self documentIsReady];
        }];
    } else { // create file and open it at the same time.
        [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)
                [self documentIsReady];
            else
                NSLog(@"Couldn't create document %@",self.url);
        }];
    }
    

}

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        // start using document
        NSLog(@"Document is in Normal State");
        // setup queue to do flickr fetches and load database.
        [self fetchAreas: self.document];
    } else {
        NSLog(@"Docuemnt is not in Normal State");
    }
    [self stopSpinner];
}

- (void) fetchAreas:(UIManagedDocument *)doc
{
    self.doneAddingData=NO;
    NSLog(@"In fetchAreas");
    NSURL *url= [FlickrFetcher URLforTopPlaces];
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,^{
        [self startSpinner];
        NSLog(@"in Queue about to query flickr");
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        self.flickrLocations=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        NSLog(@"About to go through locations");
        for(NSDictionary *d in self.flickrLocations) {
            [Location addLocation:d onDocument:doc];
        }

        
        
        NSManagedObjectContext *context=self.document.managedObjectContext;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
        NSError *error;
        NSArray *regionResults = [context executeFetchRequest:request error:&error];
        if((!regionResults) || (regionResults.count==0))
        {
            NSLog(@"Error %@",error);
        } else {
            for(Region *reg in regionResults)
                [Region updateNumberOfPicturesInRegion:reg.regionName onDocument:self.document];
        }
        [self stopSpinner];
        self.doneAddingData=YES;
    });
}

-(NSInteger)isSpinnerRunning
{
    return self.spinnerCount;
}

-(void) startSpinner
{
    self.spinnerCount++;
    if(![self.spinner isAnimating]){
        [self.spinner startAnimating];
        NSLog(@"Starting Spinner spinnerCount=%d",self.spinnerCount);
    }
}

-(void) stopSpinner
{
    self.spinnerCount--;
    if(self.spinnerCount<0)
        self.spinnerCount=0;
    if(([self.spinner isAnimating]) && (self.spinnerCount==0)) {
        [self.spinner stopAnimating];
        NSLog(@"Stopping Spinner spinnerCount=%d",self.spinnerCount);
    }
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[FRRegionTVC class]])
    {
        FRRegionTVC *regTVC=segue.destinationViewController;
        regTVC.document=self.document;
    }
}

@end
