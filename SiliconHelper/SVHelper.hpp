//
//  SVHelper.hpp
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/11/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class SVHelper {
public:
    SVHelper(xpc_rich_error_t _Nullable * _Nullable error);
    ~SVHelper();
    
    void run(xpc_rich_error_t _Nullable * _Nullable error);
    
    SVHelper(const SVHelper&) = delete;
    SVHelper& operator=(const SVHelper&) = delete;
private:
    xpc_listener_t _listener;
    void handle(xpc_session_t peer, xpc_object_t message);
};

NS_HEADER_AUDIT_END(nullability, sendability)
