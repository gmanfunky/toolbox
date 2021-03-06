//
//  overviewpluginPane.m
//  overviewplugin
//
//  Created by Jeffrey Dean Morgan on 8/24/15.
//  Copyright (c) 2015 Docker Inc. All rights reserved.
//

#import "overviewpluginPane.h"
#import "mixpanel.h"

@interface overviewpluginPane()
@property BOOL firstTime;
@end

@implementation overviewpluginPane

- (id) init {
    self.firstTime = YES;
    self = [super init];
    return self;
}

- (NSString *)title {
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void) willEnterPane:(InstallerSectionDirection)dir {
    NSURL *url = [[[self section] bundle] URLForResource:@"overview" withExtension:@"html"];
    NSMutableAttributedString *formattedHTML = [[NSMutableAttributedString alloc] initWithURL:url documentAttributes:nil];
    [formattedHTML addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13.0f] range:NSMakeRange(0, formattedHTML.length)];

    [[self.textView textStorage] setAttributedString:formattedHTML];
    if (self.firstTime) {
        [Mixpanel trackEvent:@"Installer Started" forPane:self];
        self.firstTime = NO;
    }
}

- (void) willExitPane:(InstallerSectionDirection)dir {
    if (dir != InstallerDirectionForward) {
        return;
    }

    [Mixpanel trackEvent:@"Continued from Overview" forPane:self];
}

- (IBAction)checkboxChanged:(id)sender {
    if ([(NSButton*)sender state] == NSOnState) {
        [Mixpanel trackEvent:@"Enabled Tracking" forPane:self];
        [[[self section] sharedDictionary] removeObjectForKey:@"disableTracking"];
    } else {
        [Mixpanel trackEvent:@"Disabled Tracking" forPane:self];
        [[[self section] sharedDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"disableTracking"];
    }
}

@end
