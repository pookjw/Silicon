//
//  RestoreImagesViewModelDelegate.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import "RestoreImagesViewModelDelegate.hpp"

@implementation RestoreImagesViewModelDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    self.controllerDidChangeContentWithSnapshot(controller, snapshot);
}

@end
