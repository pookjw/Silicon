//
//  RestoreImagesCollectionViewItem.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import <Cocoa/Cocoa.h>
#import "RestoreImageModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface RestoreImagesCollectionViewItem : NSCollectionViewItem
- (void)configureWithRestoreImageModel:(RestoreImageModel *)restoreImageModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
