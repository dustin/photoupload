//
//  PUImage.m
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/29/3.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PUImage.h"
#import "SizeScaler.h"

@implementation PUImage

-(id)initWithPath:(NSString *)path
{
	id rv=[super init];
	filename=[path retain];
	
	// Load up the image
	image=[[NSImage alloc] initByReferencingFile: filename];
	[image setName: path];
	[image setScalesWhenResized: YES];
	SizeScaler *sc=[[SizeScaler alloc] initWithSize: [image size]];
	NSSize theSize={64.0, 64.0};
	[image setSize: [sc scaleTo: theSize]];
	[image recache];
	
	return(rv);
}

-(void)dealloc
{
	[filename release];
	[image release];
	[super dealloc];
}

-(NSString *)filename
{
	return(filename);
}

-(NSImage *)image
{
	return(image);
}

-(NSString *)description
{
	return([NSString stringWithFormat:@"<PUImage path:%@>", filename]);
}

@end
