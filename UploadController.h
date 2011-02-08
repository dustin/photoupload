/* UploadController */
// arch-tag: 69EE517C-9196-11D8-ABF6-000A957659CC

#import <Cocoa/Cocoa.h>
#import "UploadParams.h"
#import "DumpMatrix.h"
#import "Batch.h"
#import "BatchController.h"
#import "BatchUploadController.h"
#import "PhotoUpload.h"

#define BUTTON_UPLOAD 1
#define BUTTON_STOP 2

@interface UploadController : NSObject
{
    IBOutlet NSWindow *authWindow;
    IBOutlet NSComboBox *categories;
    IBOutlet NSTextField *dateTaken;
    IBOutlet NSTextField *description;
    IBOutlet NSTextField *keywords;
    IBOutlet NSSecureTextField *password;
    IBOutlet NSProgressIndicator *progressBar;
    IBOutlet NSButton *uploadButton;
    IBOutlet NSTextField *uploadingText;
    IBOutlet NSWindow *uploadWindow;
    IBOutlet NSTextField *url;
    IBOutlet NSTextField *username;

	IBOutlet id imgStorage;

    NSUserDefaults *defaults;

    UploadParams *params;
    BatchController *_batchController;
    BatchUploadController *_batchUploadController;

    int buttonType;

    int currentFile;
}
- (IBAction)authenticate:(id)sender;
- (IBAction)dateToToday:(id)sender;
- (IBAction)newBatch:(id)sender;
- (IBAction)openAuthWindow:(id)sender;
- (IBAction)openBatch:(id)sender;
- (IBAction)openUploadWindow:(id)sender;
- (IBAction)removeAllFiles:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)saveBatch:(id)sender;
- (IBAction)selectFiles:(id)sender;
- (IBAction)showFiles:(id)sender;
- (IBAction)showSelectedImages:(id)sender;
- (IBAction)stopUpload:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)uploadBatches:(id)sender;

- (void)alert:(id)title message:(id)msg;
- (void)updateProgressText;
@end
