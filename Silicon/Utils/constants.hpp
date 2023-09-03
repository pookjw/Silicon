//
//  constants.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import <Foundation/Foundation.h>

NSErrorDomain const SiliconErrorDomain = @"SiliconErrorDomain";

typedef NS_ERROR_ENUM(SiliconErrorDomain, SiliconErrorCode) {
    SiliconUserCancelledError,
    SiliconAlreadyInitializedError,
    SiliconNotSupportedHardware,
    SiliconFileIOError
};
