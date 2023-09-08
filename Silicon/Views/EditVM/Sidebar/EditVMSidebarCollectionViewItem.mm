//
//  EditVMSidebarCollectionViewItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import "EditVMSidebarCollectionViewItem.hpp"
#import "NSTextField+LabelStyle.hpp"

@interface EditVMSidebarCollectionViewItem ()
@property (retain) NSBox *box;
@property (retain) NSStackView *stackView;
@end

@implementation EditVMSidebarCollectionViewItem

- (void)dealloc {
    [_box release];
    [_stackView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBox];
    [self setupStackView];
    [self setupImageView];
    [self setupTextField];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)highlightState {
    [super setHighlightState:highlightState];
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

- (void)setupBox {
    NSBox *box = [NSBox new];
    box.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:box];
    [NSLayoutConstraint activateConstraints:@[
        [box.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [box.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [box.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [box.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.box = box;
    [box release];
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.box addSubview:stackView];
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
    [imageView setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [self.stackView addArrangedSubview:imageView];
    self.imageView = imageView;
    [imageView release];
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    [textField setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [textField applyLabelStyle];
    [self.stackView addArrangedSubview:textField];
    self.textField = textField;
    [textField release];
}

@end
