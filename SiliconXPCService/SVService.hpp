//
//  SVService.hpp
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>
#import <ServiceManagement/ServiceManagement.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class SVService {
public:
    SVService(xpc_rich_error_t _Nullable * _Nullable error);
    ~SVService();
    
    void run(xpc_rich_error_t _Nullable * _Nullable error);
    
    SVService(const SVService&) = delete;
    SVService& operator=(const SVService&) = delete;
private:
    xpc_listener_t _listener;
    SMAppService *_appService;
    
    void handle(xpc_session_t peer, xpc_object_t message);
    void sendCompletionWithError(NSError * _Nullable error, xpc_session_t peer, xpc_object_t message);
    void installDaemon(NSError * _Nullable * error);
    void uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
