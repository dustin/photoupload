// arch-tag: 4ACF33D9-9196-11D8-9F5F-000A957659CC
#import "HideableTextField.h"

@implementation HideableTextField

- (BOOL)hidden
{
    return(_hidden);
}
- (void)setHidden: (BOOL)val
{
    _hidden=val;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)aRect
{
    if (![self hidden])
    {
        [super drawRect:aRect];
    }
}

@end
