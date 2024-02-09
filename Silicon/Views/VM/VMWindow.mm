//
//  VMWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VMWindow.hpp"
#import "VMViewController.hpp"

namespace _VirtualMachineWindow {
    namespace identifiers {
        static NSToolbarIdentifier const toolbarIdentifier = @"VirtualMachineWindow.toolbar";
    }
}

@interface VMWindow () <NSToolbarDelegate>
@end

@implementation VMWindow

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super init]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = NO;
        self.title = @"Untitled";
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = NO;
        self.contentMinSize = NSMakeSize(400.f, 400.f);
        
        VMViewController *contentViewController = [[VMViewController alloc] initWithVirtualMachineMacModel:virtualMachineMacModel];
        self.contentViewController = contentViewController;
        [contentViewController release];
    }
    
    return self;
}

@end
