//
//  AppMenuItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "AppMenuItem.hpp"
#import "SettingsWindow.hpp"

@interface AppMenuItem ()
@end

@implementation AppMenuItem

- (instancetype)initWithTitle:(NSString *)string action:(SEL)selector keyEquivalent:(NSString *)charCode {
    if (self = [super initWithTitle:string action:selector keyEquivalent:charCode]) {
        [self AppMenuItem_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self AppMenuItem_commonInit];
    }
    
    return self;
}

- (void)AppMenuItem_commonInit {
    [self setupSubmenu];
    [self setupSettingsMenuItem];
}

- (void)setupSubmenu {
    NSMenu *submenu = [NSMenu new];
    self.submenu = submenu;
    [submenu release];
}

- (void)setupSettingsMenuItem {
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                                              action:@selector(presentSettingsWindow:)
                                                       keyEquivalent:@","];
    settingsMenuItem.target = self;
    
    [self.submenu addItem:settingsMenuItem];
    [settingsMenuItem release];
}

- (void)presentSettingsWindow:(id)sender {
    SettingsWindow *settingsWindow = [SettingsWindow new];
    [settingsWindow makeKeyAndOrderFront:nullptr];
    [settingsWindow release];
}

@end
