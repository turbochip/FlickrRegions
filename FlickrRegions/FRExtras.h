//
//  FRExtras.h
//  FlickrRegions
//
//  Created by Chip Cox on 7/14/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

#define oldLog( s, ... ) NSLog( @"<%s - %d> %@", __PRETTY_FUNCTION__, __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#define CCLog( s, ... ) logIt( @"<%s - %d> %@", __PRETTY_FUNCTION__, __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )


#ifdef DEBUG
#define UA_log( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define UA_log( s, ... )
#endif


void logIt(NSString *fmt, ...);

@interface FRExtras : NSObject
+(UIActivityIndicatorView *) startSpinner:(UIActivityIndicatorView *)spinner;
+(void) stopSpinner:(UIActivityIndicatorView *) spinner;

@end
