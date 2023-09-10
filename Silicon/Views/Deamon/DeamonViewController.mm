//
//  DeamonViewController.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "DeamonViewController.hpp"
#import <xpc/xpc.h>
#import <objc/runtime.h>
#import <string>
#import <array>
#import <algorithm>

@interface DeamonViewController ()
@property (retain) NSStackView *stackView;
@property (retain) NSButton *installButton;
@property (retain) NSButton *uninstallButton;
@property (retain) NSButton *verifyButton;
@end

@implementation DeamonViewController

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
    NSButton *verifyButton = [NSButton buttonWithTitle:@"Verify" target:self action:@selector(didTriggerUninstallButton:)];
    verifyButton.bezelStyle = NSBezelStylePush;
    
    [self.stackView addArrangedSubview:verifyButton];
    self.verifyButton = verifyButton;
}

- (void)didTriggerInstallButton:(NSButton *)sender {
    xpc_rich_error_t error = NULL;
    xpc_session_t session = xpc_session_create_xpc_service("com.pookjw.Silicon.XPCService", nullptr, XPC_SESSION_CREATE_INACTIVE, &error);
    
    if (error) {
        char *description = xpc_rich_error_copy_description(error);
        xpc_release(error);
        xpc_release(session);
        NSLog(@"%s", description);
        delete description;
        return;
    }
    
    bool result = xpc_session_activate(session, &error);
    NSLog(@"%d", result);
    
    if (error) {
        char *description = xpc_rich_error_copy_description(error);
        xpc_release(error);
        xpc_release(session);
        NSLog(@"%s", description);
        delete description;
        return;
    }

    std::array<const char *, 2> keys = {"firstNumber", "secondNumber"};
    std::array<xpc_object_t, 2> values = {
        xpc_int64_create(1),
        xpc_int64_create(2)
    };
    
    xpc_object_t dictionary = xpc_dictionary_create(keys.data(), values.data(), 2);
    std::for_each(values.cbegin(), values.cend(), [](xpc_object_t object) {
        xpc_release(object);
    });
    
//    bool result_2 = xpc_session_send_message(session, dictionary);
    xpc_session_send_message_with_reply_async(session, dictionary, ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
        const char *desc = xpc_copy_description(reply);
        NSLog(@"%s", desc);
        delete desc;
    });
    
    xpc_release(error);
    xpc_release(dictionary);
//    xpc_release(session);
}

- (void)didTriggerUninstallButton:(NSButton *)sender {
    
}

- (void)didTriggerVerifyButton:(NSButton *)sender {
    
}

@end
