//
//  EditVMWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import "EditVMWindow.hpp"
#import "EditVMViewController.hpp"

@interface EditVMWindow () <NSToolbarDelegate>

@end

@implementation EditVMWindow

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super init]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.title = @"Untitled";
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = NO;
        self.contentMinSize = NSMakeSize(400.f, 400.f);
        
        EditVMViewController *contentViewController = [[EditVMViewController alloc] initWithVirtualMachineMacModel:virtualMachineMacModel];
        self.contentViewController = contentViewController;
        [contentViewController release];
    }
    
    return self;
}

@end
