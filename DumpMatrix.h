/* DumpMatrix */
// arch-tag: 5D4073F6-9196-11D8-9FA2-000A957659CC

#import <Cocoa/Cocoa.h>
#import "SizeScaler.h"

@interface DumpMatrix : NSMatrix
{
    NSMutableDictionary *_storage;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

// Remove all entries in the current matrix
-(void)clear;

// Add a new file to the storage
-(void)addFile:(NSString *)filename;
-(void)removeFile:(NSString *)filename;
-(void)removeSelected;

// Update
-(void)update;

// Get the files, an array of NSStrings
-(NSArray *)files;

@end
