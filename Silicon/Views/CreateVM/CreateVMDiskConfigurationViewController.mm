//
//  CreateVMDiskConfigurationViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import "CreateVMDiskConfigurationViewController.hpp"
#import "SVTextField.hpp"
#import <cmath>

@interface CreateVMDiskConfigurationViewController () <SVTextFieldDelegate>
@property (readonly, nonatomic) NSArray<NSUnitInformationStorage *> *storageUnits;
@property (copy, nonatomic) NSUnitInformationStorage *selectedStorageUnit;
@property (retain) NSStackView *stackView;
@property (retain) NSSlider *slider;
@property (retain) SVTextField *textField;
@property (retain) NSPopUpButton *popUpButton;
@property (retain) NSNumberFormatter *numberFormatter;
@end

@implementation CreateVMDiskConfigurationViewController

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
    [_selectedStorageUnit release];
    [_stackView release];
    [_slider release];
    [_textField release];
    [_popUpButton release];
    [_numberFormatter release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStackView];
    [self setupSlider];
    [self setupTextField];
    [self setupPopUpButton];
    
    [self setStorageSize:self.storageSize];
    [self setSelectedStorageUnit:self.selectedStorageUnit];
}

- (void)CreateVMDiskConfigurationViewController_commonInit {
    _storageSize = 128ull * 1000ull * 1000ull * 1000ull;
    _selectedStorageUnit = [NSUnitInformationStorage.gigabytes retain];
    
    _numberFormatter = [NSNumberFormatter new];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.title = @"Configure Disk";
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stackView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.stackView = stackView;
    [stackView release];
}

- (void)setupSlider {
    NSSlider *slider = [NSSlider new];
    slider.sliderType = NSSliderTypeLinear;
    slider.minValue = 0.;
    slider.maxValue = 3000.;
    slider.target = self;
    slider.action = @selector(didTriggerSlider:);
    
    [self.stackView addArrangedSubview:slider];
    self.slider = slider;
    [slider release];
}

- (void)setupTextField {
    SVTextField *textField = [SVTextField new];
    textField.delegate = self;
    
    [self.stackView addArrangedSubview:textField];
    [textField.widthAnchor constraintEqualToConstant:100.f].active = YES;
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textDidChange:)
                                               name:NSControlTextDidChangeNotification
                                             object:textField];
    
    self.textField = textField;
    [textField release];
}

- (void)setupPopUpButton {
    NSPopUpButton *popUpButton = [NSPopUpButton new];
    popUpButton.pullsDown = NO;
    popUpButton.autoenablesItems = YES;
    
    [self.storageUnits enumerateObjectsUsingBlock:^(NSUnitInformationStorage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual: NSUnitInformationStorage.gigabytes]) {
            NSMenuItem *gigabytesMenuItem = [[NSMenuItem alloc] initWithTitle:@"GB" action:@selector(didTriggerGigabytesMenuItem:) keyEquivalent:[NSString string]];
            gigabytesMenuItem.target = self;
            [popUpButton.menu addItem:gigabytesMenuItem];
            [gigabytesMenuItem release];
        } else if ([obj isEqual:NSUnitInformationStorage.gibibytes]) {
            NSMenuItem *gibibytesMenuItem = [[NSMenuItem alloc] initWithTitle:@"GiB" action:@selector(didTriggerGibibytesMenuItem:) keyEquivalent:[NSString string]];
            gibibytesMenuItem.target = self;
            [popUpButton.menu addItem:gibibytesMenuItem];
            [gibibytesMenuItem release];
        } else if ([obj isEqual:NSUnitInformationStorage.terabytes]) {
            NSMenuItem *terabytesMenuItem = [[NSMenuItem alloc] initWithTitle:@"TB" action:@selector(didTriggerTerabytesMenuItem:) keyEquivalent:[NSString string]];
            terabytesMenuItem.target = self;
            [popUpButton.menu addItem:terabytesMenuItem];
            [terabytesMenuItem release];
        } else if ([obj isEqual:NSUnitInformationStorage.tebibytes]) {
            NSMenuItem *tebibytesMenuItem = [[NSMenuItem alloc] initWithTitle:@"TiB" action:@selector(didTriggerTebibytesMenuItem:) keyEquivalent:[NSString string]];
            tebibytesMenuItem.target = self;
            [popUpButton.menu addItem:tebibytesMenuItem];
            [tebibytesMenuItem release];
        }
    }];
    
    [self.stackView addArrangedSubview:popUpButton];
    self.popUpButton = popUpButton;
    [popUpButton release];
}

