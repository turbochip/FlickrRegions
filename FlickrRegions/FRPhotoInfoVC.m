//
//  FRPhotoInfoVC.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/15/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FRPhotoInfoVC.h"
#import "FlickrFetcher.h"

@interface FRPhotoInfoVC ()  <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *photographer;
@property (weak, nonatomic) IBOutlet UITextField *dateUploadedField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *tagsField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;

@end

@implementation FRPhotoInfoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setScrollView:(UIScrollView *)scrollView
{
    _scrollView=scrollView;
    self.scrollView.contentSize=self.image ? self.image.size : CGSizeZero;
    self.scrollView.minimumZoomScale=0.2;
    self.scrollView.maximumZoomScale=2.0;
    [self.scrollView setDelegate:self];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.]
    NSManagedObjectContext *context=self.document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photoDictionary" ascending:YES]];
    request.predicate=[NSPredicate predicateWithFormat:@"photoID=%@",self.transferPhoto.photoID];
    NSError *error;
    NSArray *regionResults = [context executeFetchRequest:request error:&error];
    CCLog(@"RegionResults=%@",regionResults);
    if((!regionResults) || (regionResults.count==0)) {
        CCLog(@"Error no photoDictionary found");
    } else {
        CCLog(@"preparing photoURL");
        Photo *myP=[regionResults objectAtIndex:0];
        NSDictionary *myD=(NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:myP.photoDictionary ];
        CCLog(@"myD=%@",myD);
        
        NSURL *photoURL=[FlickrFetcher URLforPhoto:myD format:FlickrPhotoFormatLarge];
        CCLog(@"photoURL=%@",photoURL.path);
        NSURLRequest *request = [NSURLRequest requestWithURL:photoURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (!error) {
                                                                if([request.URL isEqual:photoURL]) {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image=image;});
                                                                }
                                                            }
                                                        }];
        [task resume];
        self.titleField.text=myP.title;
        self.latitudeField.text=[NSString stringWithFormat:@"%f10.2",[myP.latitude floatValue]];
        self.longitudeField.text=[NSString stringWithFormat:@"%f10.2", [myP.longitude floatValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
        NSString *myDateAsString = [dateFormatter stringFromDate:[myP dateUploaded]];

        self.dateUploadedField.text=myDateAsString;
    }
}


- (void) setImage:(UIImage *)image
{
    self.scrollView.zoomScale= 1;
    self.imageView.image=image;
    self.scrollView.contentSize=self.image ? self.image.size :CGSizeZero ;
    [self.imageView setFrame:self.scrollView.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
