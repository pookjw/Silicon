//
//  VirtualMachinesCollectionViewItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VirtualMachinesCollectionViewItem.hpp"
#import "NSTextField+LabelStyle.hpp"

@interface VirtualMachinesCollectionViewItem ()
@property (retain) VirtualMachineMacModel *virtualMachineMacModel;
@end

@implementation VirtualMachinesCollectionViewItem

- (void)dealloc {
    [_virtualMachineMacModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextField];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textField.stringValue = [NSString string];
}

- (void)configureWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    self.virtualMachineMacModel = virtualMachineMacModel;
    
    [virtualMachineMacModel.managedObjectContext performBlock:^{
        NSURL *bundleURL = virtualMachineMacModel.bundleURL;
        NSString *path = bundleURL.path;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if (![virtualMachineMacModel isEqual:self.virtualMachineMacModel]) return;
            
            self.textField.stringValue = path;
        }];
    }];
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    [textField applyLabelStyle];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:textField];
    [NSLayoutConstraint activateConstraints:@[
        [textField.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [textField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [textField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.textField = textField;
    [textField release];
}

@end