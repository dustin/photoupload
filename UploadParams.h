//
//  UploadParams.h
//  PhotoUpload
// arch-tag: 6BA29CF8-9196-11D8-B505-000A957659CC
//
//  Created by Dustin Sallings on Wed Sep 25 2002.
//  Copyright (c) 2002 SPY internetworking. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UploadParams : NSObject {

    BOOL _finished;

    id _controller;
    SEL _uploadFileMethod;
    SEL _uploadCompleteMethod;
    SEL _uploadErrorMethod;

    int currentFile;
}

-(BOOL)finished;
-(void)setFinished:(BOOL)to;

// Callbacks for updating the UI
-(void)setController: (id)controller;
-(void)setUploadedFileMethod: (SEL)markUploaded;
-(void)setUploadCompleteMethod: (SEL)markComplete;
-(void)setUploadErrorMethod: (SEL)uploadError;

// Methods used in the thread to indicate changes.
-(void)uploadedFile;
-(void)uploadError: (id)object;
-(void)uploadComplete;

@end
