//
//  DaemonViewController.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "DaemonViewController.hpp"
#import <xpc/xpc.h>
#import <objc/runtime.h>

@interface DaemonViewController () {
    xpc_session_t _session;
}
@property (retain) NSStackView *stackView;
@property (retain) NSButton *installButton;
@property (retain) NSButton *uninstallButton;
@property (retain) NSButton *verifyButton;
@property (readonly, retain) xpc_session_t session;
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
    
    if (xpc_get_type(_session) != XPC_TYPE_NULL) {
        xpc_session_cancel(_session);
    }
    xpc_release(_session);
    
    [super dealloc];
}

- (void)DeamonViewController_commonInit {
    _session = xpc_null_create();
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
    [self sendMessagWithFunction:"installDaemon" isReplyNeeded:YES];
}

- (void)didTriggerUninstallButton:(NSButton *)sender {
    [self sendMessagWithFunction:"uninstallDaemon" isReplyNeeded:YES];
}

- (void)didTriggerVerifyButton:(NSButton *)sender {
    [self sendMessagWithFunction:"ping" isReplyNeeded:NO];
}

- (xpc_session_t)session {
    if (xpc_get_type(_session) == XPC_TYPE_SESSION) {
        return _session;
    }
    
    xpc_rich_error_t error = NULL;
    xpc_session_t session = xpc_session_create_xpc_service("com.pookjw.Silicon.XPCService", nullptr, XPC_SESSION_CREATE_INACTIVE, &error);
    assert(!error);
    
    bool result = xpc_session_activate(session, &error);
    assert(!error);
    assert(result);
    
    xpc_release(_session);
    _session = session;
    return session;
}

- (void)sendMessagWithFunction:(const char *)function isReplyNeeded:(BOOL)flag {
    xpc_object_t functionObject = xpc_string_create(function);
    const char *keys [1] = {"function"};
    xpc_object_t values [1] = {functionObject};
    
    xpc_object_t dictionary = xpc_dictionary_create(keys, values, 1);
    xpc_release(functionObject);
    
    if (flag) {
        xpc_session_send_message_with_reply_async(self.session, dictionary, ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
            assert(!error);
            const char *desc = xpc_copy_description(reply);
            NSLog(@"%s", desc);
            delete desc;
        });
    } else {
        xpc_rich_error_t error = xpc_session_send_message(self.session, dictionary);
        assert(!error);
        xpc_release(error);
    }
    
    xpc_release(dictionary);
}

@end
