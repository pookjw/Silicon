//
//  SVHelper.hpp
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/11/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>
#import <string>
#import <functional>
#import <cstddef>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class SVHelper {
public:
    SVHelper(xpc_rich_error_t _Nullable * _Nullable error);
    ~SVHelper();
    
    void run(xpc_rich_error_t _Nullable * _Nullable error);
    
    SVHelper(const SVHelper&) = delete;
    SVHelper& operator=(const SVHelper&) = delete;
private:
    NSOperationQueue *_queue;
    xpc_listener_t _listener;
    
    void handle(xpc_session_t peer, xpc_object_t message);
    XPC_RETURNS_RETAINED xpc_object_t openFile(std::string path, NSError * _Nullable * _Nullable error);
    void closeFile(xpc_object_t fd, std::function<void (NSError * _Nullable)> completionHandler);
    void authorize(const void *authData, size_t length, std::function<void (NSError * _Nullable)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
