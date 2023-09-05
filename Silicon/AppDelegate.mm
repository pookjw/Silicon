//
//  AppDelegate.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "AppDelegate.hpp"
#import "VMsWindow.hpp"
#import "BaseMenu.hpp"
#import "PersistentDataManager.hpp"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    PersistentDataManager::getInstance().initialize(^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    });
    
    VMsWindow *window = [VMsWindow new];
    [window makeKeyAndOrderFront:nullptr];
    [window release];
    
    BaseMenu *baseMenu = [BaseMenu new];
    NSApp.mainMenu = baseMenu;
    [baseMenu release];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
