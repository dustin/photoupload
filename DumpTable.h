//
//  DumpTable.h
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/11/23/.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DumpTable : NSTableView {

	IBOutlet id imgStorage;

}

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

@end
