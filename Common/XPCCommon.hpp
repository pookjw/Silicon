//
//  XPCCommon.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/14/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>
#import <string>
#import <variant>
#import <optional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class XPCCommon {
public:
    XPCCommon() = delete;
    
    static std::string authRightName();
    static void sendReply(std::variant<NSError *, xpc_rich_error_t, std::nullptr_t> result, xpc_session_t peer, xpc_object_t message);
};

NS_HEADER_AUDIT_END(nullability, sendability)
