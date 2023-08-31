//
//  CreateVirtualMachineLocationViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "CreateVirtualMachineLocationViewController.hpp"
#import "NSTextField+LabelStyle.hpp"

namespace _CreateVirtualMachineLocationViewController {
namespace identifiers {
static NSToolbarItemIdentifier const nextButtonItemIdentifier = @"CreateVirtualMachineLocationViewController.nextButtonItem";
}
}

@interface CreateVirtualMachineLocationViewController () <NSToolbarDelegate>
@property (retain) NSStackView *stackView;
@property (retain) NSButton *createNewButton;
@property (retain) NSButton *addExistingButton;
@end

@implementation CreateVirtualMachineLocationViewController

- (void)dealloc {
    [_stackView release];
    [_createNewButton release];
    [_addExistingButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStackView];
    [self setupCreateNewButton];
    [self setupAddExistingButton];
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeLeading;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stackView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor],
        [stackView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.stackView = stackView;
    [stackView release];
}

- (void)setupCreateNewButton {
    NSButton *createNewButton = [NSButton radioButtonWithTitle:@"Create new Virtual Machine"
                                                        target:self
                                                        action:@selector(didTriggerCreateNewButton:)];
    
    [self.stackView addArrangedSubview:createNewButton];
    self.createNewButton = createNewButton;
}

- (void)setupAddExistingButton {
    NSButton *addExsitingButton = [NSButton radioButtonWithTitle:@"Add existing Virtual Machine"
                                                          target:self
                                                          action:@selector(didTriggerAddExistingButton:)];
    
    [self.stackView addArrangedSubview:addExsitingButton];
    self.addExistingButton = addExsitingButton;
}

- (void)didTriggerCreateNewButton:(NSButton *)sender {
    self.createNewButton.state = NSControlStateValueOn;
    self.addExistingButton.state = NSControlStateValueOff;
}

- (void)didTriggerAddExistingButton:(NSButton *)sender {
    self.createNewButton.state = NSControlStateValueOff;
    self.addExistingButton.state = NSControlStateValueOn;
}

- (void)didTriggerNextButton:(NSButton *)sender {
    if (self.createNewButton.state == NSControlStateValueOn) {
        [self.delegate locationViewControllerCreateNewVirtualMachine:self];
    } else if (self.addExistingButton.state == NSControlStateValueOn) {
        [self.delegate locationViewControllerAddExistingVirtualMachine:self];
    }
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[_CreateVirtualMachineLocationViewController::identifiers::nextButtonItemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[_CreateVirtualMachineLocationViewController::identifiers::nextButtonItemIdentifier];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:_CreateVirtualMachineLocationViewController::identifiers::nextButtonItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.title = @"Next";
        item.target = self;
        item.action = @selector(didTriggerNextButton:);
        
        return [item autorelease];
    } else {
        return nullptr;
    }
}

@end
