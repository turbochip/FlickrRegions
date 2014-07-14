//
//  FRViewController.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/13/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRViewController : UIViewController
@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic) BOOL doneAddingData;

@end
