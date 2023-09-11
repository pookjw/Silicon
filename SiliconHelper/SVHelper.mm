//
//  SVHelper.mm
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/11/23.
//

#import "SVHelper.hpp"
#import <string>

SVHelper::SVHelper(xpc_rich_error_t _Nullable * _Nullable error) {
    _listener = xpc_listener_create("com.pookjw.Silicon.Helper-Launchd",
                                    nullptr,
                                    XPC_LISTENER_CREATE_INACTIVE,
                                    ^(xpc_session_t  _Nonnull peer) {
        xpc_session_set_incoming_message_handler(peer, ^(xpc_object_t  _Nonnull message) {
            handle(peer, message);
        });
    },
                                    error);
}

SVHelper::~SVHelper() {
    xpc_listener_cancel(_listener);
    [_listener release];
}

void SVHelper::run(xpc_rich_error_t  _Nullable * _Nullable error) {
    xpc_listener_activate(_listener, error);
    if (*error) {
        return;
    }
    dispatch_main();
}

void SVHelper::handle(xpc_session_t  _Nonnull peer, xpc_object_t  _Nonnull message) {
    std::string function = xpc_dictionary_get_string(message, "function");
    
    if (function == "ping") {
        xpc_object_t result = xpc_dictionary_create_reply(message);
        xpc_dictionary_set_string(result, "result", "pong");
        xpc_rich_error_t error = xpc_session_send_message(peer, result);
        xpc_release(result);
    }
}
