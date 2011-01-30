// arch-tag: 4FAC61DA-9196-11D8-88DB-000A957659CC

#import "UploadController.h"
#import "UploadThread.h"
#import "UploadParams.h"
#import "SizeScaler.h"
#import "PUImageList.h"
#import "cJSON.h"

@interface UploadController (Private)

- (void)setButtonAction: (int)to;

@end

@implementation UploadController

- (void)alert:(id)title message:(id)msg
{
    NSRunAlertPanel(title, msg, @"OK", nil, nil);
}

static char *getJSONString(cJSON *j, const char *name) {
    assert(j);
    cJSON *f = cJSON_GetObjectItem(j, name);
    assert(f);
    assert(f->type == cJSON_String);
    return f->valuestring;
}

static cJSON *getJSONArray(cJSON *j, const char *name) {
    assert(j);
    cJSON *f = cJSON_GetObjectItem(j, name);
    assert(f == NULL || f->type == cJSON_Array);
    return f;
}

- (IBAction)authenticate:(id)sender
{
    /* Set the defaults */
    [defaults setObject: [username stringValue] forKey:@"username"];
    [defaults setObject: [url stringValue] forKey:@"url"];

    NSURL *u=[[NSURL alloc] initWithString:[[url stringValue]
											stringByAppendingPathComponent:@"/_design/app/_view/cat?group=true"]];
	NSLog(@"Fetching from %@", u);

	NSStringEncoding enc;
	NSError *e = NULL;
	NSString *result = [[NSString alloc] initWithContentsOfURL:u
													usedEncoding:&enc
															error:&e];

	NSLog(@"Result:  %@", result);

	cJSON *responseJson = cJSON_Parse([result UTF8String]);
	cJSON *rows = responseJson ? getJSONArray(responseJson, "rows") : NULL;
	if (e) {
		[self alert:_str(@"Auth Exception")	message:[e description]];
	} else if (responseJson && rows) {
		NSMutableArray *titles = [[NSMutableArray alloc] init];

		size_t numRows = rows ? cJSON_GetArraySize(rows) : 0;
		size_t i = 0;
		for (i = 0; i < numRows; ++i) {
			cJSON *ob = cJSON_GetArrayItem(rows, i);
			assert(ob);

			char *titleCStr = getJSONString(ob, "key");
			NSString *title = [[NSString alloc] initWithCString: titleCStr];
			[titles addObject:title];
			[title release];
		}

		// Populate the categories
		[categories removeAllItems];
		[categories addItemsWithTitles:titles];

		// Out with the auth
		[authWindow orderOut: self];
		// In with the uploader
		[self openUploadWindow: self];

		cJSON_Delete(responseJson);
		[titles release];
	} else {
		// {"error":"not_found","reason":"missing"}
		NSString *msg = NULL;
		if (responseJson) {
			const char *error = getJSONString(responseJson, "reason");
			msg = [NSString stringWithFormat: @"Error:  %s\n(check the URL and stuff)", error];
			cJSON_Delete(responseJson);
		} else {
			msg = @"No idea what happened.";
		}
		[self alert:_str(@"Auth Exception")	message:msg];
	}

    [u release];
	[result release];
}

- (IBAction)dateToToday:(id)sender
{
    id kw=[NSApp keyWindow];
    // Check to see if the key window is the window
    // for the other controller, and do the right thing.
    if(_batchController != nil && (kw == [_batchController window])) {
        [_batchController dateToToday:self];
    } else {
        NSDate *today = [NSDate date];
        NSString *datestr=
            [today descriptionWithCalendarFormat:
                            @"%Y/%m/%d" timeZone: nil
                                          locale: nil];
        [dateTaken setStringValue:datestr];    
    }
}

- (IBAction)newBatch:(id)sender
{
	// Create a new batch controller if we don't have one.
	if(_batchController == nil) {
    	NSLog(@"initializing controller.\n");
    	_batchController = [[BatchController alloc] initWithWindowNibName:
        	@"PhotoUploadBatch"];
    	NSLog(@"Opening window.\n");
	}
    [authWindow orderOut: self];
    [_batchController showWindow:self];
}

- (IBAction)openAuthWindow:(id)sender
{
    [authWindow makeKeyAndOrderFront: self];
}

