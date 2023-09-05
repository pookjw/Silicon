//
//  VMsViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "VMsViewController.hpp"
#import "VMsViewModel.hpp"
#import "VMsCollectionViewItem.hpp"
#import "VMWindow.hpp"
#import <memory>

namespace _VirtualMachinesViewController {
namespace identifiers {
static NSUserInterfaceItemIdentifier const collectionViewItemIdentifier = @"VirtualMachinesCollectionViewItem";
}
}

@interface VMsViewController () <NSCollectionViewDelegate>
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (assign) std::shared_ptr<VMsViewModel> viewModel;
@end

@implementation VMsViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self VirtualMachinesViewController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self VirtualMachinesViewController_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_scrollView release];
    [_collectionView release];
    [super dealloc];
}

- (void)VirtualMachinesViewController_commonInit {
    _viewModel = std::make_shared<VMsViewModel>();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupCollectionView];
    
    self.viewModel.get()->initialize([self makeDataSource], [](NSError * _Nullable error) {
        NSLog(@"%@", error);
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
    collectionView.collectionViewLayout = collectionViewLayout;
    collectionView.backgroundColors = @[NSColor.clearColor];
    collectionView.selectable = YES;
    collectionView.allowsMultipleSelection = NO;
    collectionView.allowsEmptySelection = YES;
    collectionView.delegate = self;
    
    [collectionView registerClass:VMsCollectionViewItem.class forItemWithIdentifier:_VirtualMachinesViewController::identifiers::collectionViewItemIdentifier];
    
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

- (NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)makeDataSource {
    __block decltype(self) unretainedSelf = self;
    
    NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource = [[NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull itemIdentifier) {
        VMsCollectionViewItem *item = [collectionView makeItemWithIdentifier:_VirtualMachinesViewController::identifiers::collectionViewItemIdentifier forIndexPath:indexPath];
        VirtualMachineMacModel *virtualMachineMacModel = unretainedSelf.viewModel.get()->virtualMachineMacModel(indexPath);
        
        [item configureWithVirtualMachineMacModel:virtualMachineMacModel];
        
        return item;
    }];
    
    return [dataSource autorelease];
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        self.viewModel.get()->virtualMachineMacModel(obj, ^(VirtualMachineMacModel * _Nullable virtualMachineMacModel) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                VMWindow *window = [[VMWindow alloc] initWithVirtualMachineMacModel:virtualMachineMacModel];
                [window makeKeyAndOrderFront:nullptr];
                [window release];
            }];
        });
    }];
}

@end
