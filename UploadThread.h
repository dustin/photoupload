//
//  UploadThread.h
//  PhotoUpload
// arch-tag: 6D56D8C4-9196-11D8-86CE-000A957659CC
//
//  Created by Dustin Sallings on Wed Sep 25 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadParams.h"
#import "Batch.h"

@interface UploadThread : NSObject {
	Batch *_batch;
    UploadParams *params;
}

-(void)run: (id)object;
-(void)setBatch:(Batch *)to;

@end
