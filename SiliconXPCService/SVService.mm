//
//  SVService.mm
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "SVService.hpp"
#import "XPCCommon.hpp"
#import <dlfcn.h>

SVService::SVService(xpc_rich_error_t _Nullable * _Nullable error) : _daemonSession(nullptr) {
    dispatch_queue_t queue = dispatch_queue_create("com.pookjw.Silicon.Helper", DISPATCH_QUEUE_SERIAL);
    
    _listener = xpc_listener_create("com.pookjw.Silicon.XPCService",
                                    queue,
                                    XPC_LISTENER_CREATE_INACTIVE,
                                    ^(xpc_session_t  _Nonnull peer) {
        xpc_session_set_incoming_message_handler(peer, ^(xpc_object_t  _Nonnull message) {
            handle(peer, message);
        });
    },
                                    error);
    
    dispatch_release(queue);
    
    if (*error) {
        return;
    }
    
    _appService = [[SMAppService daemonServiceWithPlistName:@"com.pookjw.Silicon.Helper.plist"] retain];
    
    //
    
    OSStatus status_1 = AuthorizationCreate(nullptr, nullptr, 0, &_authRef);
    assert(status_1 == errAuthorizationSuccess);
    
    AuthorizationExternalForm extForm;
    OSStatus status_2 = AuthorizationMakeExternalForm(_authRef, &extForm);
    assert(status_2 == errAuthorizationSuccess);
    
    _authorization = [[NSData alloc] initWithBytes:&extForm length:sizeof(extForm)];
}

SVService::~SVService() {
    xpc_listener_cancel(_listener);
    [_listener release];
    xpc_session_cancel(_daemonSession);
    xpc_release(_daemonSession);
    [_appService release];
    AuthorizationFree(_authRef, 0);
    [_authorization release];
}

void SVService::run(xpc_rich_error_t _Nullable * _Nullable error) {
    xpc_listener_activate(_listener, error);
    if (*error) {
        return;
    }
    
    dispatch_main();
}

void SVService::handle(xpc_session_t  _Nonnull peer, xpc_object_t  _Nonnull message) {
    std::string function = xpc_dictionary_get_string(message, "function");
    
    if (function == "installDaemon") {
        _mtx.lock();
        
        if (_daemonSession) {
            XPCCommon::sendReply({}, peer, message);
            _mtx.unlock();
            return;
        }
        
        NSError * _Nullable error = nullptr;
        installDaemon(&error);
        
        if (error) {
            XPCCommon::sendReply(error, peer, message);
            _mtx.unlock();
            return;
        }
        
        xpc_rich_error_t richError = NULL;
        
        _daemonSession = xpc_session_create_mach_service("com.pookjw.Silicon.Helper",
                                                         nullptr,
                                                         XPC_SESSION_CREATE_MACH_PRIVILEGED,
                                                         &richError);
        
        if (richError) {
            XPCCommon::sendReply(richError, peer, message);
        } else {
            XPCCommon::sendReply({}, peer, message);
        }
        
        _mtx.unlock();
    } else if (function == "uninstallDaemon") {
        _mtx.lock();
        
        if (!_daemonSession) {
            XPCCommon::sendReply({}, peer, message);
            _mtx.unlock();
            return;
        }
        
        uninstallDaemon(^(NSError * _Nullable error) {
            xpc_session_cancel(_daemonSession);
            xpc_release(_daemonSession);
            _daemonSession = nullptr;
            
            if (error) {
                XPCCommon::sendReply(error, peer, message);
            } else {
                XPCCommon::sendReply({}, peer, message);
            }
            
            _mtx.lock();
        });
    } else if (function == "openFile") {
        std::string filePath = xpc_dictionary_get_string(message, "filePath");
    }
}

void SVService::installDaemon(NSError * _Nullable * error) {
    [_appService registerAndReturnError:error];
}

void SVService::uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    [_appService unregisterWithCompletionHandler:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

void SVService::openFile(std::string path, NSData * _Nullable authData, NSError * _Nullable * _Nullable error) {
    
}
