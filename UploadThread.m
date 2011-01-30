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
#import "PUImage.h"
#import "SizeScaler.h"
#import "cJSON.h"
#import "NSData-Base64Extensions.h"
#import "NSData+MD5.h"


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

static NSString *formatDate(NSDate *d) {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *rv = [dateFormatter stringFromDate:d];
	[dateFormatter release];
	return rv;
}

static NSString *formatDateTime(NSDate *d) {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
	NSString *rv = [dateFormatter stringFromDate:d];
	[dateFormatter release];
	return rv;
}

static void addAttachment(cJSON *a, const char *name,
						  const char *mimeType, NSData *data) {
	cJSON *doc = cJSON_CreateObject();
	assert(doc);
	cJSON_AddStringToObject(doc, "content_type", mimeType);
	cJSON_AddStringToObject(doc, "data", [[data encodeBase64WithNewlines:NO] UTF8String]);
	cJSON_AddItemToObject(a, name, doc);
}

static void addScaledImage(cJSON *a, const char *name,
						   NSSize size, NSImage *image) {
	NSArray *reps = [image representations];
	NSEnumerator *e=[reps objectEnumerator];
	id object=nil;
	while(object = [e nextObject]) {
		if([object isKindOfClass:[NSBitmapImageRep class]]) {
			NSImage *tempImage = [[NSImage alloc] init];
			[tempImage addRepresentation:object];

			NSImage *auxImage = [[NSImage alloc] initWithSize: size];

			[auxImage lockFocus];
			[tempImage drawInRect:NSMakeRect(0,0,size.width, size.height)
						 fromRect:NSZeroRect
						operation:NSCompositeSourceOver
						 fraction:1.0];

			[auxImage unlockFocus];
			[tempImage release];

			NSBitmapImageRep* scaledImageRep = [[NSBitmapImageRep alloc]
												initWithData: [auxImage TIFFRepresentation]];

			NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
			[props setObject:[NSNumber numberWithFloat: 0.2]
					  forKey:NSImageCompressionFactor];
			NSData *d = [scaledImageRep representationUsingType:NSJPEGFileType
													 properties:props];

			NSLog(@"Storing %d bytes scaled to %dx%d",
				  [d length], (int)size.width, (int)size.height);

			addAttachment(a, name, "image/jpeg", d);

			[props release];
			[auxImage release];
			[scaledImageRep release];
			break;
		}
	}
}

-(void)run: (id)object
{
	// Create the autorelease pool.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSSize tnSize;
	tnSize.width = 220;
	tnSize.height = 146;
	NSSize eightBySix;
	eightBySix.width = 800;
	eightBySix.height = 600;


	// Retain the parameters
    params=object;
	[params retain];

	// URL for uploading
    NSURL *url=[[NSURL alloc] initWithString: [_batch url]];
    
	NSEnumerator *en=[[_batch files] objectEnumerator];
	id f=nil;
    while( (f = [en nextObject]) && (! [params finished])) {
		// Create an inner autorelease pool to deal with the garbage the
		// upload produces
    	NSAutoreleasePool *ipool = [[NSAutoreleasePool alloc] init];

		cJSON *doc = cJSON_CreateObject();
		assert(doc);

        NSLog(@"Uploading %@.", f);

        // Get the file data
        NSData *origData = [[NSData alloc] initWithContentsOfFile:[f filename]];

		cJSON_AddStringToObject(doc, "_id", [[origData md5] UTF8String]);
		cJSON_AddStringToObject(doc, "type", "photo");
		cJSON_AddStringToObject(doc, "addedby", [[_batch username] UTF8String]);
		cJSON_AddStringToObject(doc, "cat", [[_batch category] UTF8String]);
		cJSON_AddStringToObject(doc, "descr", [[_batch description] UTF8String]);
		cJSON_AddStringToObject(doc, "taken", [formatDate([_batch taken]) UTF8String]);
		cJSON_AddStringToObject(doc, "ts", [formatDateTime([NSDate date]) UTF8String]);
		cJSON_AddNumberToObject(doc, "size", [origData length]);
		cJSON_AddStringToObject(doc, "extension",
                                [[[[f filename] pathExtension] lowercaseString] UTF8String]);

		NSImage *origImage = [[NSImage alloc] initWithData: origData];
		NSSize origSize = [origImage size];
		cJSON_AddNumberToObject(doc, "width", origSize.width);
		cJSON_AddNumberToObject(doc, "height", origSize.height);

		SizeScaler *ss = [[SizeScaler alloc] initWithSize:origSize];
		NSSize thisTnSize = [ss scaleTo: tnSize];

		cJSON_AddNumberToObject(doc, "tnwidth", thisTnSize.width);
		cJSON_AddNumberToObject(doc, "tnheight", thisTnSize.height);

		cJSON *keywords = cJSON_CreateArray();
		NSArray *keywordArray = [[_batch keywords] componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
		NSEnumerator *e=[keywordArray objectEnumerator];
		id object=nil;
		while(object = [e nextObject]) {
			cJSON_AddItemToArray(keywords, cJSON_CreateString([object UTF8String]));
		}
		cJSON_AddItemToObject(doc, "keywords", keywords);

		cJSON *attachments = cJSON_CreateObject();
		addAttachment(attachments, "original.jpg", "image/jpeg", origData);
		addScaledImage(attachments, "800x600.jpg", [ss scaleTo:eightBySix], origImage);
		addScaledImage(attachments, "thumb.jpg", thisTnSize, origImage);

		cJSON_AddItemToObject(doc, "_attachments", attachments);

		char *str = cJSON_Print(doc);
		NSData *postBody = [[NSData alloc] initWithBytesNoCopy:str length:strlen(str)
												  freeWhenDone:YES];

		NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]
										   initWithURL:url];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody: postBody];
		[urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-type"];

		NSURLResponse *response;
		NSError *error;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
													 returningResponse:&response
																 error:&error];

		NSString *s = [[NSString alloc] initWithData:responseData
											encoding:NSUTF8StringEncoding];
		NSLog(@"Response:  %@", s);
		[s release];

		if (error) {
			NSLog(@"There was an error");
		}

		[urlRequest release];
		[postBody release];
		[ss release];
        [origData release];
		[origImage release];
        [params uploadedFile];
		cJSON_Delete(doc);
		[ipool release];
    }
    NSLog(@"Finished, thread will join.\n");
    [params uploadComplete];

    [url release];
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