- (IBAction)openBatch:(id)sender
{
    id filePanel=[NSOpenPanel openPanel];
    [filePanel setAllowsMultipleSelection: FALSE];
    [filePanel setCanChooseDirectories: FALSE];

    id types=[NSArray arrayWithObjects:@"pbatch", nil];
    int rv = [filePanel runModalForTypes:types];

    if (rv == NSOKButton) {
        id batch = [NSKeyedUnarchiver unarchiveObjectWithFile:
            [[filePanel filenames] objectAtIndex: 0]];
        [categories selectItemWithTitle: [batch category]];
        [dateTaken setStringValue:
            [[batch taken] descriptionWithCalendarFormat: @"%Y/%m/%d"
                                                timeZone: nil
                                                  locale: nil ]];
        [description setStringValue: [batch description]];
        [keywords setStringValue: [batch keywords]];

        [imgStorage removeAllObjects];
        NSEnumerator *e=[[batch files] objectEnumerator];
        id object;
        while(object = [e nextObject]) {
            [imgStorage addPath: object];
        }
    }
}

- (IBAction)openUploadWindow:(id)sender
{
    [uploadWindow makeKeyAndOrderFront: self];
}

- (IBAction)removeAllFiles:(id)sender
{
    id kw=[NSApp keyWindow];
    if(_batchController != nil && (kw == [_batchController window])) {
        [[_batchController imgMatrix] clear];
    } else {
        [imgStorage removeAllObjects];
    }
}

- (IBAction)removeSelected:(id)sender
{
    id kw=[NSApp keyWindow];
    if(_batchController != nil && (kw == [_batchController window])) {
        [[_batchController imgMatrix] removeSelected];
    } else {
        [imgStorage removeSelected];
    }
}

- (IBAction)saveBatch:(id)sender
{

}

- (IBAction)selectFiles:(id)sender
{
    id filePanel=[NSOpenPanel openPanel];
    [filePanel setAllowsMultipleSelection: TRUE];
    [filePanel setCanChooseDirectories: FALSE];

    id types=[NSArray arrayWithObjects:@"jpg", @"jpeg", @"JPG",
        @"GIF", @"gif", @"png", @"PNG", nil];
    int rv = [filePanel runModalForTypes:types];

    if (rv == NSOKButton) {
        NSArray *files=[filePanel filenames];        
        // This is what's displayed in the image box.
        int i=0;
        for(i=0; i<[files count]; i++) {
			[imgStorage addPath: [files objectAtIndex: i]];
        }
    }
}

- (IBAction)showFiles:(id)sender
{
    NSLog(@"Files:  %@", imgStorage);
}

- (IBAction)showSelectedImages:(id)sender
{
	/*
    NSArray *a=[imgMatrix selectedCells];
    int i=0;
    for(i=0; i<[a count]; i++) {
        NSLog(@"Selected image:  %@\n", [[a objectAtIndex: i] image]);
    }
	*/
}

- (IBAction)stopUpload:(id)sender
{
    [params setFinished: TRUE];
    [uploadButton setEnabled: FALSE];
}

- (IBAction)upload:(id)sender
{
    NSDate *date=[NSCalendarDate dateWithString: [dateTaken stringValue]
                                 calendarFormat: @"%Y/%m/%d"];
    NSString *k=[keywords stringValue];
    if([k length] == 0) {
        [self alert:_str(@"A.T.NoKeywords")
            message:_str(@"A.B.NoKeywords")];
        return;
    }
    NSString *d=[description stringValue];
    if([d length] == 0) {
        [self alert:_str(@"A.T.NoDescription")
            message:_str(@"A.B.NoDescription")];
        return;
    }
    NSString *cat=[categories titleOfSelectedItem];
    NSString *u=[username stringValue];
    NSString *p=[password stringValue];    
    
	Batch *batch=[[Batch alloc] init];

    NSArray *files=[imgStorage images];
    [batch setUrl: [url stringValue]];
    [batch setUsername: u];
    [batch setPassword: p];
    [batch setKeywords: k];
    [batch setDescription: d];
    [batch setCategory: cat];
    [batch setTaken: date];
    [batch setFiles: files];

    if(params != nil) {
        [params release];
    }
    params=[[UploadParams alloc] init];

    [params setController: self];
    [params setUploadErrorMethod: @selector(uploadError:)];
    [params setUploadedFileMethod: @selector(uploadedFile)];
    [params setUploadCompleteMethod: @selector(uploadComplete)];

    // UI updates
    // Fix up the progress bar
    [progressBar setMinValue: 0];
    [progressBar setMaxValue: [files count]];
    [progressBar setDoubleValue: 0];
    [progressBar setHidden: FALSE];
    currentFile=1;
    // And the uploading text
    [self updateProgressText];
    [uploadingText setHidden: FALSE];

    UploadThread *ut=[[UploadThread alloc] init];
	[ut setBatch: batch];
    [NSThread detachNewThreadSelector: @selector(run:)
                                         toTarget:ut withObject: params];

    [self setButtonAction: BUTTON_STOP];
    // [addFilesButton setEnabled: FALSE];
    [ut release];
}

