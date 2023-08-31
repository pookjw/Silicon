//
//  NavigationContentView.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/31/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import <optional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NavigationContentView : NSView
@property (assign) std::optional<std::function<void (NSToolbar * _Nullable)>> didChangeToolbarHandler;
- (instancetype)initWithDidChangeToolbarHandler:(std::function<void (NSToolbar * _Nullable)>)didChangeToolbarHandler;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
