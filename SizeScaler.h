//
//  SizeScaler.h
//  PhotoUpload
// arch-tag: 6821A3B4-9196-11D8-9449-000A957659CC
//
//  Created by Dustin Sallings on Sun Oct 06 2002.
//  Copyright (c) 2002 SPY internetworking. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SizeScaler : NSObject {
    NSSize baseSize;
}

-initWithSize: (NSSize)base;

-(NSSize)scaleTo:(NSSize)size;

@end
