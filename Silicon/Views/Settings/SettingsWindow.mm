//
//  SettingsWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "SettingsWindow.hpp"
#import "SettingsViewController.hpp"

@implementation SettingsWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.title = @"Settings";
        self.releasedWhenClosed = NO;
        
        SettingsViewController *contentViewController = [SettingsViewController new];
        self.contentViewController = contentViewController;
        [contentViewController release];
    }
    
    return self;
}

@end
