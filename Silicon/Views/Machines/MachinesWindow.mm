//
//  MachinesWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "MachinesWindow.hpp"
#import "MachinesViewController.hpp"
#import "MachinesWindowModel.hpp"
#import <memory>

namespace _MachinesWindow {
namespace identifiers {
static NSToolbarIdentifier const toolbarIdentifier = @"MachinesWindow.toolbar";
static NSToolbarItemIdentifier const downloadIPSWItemIdentifier = @"MachinesWindow.toolbar.downloadIPSW";
static NSToolbarItemIdentifier const processIndicatorItemIdentifier = @"MachinesWindow.toolbar.progressIndicator";
}
}

@interface MachinesWindow () <NSToolbarDelegate, NSURLSessionTaskDelegate>
@property (retain) NSProgressIndicator * _Nullable progressIndicator;
@property (assign) std::shared_ptr<MachinesWindowModel> viewModel;
@property (assign) std::shared_ptr<Cancellable> downloadIPSWCancellable;
@end

@implementation MachinesWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.title = @"Machines";
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = YES;
        
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_MachinesWindow::identifiers::toolbarIdentifier];
        toolbar.delegate = self;
        toolbar.allowsUserCustomization = NO;
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        self.toolbar = toolbar;
        [toolbar release];
        
        MachinesViewController *contentViewController = [MachinesViewController new];
        self.contentViewController = contentViewController;
        [contentViewController release];
        
        NSProgressIndicator *progressIndicator = [NSProgressIndicator new];
        progressIndicator.usesThreadedAnimation = YES;
        progressIndicator.style = NSProgressIndicatorStyleSpinning;
        progressIndicator.indeterminate = NO;
        progressIndicator.displayedWhenStopped = YES;
        self.progressIndicator = progressIndicator;
        [progressIndicator release];
        
        auto viewModel = std::make_shared<MachinesWindowModel>();
        self.viewModel = viewModel;
    }
    
    return self;
}

- (void)dealloc {
    [_progressIndicator release];
    [super dealloc];
}

- (void)downloadIPSW:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel new];
    panel.canCreateDirectories = YES;
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = NO;
    
    NSModalResponse response = [panel runModal];
    
    if (response == NSModalResponseOK) {
        NSURL *url = panel.URL;
        
        [self.toolbar removeItemAtIndex:0];
        [self.toolbar insertItemWithItemIdentifier:_MachinesWindow::identifiers::processIndicatorItemIdentifier atIndex:0];
        
        NSProgressIndicator *progressIndicator = self.progressIndicator;
        auto progressHandler = [progressIndicator](NSProgress *progress) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                progressIndicator.observedProgress = progress;
            }];
        };
        
        auto completionHandler = [](NSError * _Nullable error) {
            NSLog(@"%@", error);
        };
        
        self.downloadIPSWCancellable = self.viewModel.get()->downloadIPSW(url, progressHandler, completionHandler);
    }
    
    [panel release];
}


#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        _MachinesWindow::identifiers::downloadIPSWItemIdentifier,
        _MachinesWindow::identifiers::processIndicatorItemIdentifier
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        _MachinesWindow::identifiers::downloadIPSWItemIdentifier
    ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:_MachinesWindow::identifiers::downloadIPSWItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.image = [NSImage imageWithSystemSymbolName:@"square.and.arrow.down" accessibilityDescription:nullptr];
        item.title = @"Donlowad IPSW";
        item.target = self;
        item.action = @selector(downloadIPSW:);
        
        return [item autorelease];
    } else if ([itemIdentifier isEqualToString:_MachinesWindow::identifiers::processIndicatorItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.view = self.progressIndicator;
        
        return [item autorelease];
    } else {
        return nullptr;
    }
}

@end
