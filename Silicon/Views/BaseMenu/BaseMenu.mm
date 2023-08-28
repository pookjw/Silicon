//
//  BaseMenu.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "BaseMenu.hpp"

#import "AppMenuItem.hpp"

@interface BaseMenu ()
@end

@implementation BaseMenu

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super initWithTitle:title]) {
        [self BaseMenu_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self BaseMenu_commonInit];
    }
    
    return self;
}

- (void)BaseMenu_commonInit {
    [self setupAppMenuItem];
}

- (void)setupAppMenuItem {
    AppMenuItem *appMenuItem = [AppMenuItem new];
    [self addItem:appMenuItem];
    [appMenuItem release];
}

@end
