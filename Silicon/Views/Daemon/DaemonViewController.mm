//
//  DaemonViewController.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "DaemonViewController.hpp"
#import "XPCManager.hpp"
#import "VirtualMachineMacModel.hpp"
#import <Virtualization/Virtualization.h>

@interface DaemonViewController ()
@property (retain) NSStackView *stackView;
@property (retain) NSButton *installButton;
@property (retain) NSButton *uninstallButton;
@property (retain) NSButton *openFileButton;
@property (retain) NSButton *closeFileButton;
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
    [_openFileButton release];
    [_closeFileButton release];
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
    [self setupOpenFileButton];
    [self setupCloseFileButton];
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

- (void)setupOpenFileButton {
    NSButton *openFileButton = [NSButton buttonWithTitle:@"Open file" target:self action:@selector(didTriggerOpenFileButton:)];
    openFileButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:openFileButton];
    self.openFileButton = openFileButton;
}

- (void)setupCloseFileButton {
    NSButton *closeFileButton = [NSButton buttonWithTitle:@"Close file" target:self action:@selector(didTriggerCloseFileButton:)];
    closeFileButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:closeFileButton];
    self.closeFileButton = closeFileButton;
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

- (void)didTriggerOpenFileButton:(NSButton *)sender {
    XPCManager::getInstance().openFile("/dev/rdisk27", ^(std::variant<int, NSError *> result) {
        if (int *np = std::get_if<int>(&result)) {
            NSLog(@"%d", *np);
            VirtualMachineMacModel.tmp_fd = *np;
            
            NSFileHandle *handle = [[NSFileHandle alloc] initWithFileDescriptor:*np];
            NSError * _Nullable error = nullptr;
            VZDiskBlockDeviceStorageDeviceAttachment *a = [[VZDiskBlockDeviceStorageDeviceAttachment alloc] initWithFileHandle:handle readOnly:YES synchronizationMode:VZDiskSynchronizationModeFull error:&error];
            assert(!error);
            [handle release];
            NSLog(@"%@", a);
            [a release];
        } else if (NSError **error_p = std::get_if<NSError *>(&result)) {
            NSLog(@"%@", (*error_p).localizedDescription);
        }
    });
}

- (void)didTriggerCloseFileButton:(NSButton *)sender {
    std::variant<int, double> v {1.};
    
    if (double *d = std::get_if<double>(&v)) {
        NSLog(@"%f", *d);
    } else if (int *i = std::get_if<int>(&v)) {
        NSLog(@"%d", *i);
    }
}

@end
