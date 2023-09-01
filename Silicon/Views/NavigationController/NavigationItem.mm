//
//  NavigationItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/1/23.
//

#import "NavigationItem.hpp"

@implementation NavigationItem

- (instancetype)init {
    if (self = [super init]) {
        [_navigationalItemIdentifiers release];
        _navigationalItemIdentifiers = [NSArray<NSToolbarItemIdentifier> new];
        
        [_itemIdentifiers release];
        _itemIdentifiers = [NSArray<NSToolbarItemIdentifier> new];
    }
    
    return self;
}

- (void)dealloc {
    [_navigationalItemIdentifiers release];
    [_itemIdentifiers release];
    [super dealloc];
}

@end
