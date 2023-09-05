//
//  VMsViewModelDelegate.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <CoreData/CoreData.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VMsViewModelDelegate : NSObject <NSFetchedResultsControllerDelegate>
@property (assign) std::function<void (NSFetchedResultsController *controller, NSDiffableDataSourceSnapshot<NSString *, NSManagedObjectID *> *snapshot)> controllerDidChangeContentWithSnapshot;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
