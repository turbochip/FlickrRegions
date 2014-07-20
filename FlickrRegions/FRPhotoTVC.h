//
//  FRPhotoTVC.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/14/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "FRExtras.h"

@interface FRPhotoTVC : CoreDataTableViewController
@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSString *regionName;
@end
