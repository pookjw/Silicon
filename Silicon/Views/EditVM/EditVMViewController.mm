//
//  EditVMViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMViewController.hpp"

@interface EditVMViewController ()
@property (retain) NSSplitViewController *splitViewController;
@end

@implementation EditVMViewController

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [self init]) {
        
    }
    
    return self;
}

- (void)dealloc {
    [_splitViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
