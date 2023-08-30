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
    
    [restoreImageModel.managedObjectContext performBlock:^{
        NSDictionary<NSString *, id> *versions = restoreImageModel.versions;
        NSString *buildVersion = versions[_RestoreImageModel::versionKeys::buildVersionKey];
        NSNumber *majorVersion = versions[_RestoreImageModel::versionKeys::majorVersionKey];
        NSNumber *minorVersion = versions[_RestoreImageModel::versionKeys::minorVersionKey];
        NSNumber *patchVersion = versions[_RestoreImageModel::versionKeys::patchVersionKey];
        NSURL *URL = restoreImageModel.URL;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if (![restoreImageModel isEqual:self.restoreImageModel]) return;
            
            self.textField.stringValue = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", buildVersion, majorVersion, minorVersion, patchVersion, URL];
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
