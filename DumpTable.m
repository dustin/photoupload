//
//  DumpTable.m
//  PhotoUpload
//
//  Created by Dustin Sallings on 2005/11/23/.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "DumpTable.h"
#import "PUImageList.h"

@implementation DumpTable

-(BOOL)isImage: (NSString *)file
{
    BOOL rv=false;
    NSString *ext=[[file pathExtension] lowercaseString];

    rv|=[ext isEqualToString: @"jpg"];
    rv|=[ext isEqualToString: @"jpeg"];
    rv|=[ext isEqualToString: @"gif"];
    rv|=[ext isEqualToString: @"png"];

    return(rv);
}

-(NSArray *)getImages: (NSString *)file
{
    NSMutableArray *justFiles=[[NSMutableArray alloc] init];

    // Figure out if it's a directory or a file.
    // If it's a directory, recurse.  If it's a file, just use it.
    BOOL isDir=FALSE;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:file isDirectory:&isDir]) {
        if (isDir) {
            NSArray *subpaths = [manager subpathsAtPath:file];
            int i=0;
            for(i=0; i<[subpaths count]; i++) {
                NSString *fullpath=[file
                    stringByAppendingPathComponent: [subpaths objectAtIndex: i]];
                if ([manager fileExistsAtPath:file isDirectory:&isDir]) {
                    [justFiles addObject: fullpath];
                }
            }
        } else {
            [justFiles addObject: file];
        }
    }

    NSMutableArray *rv=[[NSMutableArray alloc] init];
    [rv autorelease];

    NSEnumerator *nse=[justFiles objectEnumerator];
    id object=nil;
    while(object = [nse nextObject]) {
        // NSLog(@"--- %@\n", object);
        if([self isImage: object]) {
            [rv addObject: object];
        }
    }
    // pathExtension

    [justFiles release];
    return(rv);
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info
	row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"Accepting drop...");
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info
	proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"Asking to validate info.");
	NSDragOperation rv=NSDragOperationNone;
    NSDragOperation sourceDragMask = [info draggingSourceOperationMask];
    if (sourceDragMask & NSDragOperationLink) {
        rv=NSDragOperationLink;
    } else if (sourceDragMask & NSDragOperationCopy) {
        rv=NSDragOperationCopy;
    }
    return rv;
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSLog(@"Performing dragging operation.");
    NSPasteboard *pboard=[sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    int i=0;
    for(i=0; i<[files count]; i++) {
        NSString *filename=[files objectAtIndex: i];
        NSArray *subfilenames=[self getImages: filename];
        int j=0;
        for(j=0; j<[subfilenames count]; j++) {
            id subfilename=[subfilenames objectAtIndex: j];
            [imgStorage addPath: subfilename];
            // NSLog(@"Subfile %@\n", subfilename);
        }
        // NSLog(@"Got %@\n", filename);
    }
    return (TRUE);
}

-(void)awakeFromNib
{
	NSLog(@"Awakened from nib, registering for dragging.");
	[self registerForDraggedTypes:[NSArray arrayWithObjects:
        NSFilenamesPboardType, nil]];
	[self setDataSource: self];
}

@end