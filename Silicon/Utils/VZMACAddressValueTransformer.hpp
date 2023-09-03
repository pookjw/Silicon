//
//  VZMACAddressValueTransformer.h
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Foundation/Foundation.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VZMACAddressValueTransformer : NSValueTransformer
+ (BOOL)registerIfNeeded;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
