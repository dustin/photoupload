/* HideableProgressIndicator */
// arch-tag: 5F7E016C-9196-11D8-B8A5-000A957659CC

#import <Cocoa/Cocoa.h>

@interface HideableProgressIndicator : NSProgressIndicator
{
    BOOL _hidden;
}
- (BOOL)hidden;
- (void)setHidden: (BOOL)val;
@end
