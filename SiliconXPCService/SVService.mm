//
//  SVService.mm
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import "SVService.hpp"
#import <string>

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
            sendCompletionWithError(error, peer, message);
            return;
        }
        
        xpc_rich_error_t richError = NULL;
        _daemonSession = xpc_session_create_mach_service("com.pookjw.Silicon.Helper",
                                                         nullptr,
                                                         XPC_SESSION_CREATE_MACH_PRIVILEGED,
                                                         &richError);
        sendCompletionWithError(richError, peer, message);
    } else if (function == "uninstallDaemon") {
        uninstallDaemon(^(NSError * _Nullable error) {
            sendCompletionWithError(error, peer, message);
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

void SVService::sendCompletionWithError(std::variant<NSError * _Nullable, xpc_rich_error_t _Nullable, std::nullopt_t> error, xpc_session_t peer, xpc_object_t message) {
    xpc_object_t result = NULL;
    
    if (auto nsError = *std::get_if<NSError * _Nullable>(&error)) {
        
    } else if (auto xpcRichError = *std::get_if<xpc_rich_error_t _Nullable>(&error)) {
        
    } else if (std::holds_alternative<std::nullopt_t>(error)) {
        
    }
    
    xpc_rich_error_t resultError = xpc_session_send_message(peer, result);
    xpc_release(result);
    if (resultError) {
        const char *description = xpc_rich_error_copy_description(resultError);
        xpc_release(resultError);
        NSLog(@"%s", description);
        delete description;
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
