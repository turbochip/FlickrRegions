//
//  FRRegionTVC.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface FRRegionTVC : CoreDataTableViewController
@property (nonatomic,strong) UIManagedDocument *document;
@end
