//
//  UploadThread.m
//  PhotoUpload
// arch-tag: 53F4E420-9196-11D8-9294-000A957659CC
//
//  Created by Dustin Sallings on Wed Sep 25 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <CoreServices/CoreServices.h>

#import "UploadThread.h"

@implementation UploadThread

-(void)setBatch:(Batch *)to
{
	id tmp=to;
	_batch=to;
	[_batch retain];
	if(tmp != nil) {
		[tmp release];
	}
}

-(void)run: (id)object
{
	// Create the autorelease pool.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Retain the parameters
    params=object;
	[params retain];

	// Dictionary for the arguments
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:10];

	// The arguments that are always the same
    [dict setObject:[_batch username] forKey:@"username"];
    [dict setObject:[_batch password] forKey:@"password"];
    [dict setObject:[_batch keywords] forKey:@"keywords"];
    [dict setObject:[_batch description] forKey:@"info"];
    [dict setObject:[_batch taken] forKey:@"taken"];
    [dict setObject:[_batch category] forKey:@"category"];

	// URL for uploading
    NSURL *url=[[NSURL alloc] initWithString: [_batch url]];
    
	NSEnumerator *en=[[_batch files] objectEnumerator];
	id f=nil;
    while( (f = [en nextObject]) && (! [params finished])) {
		// Create an inner autorelease pool to deal with the garbage the
		// upload produces
    	NSAutoreleasePool *ipool = [[NSAutoreleasePool alloc] init];

        NSLog(@"Uploading %@.", f);

        // Get the file data
        NSData *myData = [[NSData alloc] initWithContentsOfFile:[f filename]];
        [dict setObject:myData forKey:@"image"];

		NSDictionary *argDict=[NSDictionary dictionaryWithObject:dict
			forKey:@"args"];

		WSMethodInvocationRef rpcCall=WSMethodInvocationCreate(
	            (CFURLRef)url, (CFStringRef)@"addImage.addImage",
				            kWSXMLRPCProtocol);

		WSMethodInvocationSetParameters(rpcCall, (CFDictionaryRef)argDict, nil);

		NSDictionary *result =
			(NSDictionary *)WSMethodInvocationInvoke(rpcCall);

		NSLog(@"Result:  %@", result);

		if(WSMethodResultIsFault((CFDictionaryRef)result)) {
			[params uploadError:
				[result objectForKey: (NSString *)kWSFaultString]];
		} else {
			id rv=[result objectForKey: (NSString *)kWSMethodInvocationResult];
			NSLog(@"Uploaded image %@", rv);
		}

		// Release the XML-RPC specific stuff.
		CFRelease(rpcCall);
		[result release];

        [myData release];
        [params uploadedFile];
		[ipool release];
    }
    NSLog(@"Finished, thread will join.\n");
    [params uploadComplete];

    [url release];
    [dict release];
    [pool release];
}

-(void)dealloc
{
	if(_batch!=nil) {
		[_batch release];
		_batch=nil;
	}
	if(params!=nil) {
		[params release];
		params=nil;
	}
	[super dealloc];
}

@end
