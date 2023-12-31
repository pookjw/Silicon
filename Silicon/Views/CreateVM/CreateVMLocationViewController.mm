//
//  CreateVMLocationViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "CreateVMLocationViewController.hpp"
#import "NSTextField+LabelStyle.hpp"

@interface CreateVMLocationViewController () <NSToolbarDelegate>
@property (retain) NSStackView *stackView;
@property (retain) NSButton *createNewButton;
@property (retain) NSButton *addExistingButton;
@end

@implementation CreateVMLocationViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self CreateVMLocationViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self CreateVMLocationViewController_commonInit];
    }
    
    return self;
}

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

- (void)CreateVMLocationViewController_commonInit {
    self.title = @"Location";
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

@end
