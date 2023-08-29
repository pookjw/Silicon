//
//  RestoreImagesViewController.m
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "RestoreImagesViewController.hpp"
#import "RestoreImagesViewModel.hpp"
#import "RestoreImagesCollectionViewItem.hpp"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <memory>

namespace _RestoreImagesViewController {
namespace identifiers {
static NSUserInterfaceItemIdentifier const collectionViewItemIdentifier = @"RestoreImagesCollectionViewItem";
}
}

@interface RestoreImagesViewController () <NSCollectionViewDelegate>
@property (retain) NSStackView *stackView;
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (retain) NSButton *addButton;
@property (assign) std::shared_ptr<RestoreImagesViewModel> viewModel;
@property (assign) std::shared_ptr<Cancellable> addFromRemoteCancellable;
@end

@implementation RestoreImagesViewController

- (void)dealloc {
    [_stackView release];
    [_scrollView release];
    [_collectionView release];
    [_addButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStackView];
    [self setupScrollView];
    [self setupCollectionView];
    [self setupAddButton];
    [self setupViewModel];
    
    self.viewModel.get()->initialize([self makeDataSource], [](NSError * _Nullable error) {
        NSLog(@"%@", error);
    });
}

- (void)setupStackView {
    NSStackView *stackView = [NSStackView new];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
//    stackView.alignment = NSLayoutAttributeWidth;
    stackView.distribution = NSStackViewDistributionFillProportionally;
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

- (void)setupScrollView {
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.drawsBackground = NO;
    
    [self.stackView addArrangedSubview:scrollView];
    
    self.scrollView = scrollView;
    [scrollView release];
}

- (void)setupCollectionView {
    NSCollectionViewCompositionalLayout *collectionViewLayout = [self makeCollectionViewLayout];
    NSCollectionView *collectionView = [NSCollectionView new];
    collectionView.collectionViewLayout = collectionViewLayout;
    collectionView.backgroundColors = @[NSColor.clearColor];
    collectionView.selectable = YES;
    collectionView.allowsMultipleSelection = NO;
    collectionView.delegate = self;
    
    [collectionView registerClass:RestoreImagesCollectionViewItem.class forItemWithIdentifier:_RestoreImagesViewController::identifiers::collectionViewItemIdentifier];
    
    self.scrollView.documentView = collectionView;
    self.collectionView = collectionView;
    [collectionView release];
}

- (void)setupAddButton {
    NSButton *addButton = [NSButton buttonWithImage:[NSImage imageWithSystemSymbolName:@"plus" accessibilityDescription:nullptr]
                                             target:self
                                             action:@selector(didTriggerAddButton:)];
    
    addButton.bezelStyle = NSBezelStyleSmallSquare;
    
    [self.stackView addArrangedSubview:addButton];
    
    self.addButton = addButton;
}

- (void)setupViewModel {
    std::shared_ptr<RestoreImagesViewModel> viewModel = std::make_shared<RestoreImagesViewModel>();
    self.viewModel = viewModel;
}

- (void)didTriggerAddButton:(NSButton *)sender {
    NSMenu *menu = [NSMenu new];
    
    NSMenuItem *addFromLocalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add from Local..." action:@selector(didTriggerAddFromLocalMenuItem:) keyEquivalent:[NSString string]];
    addFromLocalMenuItem.target = self;
    [menu addItem:addFromLocalMenuItem];
    [addFromLocalMenuItem release];
    
    NSMenuItem *addFromRemoteMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add from Remote..." action:@selector(didTriggerAddFromRemoteMenuItem:) keyEquivalent:[NSString string]];
    addFromRemoteMenuItem.target = self;
    [menu addItem:addFromRemoteMenuItem];
    [addFromRemoteMenuItem release];
    
    [NSMenu popUpContextMenu:menu withEvent:NSApp.currentEvent forView:sender];
    [menu release];
}

- (void)didTriggerAddFromLocalMenuItem:(NSMenuItem *)sender {
    NSOpenPanel *panel = [NSOpenPanel new];
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = YES;
    panel.allowedContentTypes = @[[UTType typeWithFilenameExtension:@"ipsw"]];
    panel.allowsOtherFileTypes = YES;
    
    NSModalResponse response = [panel runModal];
    
    if (response == NSModalResponseOK) {
        NSArray<NSURL *> *urls = panel.URLs;
        self.viewModel.get()->addFromLocalIPSWURLs(urls, [](NSError * _Nullable error) {
            NSLog(@"%@", error);
        });
    }
    
    [panel release];
}

- (void)didTriggerAddFromRemoteMenuItem:(NSMenuItem *)sender {
    auto progressHandler = [](NSProgress *progress) {
        NSLog(@"%@", progress);
    };
    
    auto completionHandler = [](NSError * _Nullable error) {
        NSLog(@"%@", error);
    };
    
    self.addFromRemoteCancellable = self.viewModel.get()->addFromRemote(progressHandler, completionHandler);
}

- (NSCollectionViewCompositionalLayout *)makeCollectionViewLayout {
    NSCollectionViewCompositionalLayoutConfiguration *configuration = [NSCollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = NSCollectionViewScrollDirectionVertical;
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment> _Nonnull environment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                          heightDimension:[NSCollectionLayoutDimension estimatedDimension:44.f]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                           heightDimension:[NSCollectionLayoutDimension estimatedDimension:44.f]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:groupSize subitem:item count:1];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        return section;
    }
                                                                                                                       configuration:configuration];
    
    [configuration release];
    
    return [collectionViewLayout autorelease];
}

- (NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)makeDataSource {
    __block decltype(self) unretainedSelf = self;
    
    NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource = [[NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull itemIdentifier) {
        RestoreImagesCollectionViewItem *item = [collectionView makeItemWithIdentifier:_RestoreImagesViewController::identifiers::collectionViewItemIdentifier forIndexPath:indexPath];
        RestoreImageModel *restoreImageModel = unretainedSelf.viewModel.get()->restoreImageModel(indexPath);
        
        [item configureWithRestoreImageModel:restoreImageModel];
        
        return item;
    }];
    
    return [dataSource autorelease];
}

@end
