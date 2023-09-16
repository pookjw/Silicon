//
//  SVHelper.mm
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/11/23.
//

#import "SVHelper.hpp"
#import "constants.hpp"
#import "XPCCommon.hpp"
#import <Security/Security.h>
#import <string>

SVHelper::SVHelper(xpc_rich_error_t _Nullable * _Nullable error) {
    _listener = xpc_listener_create("com.pookjw.Silicon.Helper",
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
    
    if (function == "openFile") {
        size_t authDataLength = NULL;
        const void *authData = xpc_dictionary_get_data(message, "authData", &authDataLength);
        
        authorize(authData, authDataLength, ^(NSError * _Nullable authError) {
            if (authError) {
                XPCCommon::sendReplyWithNSError(authError, peer, message);
                return;
            }
            
            const char *path = xpc_dictionary_get_string(message, "path");
            NSError * _Nullable error = nullptr;
            xpc_object_t fd = openFile(path, &error);
            
            if (error) {
                xpc_release(fd);
                XPCCommon::sendReplyWithNSError(error, peer, message);
                return;
            }
            
            xpc_rich_error_t _Nullable xpcError = xpc_session_send_message(peer, fd);
            xpc_release(fd);
            assert(!xpcError);
            xpc_release(xpcError);
        });
    }
}


xpc_object_t SVHelper::openFile(std::string path, NSError * _Nullable * _Nullable error) {
    NSString *string = [[NSString alloc] initWithCString:path.data() encoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:string];
    [string release];
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingURL:url error:error];
    [url release];
    
    if (*error) {
        return xpc_null_create();
    }
    
    return xpc_fd_create(handle.fileDescriptor);
}

void SVHelper::closeFile(xpc_object_t  _Nonnull fd, std::function<void (NSError * _Nullable)> completionHandler) {
    
}

void SVHelper::authorize(const void *authData, size_t length, std::function<void (NSError * _Nullable)> completionHandler) {
    AuthorizationRef authRef = NULL;
    
    if (length != sizeof(AuthorizationExternalForm)) {
        completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconInvalidAuthData userInfo:nullptr]);
        return;
    }
    
    OSStatus err_1 = AuthorizationCreateFromExternalForm(static_cast<const AuthorizationExternalForm *>(authData), &authRef);
    
    if (err_1 != errAuthorizationSuccess) {
        completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconInvalidAuthData userInfo:nullptr]);
        return;
    }
    
    std::string authRightName = XPCCommon::authRightName();
    
    AuthorizationItem item = {
        .name = authRightName.data(),
        .valueLength = 0,
        .value = nullptr,
        .flags = 0
    };
    
    AuthorizationRights rights = {
        .count = 1,
        .items = &item
    };
    
    AuthorizationCopyRightsAsync(authRef,
                                 &rights,
                                 nullptr,
                                 kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed,
                                 ^(OSStatus err_2, AuthorizationRights * _Nullable blockAuthorizedRights) {
        AuthorizationFree(authRef, 0);
        
        if (err_2 != errAuthorizationSuccess) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconInvalidAuthData userInfo:nullptr]);
            return;
        }
        
        completionHandler(nullptr);
    });
}
