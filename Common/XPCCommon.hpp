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
#import <unordered_map>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class XPCCommon {
public:
    XPCCommon() = delete;
    
    static std::string authRightName();
    static void sendReply(std::variant<NSError *, xpc_rich_error_t, std::nullptr_t> result, xpc_session_t peer, xpc_object_t message);
    static void sendMessageAndReleaseValues(xpc_session_t session, std::unordered_map<std::string, xpc_object_t> message, std::function<void (xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
