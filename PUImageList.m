//
//  PUImageList.m
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/30/3.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PUImageList.h"
#import "PUImage.h"

@implementation PUImageList

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic=NO;
    if ([theKey isEqualToString:@"images"]) {
        automatic=YES;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

-(id)init
{
	id rv=[super init];
	images=[[NSMutableArray alloc] initWithCapacity:16];
	return(rv);
}

-(void)addPath:(NSString *)path
{
	[self willChangeValueForKey:@"images"];
	PUImage *img=[[PUImage alloc] initWithPath:path];
	[images addObject: img];
	[img release];
	
	[self didChangeValueForKey:@"images"];
}

-(void)removeAllObjects
{
	[self willChangeValueForKey:@"images"];
	[images removeAllObjects];
	[self didChangeValueForKey:@"images"];
}

-(NSArray *)images
{
	return(images);
}

-(unsigned)count
{
	return([images count]);
}

@end
