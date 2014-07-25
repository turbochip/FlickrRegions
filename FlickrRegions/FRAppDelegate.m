//
//  FRAppDelegate.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo.h"
#import "Photo+addon.h"
#import "Location.h"
#import "Location+addon.h"
#import "PhotoDatabaseAvailability.h"

@interface FRAppDelegate() <NSURLSessionDownloadDelegate>
@property (strong,nonatomic) UIActivityIndicatorView *spinner;
@property (copy,nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrLocationDownloadSession;
@property (strong, nonatomic) NSURLSession *flickrPhotoDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (strong,nonatomic) NSURL *url;
@end

//@synthesize document= _document;
#define FLICKR_PHOTO_FETCH @"Flickr Just Uploaded Photo"
#define FLICKR_LOCATION_FETCH @"Flickr Just Uploaded Location"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (3*60)

@implementation FRAppDelegate

-(void)setDocument:(UIManagedDocument *)document
{
    _document = document;
    
    NSDictionary *userInfo=self.document ? @{ PhotoDatabaseAvailabilityDocument :self.document } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
    
    [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                     target:self
                                   selector:@selector(startFlickrLocationFetch:)
                                   userInfo:nil
                                    repeats:YES];
}

-(UIActivityIndicatorView *)spinner
{
    if(!_spinner) _spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setFrame:CGRectMake(200, 200, 200, 200)];
    return _spinner;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.document=[self openDatabase:@"FlickrRegions"];
    
    self.context=self.document.managedObjectContext;
    //[FRExtras startSpinner:self.spinner];
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,^{
        CCLog(@"About to start fetching locations");
        [self startFlickrLocationFetch];
    });
    //[FRExtras stopSpinner:self.spinner];
    // Override point for customization after application launch.
    return YES;
}

- (UIManagedDocument *) openDatabase: (NSString *) databaseName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory =[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = databaseName;
    self.url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    // Setup my document here
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:self.url];
    // print out the url path just for fun.
    CCLog(@"url=%@ \n filePathURL=%@",[self.url path], [self.url pathComponents]);
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.url path]];
    if(fileExists){
        // open file
        [document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                CCLog(@"Database exists and was opened");
            }
        }];
    } else { // create file and open it at the same time.
        [document saveToURL:self.url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)
                CCLog(@"New Database Opened");
            else
                CCLog(@"Couldn't create document %@",self.url);
        }];
    }
    return document;
}

- (void) startFlickrLocationFetch:(NSTimer *)timer
{
    CCLog(@"Timer refresh initiated");
    [self startFlickrLocationFetch];
}

- (void) startFlickrLocationFetch
{
    [self.flickrLocationDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(![downloadTasks count]) {
            CCLog(@"Starting download of Locations");
            NSURLSessionDownloadTask *task = [self.flickrLocationDownloadSession downloadTaskWithURL:[FlickrFetcher URLforTopPlaces]];
            task.taskDescription=FLICKR_LOCATION_FETCH;
            [task resume];
        } else {
            CCLog(@"there are %d downloadTasks to resume",downloadTasks.count);
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                CCLog(@"Resuming existing tasks %@",task.taskDescription);
                [task resume];
            }
        }
    }];
}

- (void) startFlickrPhotoFetch:(NSArray *)locations
{
    CCLog(@"Regions=%@",locations);
    for (NSDictionary *location in locations)
    {
        NSString *location_ID=[location objectForKey:FLICKR_PLACE_ID];
        [self.flickrPhotoDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if(![downloadTasks count]) {
                CCLog(@"Starting download %@",location_ID);
                NSURLSessionDownloadTask *task = [self.flickrPhotoDownloadSession downloadTaskWithURL:[FlickrFetcher URLforPhotosInPlace: location_ID
                    maxResults:10]];
                task.taskDescription=FLICKR_PHOTO_FETCH;
                [task resume];
            } else {
                for (NSURLSessionDownloadTask *task in downloadTasks)
                    [task resume];
            }
        }];
    }
}

// Getter for property flickrDownloadSession
- (NSURLSession *)flickrPhotoDownloadSession
{
    if (!_flickrPhotoDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionCOnfig = [NSURLSessionConfiguration
                                                           backgroundSessionConfiguration:FLICKR_PHOTO_FETCH];
            urlSessionCOnfig.allowsCellularAccess=NO;
            _flickrPhotoDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionCOnfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _flickrPhotoDownloadSession;
}

// Getter for property flickrDownloadSession
- (NSURLSession *)flickrLocationDownloadSession
{
    if (!_flickrLocationDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionCOnfig = [NSURLSessionConfiguration
                                                           backgroundSessionConfiguration:FLICKR_LOCATION_FETCH];
            urlSessionCOnfig.allowsCellularAccess=NO;
            _flickrLocationDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionCOnfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _flickrLocationDownloadSession;
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    CCLog(@"Didfinishdownloadingtourl");
    NSManagedObjectContext *context=[self.document managedObjectContext];
    if([downloadTask.taskDescription isEqualToString:FLICKR_PHOTO_FETCH]) {
        if (context) {
            NSArray *photos = [self flickrPhotosAtURL:localFile];
            [context performBlock:^{
                CCLog(@"About to load photo array");
                [Photo LoadPhotosFromFlickrArray:photos onDocument:self.document];
                [context save:NULL];
            }];
        } else {
            [self flickrDownloadTasksMightBeComplete:FLICKR_PHOTO_FETCH];
        }
    } else {
        if([downloadTask.taskDescription isEqualToString:FLICKR_LOCATION_FETCH]) {
            if (context) {
                NSArray *locations = [self flickrLocationsAtURL:localFile];

                [context performBlock:^{
                    CCLog(@"About to load locations array");
                    CCLog(@"Locations=%@",locations);
                    [Location loadLocationsFromFlickrArray:locations onDocument:self.document];
                    [context save:NULL];
                    [self startFlickrPhotoFetch:locations];
                    [context save:NULL];
                }];
            } else {
                [self flickrDownloadTasksMightBeComplete:FLICKR_LOCATION_FETCH];
            }
        }
    }
}

- (void)flickrDownloadTasksMightBeComplete:(NSString*) taskDescription
{
    if(self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        if([taskDescription isEqualToString:FLICKR_PHOTO_FETCH]) {
            [self.flickrPhotoDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                if(![downloadTasks count]) {
                    void (^completionHandler)()=self.flickrDownloadBackgroundURLSessionCompletionHandler;
                    self.flickrDownloadBackgroundURLSessionCompletionHandler=nil;
                    if(completionHandler) {
                        completionHandler();
                    }
                }
            }];
        }else {
            if([taskDescription isEqualToString:FLICKR_LOCATION_FETCH]) {
                [self.flickrLocationDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                    if(![downloadTasks count]) {
                        void (^completionHandler)()=self.flickrDownloadBackgroundURLSessionCompletionHandler;
                        self.flickrDownloadBackgroundURLSessionCompletionHandler=nil;
                        if(completionHandler) {
                            completionHandler();
                        }
                    }
                }];
            }
        }
    }
}

-(void) URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

-(NSArray *) flickrPhotosAtURL:(NSURL *)url
{
    CCLog(@"Converting JSON data to array");
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    NSDictionary *flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

-(NSArray *) flickrLocationsAtURL:(NSURL *)url
{
    CCLog(@"Converting JSON data to array");
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    NSDictionary *flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PLACES];
}

@end
