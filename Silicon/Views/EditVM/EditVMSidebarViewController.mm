//
//  EditVMSidebarViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMSidebarViewController.hpp"

@interface EditVMSidebarViewController ()
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@end

@implementation EditVMSidebarViewController

- (void)dealloc {
    [_scrollView release];
    [_collectionView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setupScrollView {
    
}

@end
