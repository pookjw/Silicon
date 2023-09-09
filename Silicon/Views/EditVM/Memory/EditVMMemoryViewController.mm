//
//  EditVMMemoryViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import "EditVMMemoryViewController.hpp"
#import "SVStorageSizeEditor.hpp"
#import "EditVMMemoryViewModel.hpp"
#import <memory>

@interface EditVMMemoryViewController ()
@property (retain) SVStorageSizeEditor *storageSizeEditor;
@property (assign) std::shared_ptr<EditVMMemoryViewModel> viewModel;
@end

@implementation EditVMMemoryViewController

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super initWithNibName:nullptr bundle:nullptr]) {
        _viewModel = std::make_shared<EditVMMemoryViewModel>(virtualMachineMacModel);
    }
    
    return self;
}

- (void)dealloc {
    [_storageSizeEditor release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStorageSizeEditor];
    [self loadMemorySize];
}

- (void)setupStorageSizeEditor {
    SVStorageSizeEditor *storageSizeEditor = [SVStorageSizeEditor new];
    storageSizeEditor.storageUnits = @[
        NSUnitInformationStorage.gigabytes
    ];
    storageSizeEditor.continuous = NO;
    storageSizeEditor.target = self;
    storageSizeEditor.action = @selector(didTriggerStorageSizeEditor:);
    storageSizeEditor.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:storageSizeEditor];
    [NSLayoutConstraint activateConstraints:@[
        [storageSizeEditor.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [storageSizeEditor.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [storageSizeEditor.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [storageSizeEditor.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.storageSizeEditor = storageSizeEditor;
    [storageSizeEditor release];
}

- (void)loadMemorySize {
    SVStorageSizeEditor *storageSizeEditor = self.storageSizeEditor;
    storageSizeEditor.hidden = YES;
    self.viewModel.get()->memorySize(^(std::uint64_t memorySize) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            storageSizeEditor.hidden = NO;
            storageSizeEditor.storageSize = memorySize;
        }];
    });
}

- (void)didTriggerStorageSizeEditor:(SVStorageSizeEditor *)sender {
    self.viewModel.get()->setMemorySize(sender.storageSize, ^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
    });
}

@end
