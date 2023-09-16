//
//  XPCCommon.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/14/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>
#import <string>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class XPCCommon {
public:
    XPCCommon() = delete;
    
    static std::string authRightName();
    static void sendReplyWithRichError(xpc_rich_error_t error, xpc_session_t peer, xpc_object_t message);
    static void sendReplyWithNSError(NSError *error, xpc_session_t peer, xpc_object_t message);
    static void sendReplyWithNull(xpc_session_t peer, xpc_object_t message);
};

NS_HEADER_AUDIT_END(nullability, sendability)
