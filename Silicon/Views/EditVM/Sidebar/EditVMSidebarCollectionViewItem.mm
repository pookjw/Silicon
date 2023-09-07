//
//  EditVMSidebarCollectionViewItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import "EditVMSidebarCollectionViewItem.hpp"
#import "NSTextField+LabelStyle.hpp"

@interface EditVMSidebarCollectionViewItem ()
@property (retain) NSStackView *stackView;
@end

@implementation EditVMSidebarCollectionViewItem

- (void)dealloc {
    [_stackView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStackView];
    [self setupImageView];
    [self setupTextField];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nullptr;
    self.textField.stringValue = [NSString string];
}

- (void)configureWithItemModel:(EditVMSidebarItemModel *)itemModel {
    self.imageView.image = itemModel.image;
    self.textField.stringValue = itemModel.text;
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.stackView = stackView;
    [stackView release];
}

- (void)setupImageView {
    NSImageView *imageView = [NSImageView new];
    [self.stackView addArrangedSubview:imageView];
    self.imageView = imageView;
    [imageView release];
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    [textField applyLabelStyle];
    [self.stackView addArrangedSubview:textField];
    self.textField = textField;
    [textField release];
}

@end
