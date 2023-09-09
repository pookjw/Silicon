//
//  SVStorageSizeEditor.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import "SVStorageSizeEditor.hpp"
#import "SVSliderCell.hpp"
#import "SVTextField.hpp"
#import "SVStorageSizeEditorMenuItem.hpp"
#import <cmath>
#import <memory>

@interface SVStorageSizeEditor () <SVTextFieldDelegate>
@property (retain) NSStackView *stackView;
@property (retain) NSSlider *slider;
@property (retain) SVSliderCell *sliderCell;
@property (retain) SVTextField *textField;
@property (retain) NSPopUpButton *popUpButton;
@property (retain) NSNumberFormatter *numberFormatter;
@property (assign) std::shared_ptr<std::uint8_t> sliderCellContext;
@end

@implementation SVStorageSizeEditor

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self SVStorageEditor_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self SVStorageEditor_commonInit];
        self.selectedStorageUnit = [coder decodeObjectForKey:@"SVStorageSizeEditor.selectedStorageUnit"];
        self.storageUnits = [coder decodeObjectForKey:@"SVStorageSizeEditor.storageUnits"];
        [self setStorageSize:[coder decodeInt64ForKey:@"SVStorageSizeEditor.storageSize"] sendEvent:NO];
    }
    
    return self;
}

- (void)dealloc {
    [_stackView release];
    [_slider release];
    [_sliderCell release];
    [_textField release];
    [_popUpButton release];
    [_numberFormatter release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _sliderCellContext.get()) {
        if (!self.isContinuous) {
            [self didTriggerSlider:static_cast<NSSlider *>(static_cast<SVSliderCell *>(object).controlView) sendEvent:NO];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.selectedStorageUnit forKey:@"SVStorageSizeEditor.selectedStorageUnit"];
    [coder encodeObject:self.storageUnits forKey:@"SVStorageSizeEditor.storageUnits"];
    [coder encodeInt64:_storageSize forKey:@"SVStorageSizeEditor.storageSize"];
}

- (void)SVStorageEditor_commonInit {
    _storageSize = 128ull * 1000ull * 1000ull * 1000ull;
    _numberFormatter = [NSNumberFormatter new];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    [self setupStackView];
    [self setupSlider];
    [self setupTextField];
    [self setupPopUpButton];
    
    self.storageUnits = @[
        NSUnitInformationStorage.gigabytes,
        NSUnitInformationStorage.gibibytes,
        NSUnitInformationStorage.terabytes,
        NSUnitInformationStorage.tebibytes
    ];
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [stackView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stackView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor]
    ]];
    
    self.stackView = stackView;
    [stackView release];
}

- (void)setupSlider {
    SVSliderCell *sliderCell = [SVSliderCell new];
    NSSlider *slider = [NSSlider new];
    slider.cell = sliderCell;
    slider.sliderType = NSSliderTypeLinear;
    slider.minValue = 0.;
    slider.maxValue = 3000.;
    slider.target = self;
    slider.action = @selector(didTriggerSlider:);
    
    [sliderCell addObserver:self forKeyPath:@"continuousDoubleValue" options:NSKeyValueObservingOptionNew context:_sliderCellContext.get()];
    
    [self.stackView addArrangedSubview:slider];
    self.slider = slider;
    self.sliderCell = sliderCell;
    [slider release];
    [sliderCell release];
}

- (void)setupTextField {
    SVTextField *textField = [SVTextField new];
    textField.delegate = self;
    textField.target = self;
    textField.action = @selector(didTriggerTextField:);
    
    [self.stackView addArrangedSubview:textField];
    [textField.widthAnchor constraintEqualToConstant:100.f].active = YES;
    
    self.textField = textField;
    [textField release];
}

- (void)setupPopUpButton {
    NSPopUpButton *popUpButton = [NSPopUpButton new];
    popUpButton.pullsDown = NO;
    popUpButton.autoenablesItems = NO;
    
    [self.stackView addArrangedSubview:popUpButton];
    self.popUpButton = popUpButton;
    [popUpButton release];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.slider.enabled = enabled;
    self.textField.enabled = enabled;
    
    if (enabled) {
        self.popUpButton.enabled = self.popUpButton.menu.itemArray.count > 1;
    } else {
        self.popUpButton.enabled = NO;
    }
}

- (void)setContinuous:(BOOL)continuous {
    [super setContinuous:continuous];
    self.slider.continuous = continuous;
    self.textField.continuous = continuous;
    self.popUpButton.continuous = continuous;
}

