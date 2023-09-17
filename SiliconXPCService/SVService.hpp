//
//  SVService.hpp
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Security.h>
#import <functional>
#import <string>
#import <mutex>
#import <variant>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class SVService {
public:
    SVService(xpc_rich_error_t _Nullable * _Nullable error);
    ~SVService();
    
    void run(xpc_rich_error_t _Nullable * _Nullable error);
    
    SVService(const SVService&) = delete;
    SVService& operator=(const SVService&) = delete;
private:
    NSOperationQueue *_queue;
    
    xpc_listener_t _listener;
    xpc_session_t _Nullable _daemonSession;
    SMAppService *_appService;
    
    AuthorizationRef _authRef;
    NSData *_authorization;
    
    std::mutex _mtx;
    
    void handle(xpc_session_t peer, xpc_object_t message);
    void installDaemon(NSError * _Nullable * error);
    void uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler);
    void openFile(std::string path, std::function<void (std::variant<int, xpc_rich_error_t>)> completionHandler);
    void closeFile(xpc_object_t fd, std::function<void (NSError * _Nullable)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
