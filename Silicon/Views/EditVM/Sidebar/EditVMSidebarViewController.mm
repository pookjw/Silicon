//
//  EditVMSidebarViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMSidebarViewController.hpp"
#import "EditVMSidebarViewModel.hpp"
#import "EditVMSidebarCollectionViewItem.hpp"
#import <memory>
#import <cinttypes>

namespace _EditVMSidebarViewController {
namespace identifiers {
static NSUserInterfaceItemIdentifier const collectionViewItemIdentifier = @"EditVMSidebarCollectionViewItem";
}
}

@interface EditVMSidebarViewController () <NSCollectionViewDelegate>
@property (retain) EditVMSidebarItemModel *selectedItemModel;
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (assign) std::shared_ptr<EditVMSidebarViewModel> viewModel;
@property (assign) std::shared_ptr<std::uint8_t> selectionIndexPathsContext;
@end

@implementation EditVMSidebarViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self EditVMSidebarViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self EditVMSidebarViewController_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_selectedItemModel release];
    [_scrollView release];
    [_collectionView removeObserver:self forKeyPath:@"selectionIndexPaths" context:_selectionIndexPathsContext.get()];
    [_collectionView release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _selectionIndexPathsContext.get()) {
        NSSet<NSIndexPath *> *selectionIndexPaths = static_cast<NSCollectionView *>(object).selectionIndexPaths;
        NSIndexPath * _Nullable firstIndexPath = selectionIndexPaths.allObjects.firstObject;
        if (!firstIndexPath) return;
        
        self.viewModel.get()->itemModel(firstIndexPath, ^(EditVMSidebarItemModel * _Nullable itemModel) {
            self.selectedItemModel = itemModel;
            [self.delegate editVMSidebarViewController:self didSelectItemModel:itemModel];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)EditVMSidebarViewController_commonInit {
    _viewModel = std::make_shared<EditVMSidebarViewModel>();
    _selectionIndexPathsContext = std::make_shared<std::uint8_t>();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupCollectionView];
    
    _viewModel.get()->load([self makeDataSource], ^{
        
    });
}

- (void)setupScrollView {
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.drawsBackground = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
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
    collectionView.allowsEmptySelection = NO;
    collectionView.delegate = self;
    
    [collectionView registerClass:EditVMSidebarCollectionViewItem.class forItemWithIdentifier:_EditVMSidebarViewController::identifiers::collectionViewItemIdentifier];
    
    self.scrollView.documentView = collectionView;
    self.collectionView = collectionView;
    [collectionView release];
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

- (EditVMSidebarViewModel::DataSource *)makeDataSource {
    EditVMSidebarViewModel::DataSource *dataSource = [[EditVMSidebarViewModel::DataSource alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, EditVMSidebarItemModel * _Nonnull itemIdentifier) {
        EditVMSidebarCollectionViewItem *item = [collectionView makeItemWithIdentifier:_EditVMSidebarViewController::identifiers::collectionViewItemIdentifier forIndexPath:indexPath];
        
        [item configureWithItemModel:itemIdentifier];
        
        return item;
    }];
    
    return [dataSource autorelease];
}

@end
