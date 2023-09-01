//
//  NavigationItem.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/1/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NavigationItem : NSObject
@property (copy) NSArray<NSToolbarItemIdentifier> *navigationalItemIdentifiers;
@property (copy) NSArray<NSToolbarItemIdentifier> *itemIdentifiers;
@property (assign) std::function<NSToolbarItem * _Nullable (NSToolbarItemIdentifier)> toolbarItemHandler;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
