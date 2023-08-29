//
//  RestoreImagesCollectionViewItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import "RestoreImagesCollectionViewItem.hpp"
#import "NSTextField+LabelStyle.hpp"

@interface RestoreImagesCollectionViewItem ()
@property (retain) RestoreImageModel *restoreImageModel;
@end

@implementation RestoreImagesCollectionViewItem

- (void)dealloc {
    [_restoreImageModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextField];
}

- (void)configureWithRestoreImageModel:(RestoreImageModel *)restoreImageModel {
    self.restoreImageModel = restoreImageModel;
    
    self.textField.stringValue = restoreImageModel.objectID.URIRepresentation.absoluteString;
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