- (IBAction)uploadBatches:(id)sender
{
    id filePanel=[NSOpenPanel openPanel];
    [filePanel setAllowsMultipleSelection: TRUE];
    [filePanel setCanChooseDirectories: FALSE];

    id types=[NSArray arrayWithObjects:@"pbatch", nil];
    int rv = [filePanel runModalForTypes:types];

    if (rv == NSOKButton) {

        // Create a new batch controller if we don't have one.
        if(_batchUploadController == nil) {
            _batchUploadController=[[BatchUploadController alloc] initWithWindowNibName:
                @"BatchUpload"];
        }
        [_batchUploadController setUrl: [url stringValue]];
        [_batchUploadController setUsername: [username stringValue]];
        [_batchUploadController setPassword: [password stringValue]];

        [_batchUploadController processFiles: [filePanel filenames]];
    }    
}

- (void)updateProgressText
{
    if(currentFile <= [imgStorage count])
    {
        NSString *msg=[NSString stringWithFormat:_str(@"UploadingText"),
            currentFile, [imgStorage count]];
        [uploadingText setStringValue: msg];
        [uploadingText displayIfNeeded];
    }
}

- (void)setButtonAction: (int)to
{
    switch(to) {
        case BUTTON_UPLOAD:
            [uploadButton setTitle:_str(@"B.Upload")];
            [uploadButton setAction:@selector(upload:)];
            [uploadButton setToolTip: _str(@"B.Upload.ToolTip")];
            break;
        case BUTTON_STOP:
            [uploadButton setTitle:_str(@"B.Stop")];
            [uploadButton setAction:@selector(stopUpload:)];
            [uploadButton setToolTip: _str(@"B.Stop.ToolTip")];
            break;
    }
    [uploadButton setNeedsDisplay: TRUE];
}

-(void)uploadError: (id)msg
{
    [self alert:_str(@"Upload Error") message: msg];
}

-(void)uploadedFile
{
    // NSLog(@"Uploaded a file.\n");
    currentFile++;
    [self updateProgressText];
    [progressBar incrementBy: 1];
}

-(void)uploadComplete
{
    NSLog(@"Upload is complete.\n");
    // [addFilesButton setEnabled: TRUE];
    [uploadingText setHidden: TRUE];
    [progressBar setMinValue: 0];
    [progressBar setMaxValue: 0];
    [progressBar setDoubleValue: 0];
    [progressBar setHidden: TRUE];
    [progressBar displayIfNeeded];
    [self setButtonAction: BUTTON_UPLOAD];
    [uploadButton setEnabled: TRUE];
}

- (void)awakeFromNib
{
    // Set up windows
    [uploadWindow orderOut: self];
    [progressBar setDisplayedWhenStopped: FALSE];
    // Initialize the button
    buttonType=BUTTON_UPLOAD;
    [self setButtonAction: buttonType];

    defaults=[NSUserDefaults standardUserDefaults];
    id defaultUrl=[defaults objectForKey:@"url"];
    id defaultUsername=[defaults objectForKey:@"username"];
    if(defaultUrl != nil) {
        [url setStringValue:defaultUrl];
    }
    if(defaultUsername != nil) {
        [username setStringValue:defaultUsername];
    }

    // Fill in form entries with defaults
    [self dateToToday: self];

    [imgStorage removeAllObjects];
	/*
    [imgMatrix registerForDraggedTypes:[NSArray arrayWithObjects:
        NSFilenamesPboardType, nil]];
	*/

    [authWindow makeKeyAndOrderFront: self];    
}

@end
