//
//  VirtualMachineWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VirtualMachineWindow.hpp"
#import "VirtualMachineViewController.hpp"

namespace _VirtualMachineWindow {
    namespace identifiers {
        static NSToolbarIdentifier const toolbarIdentifier = @"VirtualMachineWindow.toolbar";
    }
}

@interface VirtualMachineWindow () <NSToolbarDelegate>
@end

@implementation VirtualMachineWindow

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super init]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.title = @"Untitled";
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = NO;
        self.contentMinSize = NSMakeSize(400.f, 400.f);
        
        VirtualMachineViewController *contentViewController = [[VirtualMachineViewController alloc] initWithVirtualMachineMacModel:virtualMachineMacModel];
        self.contentViewController = contentViewController;
        [contentViewController release];
    }
    
    return self;
}

@end
