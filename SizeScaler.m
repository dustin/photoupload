//
//  SizeScaler.m
//  PhotoUpload
// arch-tag: 4D8FC084-9196-11D8-85E4-000A957659CC
//
//  Created by Dustin Sallings on Sun Oct 06 2002.
//  Copyright (c) 2002 SPY internetworking. All rights reserved.
//

#import "SizeScaler.h"


@implementation SizeScaler

-initWithSize: (NSSize)base
{
    [super init];
    baseSize=base;
    return(self);
}

-(NSSize)scaleTo: (NSSize)size
{
    float x=(float)baseSize.width;
    float y=(float)baseSize.height;
    float aspect=x/y;
	NSSize rv;
	rv.width=x;
	rv.height=y;

    if(size.width <= rv.width || size.height <= rv.height) {

        rv.width=size.width;
        rv.height=(int)((float)rv.width/aspect);

        // If it exceeds the boundaries, do it the other way.
        if(rv.width > size.width || rv.height > size.height) {
            rv.height=size.height;
            rv.width=(int)((float)rv.height*aspect);
        }
    }

    return(rv);    
}

@end
