//
//  AppDelegate.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "AppDelegate.hpp"
#import "VirtualMachinesWindow.hpp"
#import "BaseMenu.hpp"
#import "PersistentDataManager.hpp"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    VirtualMachinesWindow *window = [VirtualMachinesWindow new];
    [window makeKeyAndOrderFront:nullptr];
    [window release];
    
    BaseMenu *baseMenu = [BaseMenu new];
    NSApp.mainMenu = baseMenu;
    [baseMenu release];
    
    PersistentDataManager::getInstance().initialize([](NSError * _Nullable error) {
        NSLog(@"%@", error);
    });
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
