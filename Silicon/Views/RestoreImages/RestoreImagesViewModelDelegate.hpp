//
//  RestoreImagesViewModelDelegate.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import <CoreData/CoreData.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface RestoreImagesViewModelDelegate : NSObject <NSFetchedResultsControllerDelegate>
@property (assign) std::function<void (NSFetchedResultsController *controller, NSDiffableDataSourceSnapshot<NSString *, NSManagedObjectID *> *snapshot)> controllerDidChangeContentWithSnapshot;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
