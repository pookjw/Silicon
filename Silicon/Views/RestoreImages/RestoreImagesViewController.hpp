//
//  RestoreImagesViewController.h
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import <Cocoa/Cocoa.h>
#import "RestoreImageModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class RestoreImagesViewController;
@protocol RestoreImagesViewControllerDelegate <NSObject>
- (void)restoreImagesViewController:(RestoreImagesViewController *)viewControoler didSelectRestoreImageModel:(RestoreImageModel * _Nullable)restoreImageModel;
@end

@interface RestoreImagesViewController : NSViewController
@property (readonly, retain) RestoreImageModel * _Nullable selectedRestoreImageModel;
@property (assign) id<RestoreImagesViewControllerDelegate> _Nullable delegate;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
