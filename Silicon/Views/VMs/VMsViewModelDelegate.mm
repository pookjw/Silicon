//
//  VMsViewModelDelegate.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VMsViewModelDelegate.hpp"

@implementation VMsViewModelDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    self.controllerDidChangeContentWithSnapshot(controller, snapshot);
}

@end
