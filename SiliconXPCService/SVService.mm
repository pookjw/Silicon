//
//  SVService.mm
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "SVService.hpp"
#import "XPCCommon.hpp"
#import <dlfcn.h>

SVService::SVService(xpc_rich_error_t _Nullable * _Nullable error) {
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
}

SVService::~SVService() {
    xpc_listener_cancel(_listener);
    [_listener release];
    xpc_session_cancel(_daemonSession);
    xpc_release(_daemonSession);
    [_appService release];
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
        NSError * _Nullable error = nullptr;
        installDaemon(&error);
        
        if (error) {
            XPCCommon::sendReplyWithNSError(error, peer, message);
            return;
        }
        
        xpc_rich_error_t richError = NULL;
        _daemonSession = xpc_session_create_mach_service("com.pookjw.Silicon.Helper",
                                                         nullptr,
                                                         XPC_SESSION_CREATE_MACH_PRIVILEGED,
                                                         &richError);
        
        if (richError) {
            XPCCommon::sendReplyWithRichError(richError, peer, message);
        } else {
            XPCCommon::sendReplyWithNull(peer, message);
        }
    } else if (function == "uninstallDaemon") {
        uninstallDaemon(^(NSError * _Nullable error) {
            if (error) {
                XPCCommon::sendReplyWithNSError(error, peer, message);
                NS_VOIDRETURN;
            }
            
            XPCCommon::sendReplyWithNull(peer, message);
        });
    } else if (function == "ping") {
        xpc_object_t functionObject = xpc_string_create("ping");
        const char *keys [1] = {"function"};
        xpc_object_t values [1] = {functionObject};
        
        xpc_object_t dictionary = xpc_dictionary_create(keys, values, 1);
        xpc_release(functionObject);
        xpc_session_send_message_with_reply_async(_daemonSession, dictionary, ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
            const char *description = xpc_copy_description(reply);
            NSLog(@"%s", description);
            delete description;
        });
        
        xpc_release(dictionary);
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
