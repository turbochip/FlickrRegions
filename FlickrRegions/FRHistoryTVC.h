//
//  FRHistoryTVC.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/17/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRExtras.h"
#import "Photo.h"

@interface FRHistoryTVC : UITableViewController
@property (nonatomic,strong) Photo *transferPhoto;
@property (nonatomic,strong) UIManagedDocument *document;

@end
