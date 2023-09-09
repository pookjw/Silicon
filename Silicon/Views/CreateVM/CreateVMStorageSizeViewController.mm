//
//  CreateVMStorageSizeViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import "CreateVMStorageSizeViewController.hpp"
#import "SVStorageSizeEditor.hpp"
#import <cmath>

@interface CreateVMStorageSizeViewController ()
@property (retain) SVStorageSizeEditor *storageSizeEditor;
@end

@implementation CreateVMStorageSizeViewController

- (instancetype)initWithNibName:(nullable NSNibName)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self CreateVMDiskConfigurationViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self CreateVMDiskConfigurationViewController_commonInit];
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
}

- (void)CreateVMDiskConfigurationViewController_commonInit {
    self.title = @"Configure Disk";
}

- (void)setupStorageSizeEditor {
    SVStorageSizeEditor *storageSizeEditor = [SVStorageSizeEditor new];
    storageSizeEditor.storageUnits = @[
        NSUnitInformationStorage.gigabytes,
        NSUnitInformationStorage.gibibytes,
        NSUnitInformationStorage.terabytes,
        NSUnitInformationStorage.tebibytes
    ];
    storageSizeEditor.target = self;
    storageSizeEditor.action = @selector(didTriggerStorageSizeEditor:);
    storageSizeEditor.continuous = NO;
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

- (std::uint64_t)storageSize {
    return self.storageSizeEditor.storageSize;
}

- (void)didTriggerStorageSizeEditor:(SVStorageSizeEditor *)sender {
    [self.delegate createVirtualMachineStorageSizeViewController:self didChangeStorageSize:sender.storageSize];
}

@end
