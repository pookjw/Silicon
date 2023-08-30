//
//  VirtualMachinesWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "VirtualMachinesWindow.hpp"
#import "VirtualMachinesViewController.hpp"
#import "CreateVirtualMachineViewController.hpp"

namespace _VirtualMachinesWindow {
namespace identifiers {
static NSToolbarIdentifier const toolbarIdentifier = @"MachinesWindow.toolbar";
static NSToolbarItemIdentifier const createVirtualMachineItemIdentifier = @"VirtualMachinesWindow.createVirtualMachine";
}
}

@interface VirtualMachinesWindow () <NSToolbarDelegate>
@end

@implementation VirtualMachinesWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.title = @"Machines";
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = YES;
        
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_VirtualMachinesWindow::identifiers::toolbarIdentifier];
        toolbar.delegate = self;
        toolbar.allowsUserCustomization = NO;
        toolbar.displayMode = NSToolbarDisplayModeIconOnly;
        self.toolbar = toolbar;
        [toolbar release];
        
        VirtualMachinesViewController *contentViewController = [VirtualMachinesViewController new];
        self.contentViewController = contentViewController;
        [contentViewController release];
    }
    
    return self;
}

- (void)didTriggerCreateVirtualMachineItem:(NSToolbarItem *)sender {
    CreateVirtualMachineViewController *viewController = [CreateVirtualMachineViewController new];
    [self.contentViewController presentViewControllerAsSheet:viewController];
    [viewController release];
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        _VirtualMachinesWindow::identifiers::createVirtualMachineItemIdentifier
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        _VirtualMachinesWindow::identifiers::createVirtualMachineItemIdentifier
    ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:_VirtualMachinesWindow::identifiers::createVirtualMachineItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.image = [NSImage imageWithSystemSymbolName:@"plus" accessibilityDescription:nullptr];
        item.target = self;
        item.action = @selector(didTriggerCreateVirtualMachineItem:);
        
        return [item autorelease];
    } else {
        return nullptr;
    }
}

@end
