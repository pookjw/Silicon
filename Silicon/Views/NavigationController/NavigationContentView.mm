//
//  NavigationContentView.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/31/23.
//

#import "NavigationContentView.hpp"
#import <memory>
#import <cinttypes>

@interface NavigationContentView ()
@property (assign) std::shared_ptr<std::uint8_t> context;
@end

@implementation NavigationContentView

- (instancetype)initWithDidChangeToolbarHandler:(std::function<void (NSToolbar * _Nullable)>)didChangeToolbarHandler {
    if (self = [super init]) {
        self.didChangeToolbarHandler = didChangeToolbarHandler;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _context = std::make_shared<std::uint8_t>();
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _context = std::make_shared<std::uint8_t>();
    }
    
    return self;
}

- (void)dealloc {
    [self.window removeObserver:self forKeyPath:@"toolbar" context:_context.get()];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _context.get()) {
        if (!self.didChangeToolbarHandler.has_value()) return;
        
        id _Nullable newValue = change[NSKeyValueChangeNewKey];
        if ([newValue isEqual:[NSNull null]]) newValue = nullptr;
        auto toolbar = static_cast<NSToolbar * _Nullable>(newValue);
        self.didChangeToolbarHandler.value()(toolbar);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [self.window removeObserver:self forKeyPath:@"toolbar" context:_context.get()];
    [super viewWillMoveToWindow:newWindow];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self.window addObserver:self forKeyPath:@"toolbar" options:NSKeyValueObservingOptionNew context:_context.get()];
    
    if (self.didChangeToolbarHandler.has_value()) {
        self.didChangeToolbarHandler.value()(self.window.toolbar);
    }
}

@end
