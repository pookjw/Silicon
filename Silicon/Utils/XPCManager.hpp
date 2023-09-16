//
//  XPCManager.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/16/23.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <xpc/xpc.h>
#import <functional>
#import <string>
#import <variant>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class XPCManager {
public:
    static XPCManager& getInstance() {
        static XPCManager instance; // Magic Statics
        return instance;
    }
    
    void installDaemon(std::function<void (NSError * _Nullable)> completionHandler);
    void uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler);
    
    void openFile(std::string path, std::function<void (std::variant<int, NSError *>)> completionHandler);
    void closeFile(int fd, std::function<void (NSError * _Nullable)> completionHandler);
    
    void reset(std::function<void (NSError * _Nullable)> completionHandler);
private:
    XPCManager();
    ~XPCManager();
    
    xpc_session_t _session;
    
    BOOL handleErrorIfNeeded(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error, std::function<void (NSError * _Nullable)> errorHandler);
    void sendMessageAndReleaseValues(std::unordered_map<std::string, xpc_object_t> message, std::function<void (xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
