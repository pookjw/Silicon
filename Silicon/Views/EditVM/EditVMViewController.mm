//
//  EditVMViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMViewController.hpp"
#import "EditVMSidebarViewController.hpp"

@interface EditVMViewController ()
@property (retain) NSSplitViewController *splitViewController;
@property (retain) NSSplitViewItem *sidebarItem;
@property (retain) EditVMSidebarViewController *sidebarViewController;
@property (retain) VirtualMachineMacModel *model;
@end

@implementation EditVMViewController

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [self init]) {
        self.model = virtualMachineMacModel;
    }
    
    return self;
}

- (void)dealloc {
    [_splitViewController release];
    [_sidebarItem release];
    [_sidebarViewController release];
    [_model release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSplitViewController];
    [self setupSidebarViewController];
}

- (void)setupSplitViewController {
    NSSplitViewController *splitViewController = [NSSplitViewController new];
    splitViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:splitViewController.view];
    [NSLayoutConstraint activateConstraints:@[
        [splitViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [splitViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [splitViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [splitViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self addChildViewController:splitViewController];
    
    self.splitViewController = splitViewController;
    [splitViewController release];
}

- (void)setupSidebarViewController {
    EditVMSidebarViewController *sidebarViewController = [EditVMSidebarViewController new];
    NSSplitViewItem *sidebarItem = [NSSplitViewItem sidebarWithViewController:sidebarViewController];
    
    sidebarItem.canCollapse = NO;
    [self.splitViewController addSplitViewItem:sidebarItem];
    
    self.sidebarItem = sidebarItem;
    self.sidebarViewController = sidebarViewController;
    [sidebarViewController release];
}

@end
