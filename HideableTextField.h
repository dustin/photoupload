/* HideableTextField */
// arch-tag: 60D98254-9196-11D8-943A-000A957659CC

#import <Cocoa/Cocoa.h>

@interface HideableTextField : NSTextField
{
    BOOL _hidden;
}
- (BOOL)hidden;
- (void)setHidden: (BOOL)val;
@end
