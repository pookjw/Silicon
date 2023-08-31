//
//  RestoreImagesViewController.h
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import <Cocoa/Cocoa.h>
#import "RestoreImageModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface RestoreImagesViewController : NSViewController
@property (readonly, retain) RestoreImageModel * _Nullable selectedRestoreModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
