//
//  SVService.mm
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "SVService.hpp"
#import "XPCCommon.hpp"
#import "constants.hpp"
#import <dlfcn.h>

SVService::SVService(xpc_rich_error_t _Nullable * _Nullable error) : _daemonSession(nullptr) {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceBackground;
    queue.maxConcurrentOperationCount = 1;
    _queue = queue;
    
    //
    
    _listener = xpc_listener_create("com.pookjw.Silicon.XPCService",
                                    nullptr,
                                    XPC_LISTENER_CREATE_INACTIVE,
                                    ^(xpc_session_t  _Nonnull peer) {
        xpc_session_set_incoming_message_handler(peer, ^(xpc_object_t  _Nonnull message) {
            handle(peer, message);
        });
    },
                                    error);
    
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
    
    OSStatus status_3 = AuthorizationRightGet(XPCCommon::authRightName().data(), nullptr);
    if (status_3 == errAuthorizationDenied) {
        CFStringRef rightDefinition = CFSTR(kAuthorizationRuleAuthenticateAsAdmin);
        CFStringRef descriptionKey = CFSTR("TEST");
        
        OSStatus status_4 = AuthorizationRightSet(_authRef,
                                                  XPCCommon::authRightName().data(),
                                                  rightDefinition,
                                                  descriptionKey,
                                                  nullptr,
                                                  nullptr);
        
        CFRelease(rightDefinition);
        CFRelease(descriptionKey);
        
        assert(status_4 == errAuthorizationSuccess);
    }
}

SVService::~SVService() {
    [_queue cancelAllOperations];
    [_queue release];
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
    [_queue addOperationWithBlock:^{
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
            _mtx.lock();
            
            if (!_daemonSession) {
                XPCCommon::sendReply([NSError errorWithDomain:SiliconErrorDomain code:SiliconXPCDaemonNotActivatedError userInfo:nullptr], peer, message);
                _mtx.unlock();
                NS_VOIDRETURN;
            }
            
            std::string filePath = xpc_dictionary_get_string(message, "filePath");
            
            openFile(filePath, ^(std::variant<int, xpc_rich_error_t> result) {
                if (int *fd_p = std::get_if<int>(&result)) {
                    xpc_object_t reply = xpc_dictionary_create_reply(message);
                    xpc_dictionary_set_fd(reply, "fd", *fd_p);
                    xpc_rich_error_t _Nullable error = xpc_session_send_message(peer, reply);
                    xpc_release(reply);
                    assert(!error);
                    xpc_release(error);
                } else if (xpc_rich_error_t *error_p = std::get_if<xpc_rich_error_t>(&result)) {
                    XPCCommon::sendReply(*error_p, peer, message);
                }
                
                _mtx.unlock();
            });
        }
    }];
}

void SVService::installDaemon(NSError * _Nullable * error) {
    [_appService registerAndReturnError:error];
}

void SVService::uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    [_appService unregisterWithCompletionHandler:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

void SVService::openFile(std::string path, std::function<void (std::variant<int, xpc_rich_error_t>)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input = {
        {"function", xpc_string_create("openFile")},
        {"filePath", xpc_string_create(path.data())},
        {"authData", xpc_data_create(_authorization.bytes, _authorization.length)}
    };
    
    XPCCommon::sendMessageAndReleaseValues(_daemonSession, input, ^(xpc_object_t _Nullable message, xpc_rich_error_t _Nullable error) {
        if (error) {
            completionHandler(error);
            NS_VOIDRETURN;
        }
        
        int fd = xpc_dictionary_dup_fd(message, "fd");
        completionHandler(fd);
    });
}