- (NSArray<NSUnitInformationStorage *> *)storageUnits {
    return @[
        NSUnitInformationStorage.gigabytes,
        NSUnitInformationStorage.gibibytes,
        NSUnitInformationStorage.terabytes,
        NSUnitInformationStorage.tebibytes
    ];
}

- (void)setStorageSize:(std::uint64_t)storageSize {
    _storageSize = storageSize;
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:storageSize unit:NSUnitInformationStorage.bytes];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:self.selectedStorageUnit];
    [measurement release];
    
    self.slider.doubleValue = convertedMeasurement.doubleValue;
    NSNumber *number = [[NSNumber alloc] initWithDouble:convertedMeasurement.doubleValue];
    self.textField.stringValue = number.stringValue;
    [number release];
    
    [self.delegate createVirtualMachineDiskConfigurationViewController:self didChangeStorageSize:_storageSize];
}

- (void)setSelectedStorageUnit:(NSUnitInformationStorage *)storageUnit {
    [_selectedStorageUnit release];
    _selectedStorageUnit = [storageUnit copy];
    
    NSUInteger index = [self.storageUnits indexOfObject:_selectedStorageUnit];
    if (index != NSNotFound) {
        [self.popUpButton selectItemAtIndex:index];
    }
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:self.storageSize unit:NSUnitInformationStorage.bytes];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:_selectedStorageUnit];
    [measurement release];
    
    std::double_t value = convertedMeasurement.doubleValue;
    self.slider.doubleValue = value;
    NSNumber *number = [[NSNumber alloc] initWithFloat:value];
    self.textField.stringValue = number.stringValue;
    [number release];
}

- (void)didTriggerSlider:(NSSlider *)sender {
    std::float_t value = std::floor(sender.floatValue);
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.selectedStorageUnit];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:NSUnitInformationStorage.bytes];
    [measurement release];
    
    self.storageSize = convertedMeasurement.doubleValue;
    NSNumber *number = [[NSNumber alloc] initWithFloat:value];
    self.textField.stringValue = number.stringValue;
    [number release];
}

- (void)textDidChange:(NSNotification *)notification {
    auto textField = static_cast<NSTextField *>(notification.object);
    std::float_t value = textField.stringValue.floatValue;
    
    self.slider.floatValue = value;
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.selectedStorageUnit];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:NSUnitInformationStorage.bytes];
    [measurement release];
    self.storageSize = convertedMeasurement.doubleValue;
}

- (void)didTriggerGigabytesMenuItem:(NSMenuItem *)sender {
    self.selectedStorageUnit = NSUnitInformationStorage.gigabytes;
}

- (void)didTriggerGibibytesMenuItem:(NSMenuItem *)sender {
    self.selectedStorageUnit = NSUnitInformationStorage.gibibytes;
}

- (void)didTriggerTerabytesMenuItem:(NSMenuItem *)sender {
    self.selectedStorageUnit = NSUnitInformationStorage.terabytes;
}

- (void)didTriggerTebibytesMenuItem:(NSMenuItem *)sender {
    self.selectedStorageUnit = NSUnitInformationStorage.tebibytes;
}

#pragma mark - SVTextFieldDelegate

- (BOOL)textField:(SVTextField *)textField shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.stringValue stringByReplacingCharactersInRange:range withString:string];
    if (result.length == 0) {
        return YES;
    }
    
    NSNumber * _Nullable number = [self.numberFormatter numberFromString:result];
    return number;
}

@end
