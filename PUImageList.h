//
//  PUImageList.h
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/30/3.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PUImageList : NSObject {
	
	NSMutableArray *images;

}

-(unsigned)count;
-(void)addPath:(NSString *)path;
-(NSArray *)images;

@end
