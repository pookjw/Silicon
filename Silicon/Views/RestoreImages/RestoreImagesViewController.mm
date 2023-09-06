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
#import <cinttypes>

namespace _RestoreImagesViewController {
namespace identifiers {
static NSUserInterfaceItemIdentifier const collectionViewItemIdentifier = @"RestoreImagesCollectionViewItem";
}
}

@interface RestoreImagesViewController () <NSCollectionViewDelegate>
@property (retain) RestoreImageModel * _Nullable selectedRestoreImageModel;
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (retain) NSButton *addButton;
@property (retain) NSProgressIndicator *progressIndicator;
@property (retain) NSGridView *gridView;
@property (assign) std::shared_ptr<RestoreImagesViewModel> viewModel;
@property (assign) std::shared_ptr<Cancellable> addFromRemoteCancellable;
@property (assign) std::shared_ptr<std::uint8_t> selectionIndexPathsContext;
@end

@implementation RestoreImagesViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self RestoreImagesViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self RestoreImagesViewController_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_selectedRestoreImageModel release];
    [_scrollView release];
    [_collectionView removeObserver:self forKeyPath:@"selectionIndexPaths" context:_selectionIndexPathsContext.get()];
    [_collectionView release];
    [_addButton release];
    [_progressIndicator release];
    [_gridView release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _selectionIndexPathsContext.get()) {
        NSSet<NSIndexPath *> *selectionIndexPaths = static_cast<NSCollectionView *>(object).selectionIndexPaths;
        NSIndexPath * _Nullable firstIndexPath = selectionIndexPaths.allObjects.firstObject;
        if (!firstIndexPath) return;
        
        self.viewModel.get()->restoreImageModel(firstIndexPath, [self](RestoreImageModel * _Nullable result) {
            self.selectedRestoreImageModel = result;
            [self.delegate restoreImagesViewController:self didSelectRestoreImageModel:result];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)RestoreImagesViewController_commonInit {
    _selectionIndexPathsContext = std::make_shared<std::uint8_t>();
    self.title = @"Restore Images";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupCollectionView];
    [self setupAddButton];
    [self setupProgressIndicator];
    [self setupViewModel];
    [self setupGridView];
    
    self.viewModel.get()->initialize([self makeDataSource], [](NSError * _Nullable error) {
        NSLog(@"%@", error);
    });
}

- (void)setupScrollView {
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.drawsBackground = NO;
    
    self.scrollView = scrollView;
    [scrollView release];
}

- (void)setupCollectionView {
    NSCollectionViewCompositionalLayout *collectionViewLayout = [self makeCollectionViewLayout];
    NSCollectionView *collectionView = [NSCollectionView new];
    [collectionView addObserver:self forKeyPath:@"selectionIndexPaths" options:NSKeyValueObservingOptionNew context:_selectionIndexPathsContext.get()];
    collectionView.collectionViewLayout = collectionViewLayout;
    collectionView.backgroundColors = @[NSColor.clearColor];
    collectionView.selectable = YES;
    collectionView.allowsMultipleSelection = NO;
    collectionView.allowsEmptySelection = YES;
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
    
    self.addButton = addButton;
}

- (void)setupProgressIndicator {
    NSProgressIndicator *progressIndicator = [NSProgressIndicator new];
    progressIndicator.usesThreadedAnimation = YES;
    progressIndicator.style = NSProgressIndicatorStyleSpinning;
    progressIndicator.indeterminate = NO;
    progressIndicator.displayedWhenStopped = YES;
    
    self.progressIndicator = progressIndicator;
    [progressIndicator release];
}

- (void)setupGridView {
    NSGridView *gridView = [NSGridView new];
    gridView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [gridView addRowWithViews:@[self.scrollView]];
    [gridView addRowWithViews:@[self.progressIndicator, self.addButton]];
    
    [[gridView cellForView:self.scrollView].row mergeCellsInRange:NSMakeRange(0, 2)];
    
    [self.view addSubview:gridView];
    [NSLayoutConstraint activateConstraints:@[
        [gridView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [gridView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [gridView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [gridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    self.gridView = gridView;
    [gridView release];
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
    NSProgressIndicator *progressIndicator = self.progressIndicator;
    
    auto progressHandler = [progressIndicator](NSProgress *progress) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            progressIndicator.observedProgress = progress;
        }];
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
