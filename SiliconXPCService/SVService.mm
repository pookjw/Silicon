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
    
    _daemonSession = xpc_session_create_mach_service("com.pookjw.Silicon.Helper-Launchd",
                                                     nullptr,
                                                     XPC_SESSION_CREATE_INACTIVE,
                                                     error);
    
    if (*error) {
        return;
    }
    
    _appService = [[SMAppService daemonServiceWithPlistName:@"com.pookjw.Silicon.Helper-Launchd.plist"] retain];
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
    
//    xpc_session_activate(_daemonSession, error);
//    if (*error) {
//        return;
//    }
    
    dispatch_main();
}

void SVService::handle(xpc_session_t  _Nonnull peer, xpc_object_t  _Nonnull message) {
    std::string function = xpc_dictionary_get_string(message, "function");
    
    if (function == "installDaemon") {
        NSError * _Nullable error = nullptr;
        installDaemon(&error);
        sendCompletionWithError(error, peer, message);
        
        // TODO: Error Handling
        xpc_session_activate(_daemonSession, nullptr);
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

void SVService::sendCompletionWithError(NSError * _Nullable error, xpc_session_t peer, xpc_object_t message) {
    xpc_object_t dictionary = xpc_dictionary_create_reply(message);
    if (!dictionary) return;
    
    if (error) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:error requiringSecureCoding:YES error:&error];
        assert(data);
        
        xpc_dictionary_set_data(dictionary, "error", data.bytes, data.length);
    } else {
        xpc_object_t nullObject = xpc_null_create();
        xpc_dictionary_set_value(dictionary, "error", nullObject);
        xpc_release(nullObject);
    }
    
    xpc_rich_error_t resultError = xpc_session_send_message(peer, dictionary);
    xpc_release(dictionary);
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
