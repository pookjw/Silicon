//
//  EditVMSidebarCollectionViewItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import "EditVMSidebarCollectionViewItem.hpp"
#import "NSTextField+LabelStyle.hpp"
#import <objc/message.h>

@interface EditVMSidebarCollectionViewItem ()
@property (retain) NSVisualEffectView *visualEffectView;
@property (retain) NSStackView *stackView;
@end

@implementation EditVMSidebarCollectionViewItem

- (void)dealloc {
    [_visualEffectView release];
    [_stackView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVisualEffectView];
    [self setupStackView];
    [self setupImageView];
    [self setupTextField];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateVisualEffectView];
//    self.textField.textColor = selected ? NSColor.alternateSelectedControlTextColor : NSColor.controlTextColor;
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)highlightState {
    [super setHighlightState:highlightState];
    [self updateVisualEffectView];
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

- (void)setupVisualEffectView {
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.view.bounds];
    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualEffectView.emphasized = YES;
    visualEffectView.material = NSVisualEffectMaterialSelection;
    visualEffectView.wantsLayer = YES;
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    visualEffectView.hidden = !self.isSelected;
    
    [self.view addSubview:visualEffectView];
    self.visualEffectView = visualEffectView;
    [visualEffectView release];
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
    [imageView setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [self.stackView addArrangedSubview:imageView];
    self.imageView = imageView;
    [imageView release];
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(textField, NSSelectorFromString(@"_setSemanticContext:"), 5);
    [textField setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    textField.textColor = NSColor.controlTextColor;
    [textField applyLabelStyle];
    [self.stackView addArrangedSubview:textField];
    self.textField = textField;
    [textField release];
}

- (void)updateVisualEffectView {
    BOOL isSelected = self.isSelected;
    NSCollectionViewItemHighlightState highlightState = self.highlightState;
    
    BOOL isHidden;
    if (isSelected) {
        isHidden = NO;
    } else if (highlightState != NSCollectionViewItemHighlightNone) {
        isHidden = NO;
    } else {
        isHidden = YES;
    }
    
    CGFloat opacity;
    if (isSelected) {
        opacity = 1.f;
    } else if (highlightState != NSCollectionViewItemHighlightNone) {
        opacity = 0.4f;
    } else {
        opacity = 1.f;
    }
    
    self.visualEffectView.hidden = isHidden;
    self.visualEffectView.layer.opacity = opacity;
}

@end
