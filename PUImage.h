//
//  PUImage.h
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/29/3.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PUImage : NSObject {
	NSString *filename;
	NSImage *image;
}

-(id)initWithPath:(NSString *)path;

-(NSImage *)image;
-(NSString *)filename;

@end