- (NSArray<NSUnitInformationStorage *> *)storageUnits {
    NSMutableArray<NSUnitInformationStorage *> *results = [NSMutableArray<NSUnitInformationStorage *> new];
    
    [self.popUpButton.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:static_cast<SVStorageSizeEditorMenuItem *>(obj).storageUnit];
    }];
    
    return [results autorelease];
}

- (void)setStorageUnits:(NSArray<NSUnitInformationStorage *> *)storageUnits {
    if ([self.storageUnits isEqual:storageUnits]) return;
    
    NSUInteger count = storageUnits.count;
    
    if (count == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"storageUnits must be have more than 1 element." userInfo:nullptr];
    } else {
        BOOL shouldUpdateSelectedStorageUnit = ![storageUnits containsObject:static_cast<SVStorageSizeEditorMenuItem *>(self.popUpButton.selectedItem).storageUnit];
        
        NSMenu *menu = [NSMenu new];
        
        [storageUnits enumerateObjectsUsingBlock:^(NSUnitInformationStorage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SVStorageSizeEditorMenuItem *menuItem = [[SVStorageSizeEditorMenuItem alloc] initWithStorageUnit:obj action:@selector(didTriggerMenuItem:) keyEquivalent:[NSString string]];
            menuItem.target = self;
            [menu addItem:menuItem];
            [menuItem release];
        }];
        
        self.popUpButton.menu = menu;
        [menu release];
        self.popUpButton.enabled = (count > 1);
        
        if (shouldUpdateSelectedStorageUnit) {
            self.selectedStorageUnit = storageUnits.firstObject;
        }
    }
}

- (void)setStorageSize:(std::uint64_t)storageSize {
    [self setStorageSize:storageSize sendEvent:YES];
}

- (NSUnitInformationStorage *)selectedStorageUnit {
    return static_cast<SVStorageSizeEditorMenuItem *>(self.popUpButton.selectedItem).storageUnit;
}

- (void)setSelectedStorageUnit:(NSUnitInformationStorage *)storageUnit {
    [self.popUpButton.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([static_cast<SVStorageSizeEditorMenuItem *>(obj).storageUnit isEqual:storageUnit]) {
            [self.popUpButton selectItem:obj];
            *stop = YES;
        }
    }];
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:self.storageSize unit:NSUnitInformationStorage.bytes];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:storageUnit];
    [measurement release];
    
    std::double_t value = convertedMeasurement.doubleValue;
    self.slider.doubleValue = value;
    NSNumber *number = [[NSNumber alloc] initWithDouble:value];
    self.textField.stringValue = number.stringValue;
    [number release];
}

- (void)setStorageSize:(std::uint64_t)storageSize sendEvent:(BOOL)flag {
    if (flag) {
        [self willChangeValueForKey:@"storageSize"];
    }
    
    _storageSize = storageSize;
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:storageSize unit:NSUnitInformationStorage.bytes];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:self.selectedStorageUnit];
    [measurement release];
    
    self.slider.doubleValue = convertedMeasurement.doubleValue;
    NSNumber *number = [[NSNumber alloc] initWithDouble:convertedMeasurement.doubleValue];
    self.textField.stringValue = number.stringValue;
    [number release];
    
    if (flag) {
        [self sendAction:self.action to:self.target];
        [self didChangeValueForKey:@"storageSize"];
    }
}

- (void)didTriggerSlider:(NSSlider *)sender sendEvent:(BOOL)flag {
    std::double_t value = std::floor(sender.doubleValue);
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.selectedStorageUnit];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:NSUnitInformationStorage.bytes];
    [measurement release];
    
    [self setStorageSize:convertedMeasurement.doubleValue sendEvent:flag];
    NSNumber *number = [[NSNumber alloc] initWithDouble:value];
    self.textField.stringValue = number.stringValue;
    [number release];
}

- (void)didTriggerSlider:(NSSlider *)sender {
    [self didTriggerSlider:sender sendEvent:YES];
}

- (void)didTriggerTextField:(SVTextField *)sender {
    std::double_t value = sender.stringValue.doubleValue;
    
    self.slider.doubleValue = value;
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.selectedStorageUnit];
    NSMeasurement *convertedMeasurement = [measurement measurementByConvertingToUnit:NSUnitInformationStorage.bytes];
    [measurement release];
    [self setStorageSize:convertedMeasurement.doubleValue sendEvent:YES];
}

- (void)didTriggerMenuItem:(SVStorageSizeEditorMenuItem *)sender {
    self.selectedStorageUnit = sender.storageUnit;
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
