//
//  DaemonViewController.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "DaemonViewController.hpp"
#import "XPCManager.hpp"

@interface DaemonViewController ()
@property (retain) NSStackView *stackView;
@property (retain) NSButton *installButton;
@property (retain) NSButton *uninstallButton;
@property (retain) NSButton *verifyButton;
@end

@implementation DaemonViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self DeamonViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self DeamonViewController_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_stackView release];
    [_installButton release];
    [_uninstallButton release];
    [_verifyButton release];
    [super dealloc];
}

- (void)DeamonViewController_commonInit {
    self.preferredContentSize = NSMakeSize(400.f, 400.f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStackView];
    [self setupInstallButton];
    [self setupUninstallButton];
    [self setupVerifyButton];
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    self.stackView = stackView;
    [stackView release];
}

- (void)setupInstallButton {
    NSButton *installButton = [NSButton buttonWithTitle:@"Install" target:self action:@selector(didTriggerInstallButton:)];
    installButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:installButton];
    self.installButton = installButton;
}

- (void)setupUninstallButton {
    NSButton *uninstallButton = [NSButton buttonWithTitle:@"Uninstall" target:self action:@selector(didTriggerUninstallButton:)];
    uninstallButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:uninstallButton];
    self.uninstallButton = uninstallButton;
}

- (void)setupVerifyButton {
    NSButton *verifyButton = [NSButton buttonWithTitle:@"Verify" target:self action:@selector(didTriggerVerifyButton:)];
    verifyButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:verifyButton];
    self.verifyButton = verifyButton;
}

- (void)didTriggerInstallButton:(NSButton *)sender {
    XPCManager::getInstance().installDaemon(^(NSError * _Nullable error) {
        assert(!error);
    });
}

- (void)didTriggerUninstallButton:(NSButton *)sender {
    XPCManager::getInstance().uninstallDaemon(^(NSError * _Nullable error) {
        assert(!error);
    });
}

- (void)didTriggerVerifyButton:(NSButton *)sender {
}

@end
