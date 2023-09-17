//
//  XPCManager.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/16/23.
//

#import "XPCManager.hpp"
#import "XPCCommon.hpp"
#import "constants.hpp"

XPCManager::XPCManager() : _session(xpc_null_create()) {
    xpc_rich_error_t error = nullptr;
    xpc_session_t session = xpc_session_create_xpc_service("com.pookjw.Silicon.XPCService", nullptr, XPC_SESSION_CREATE_INACTIVE, &error);
    assert(!error);
    
    assert(xpc_session_activate(session, &error));
    assert(!error);
    
    _session = session;
    
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

XPCManager::~XPCManager() {
    if (xpc_get_type(_session) == XPC_TYPE_SESSION) {
        xpc_session_cancel(_session);
    }
    xpc_release(_session);
    AuthorizationFree(_authRef, 0);
    [_authorization release];
}

void XPCManager::installDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("installDaemon")}
    };
    
    XPCCommon::sendMessageAndReleaseValues(_session, input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        if (handleErrorIfNeeded(reply, error, completionHandler)) NS_VOIDRETURN;
        completionHandler(nullptr);
    });
}

void XPCManager::uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("uninstallDaemon")}
    };
    
    XPCCommon::sendMessageAndReleaseValues(_session, input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        if (handleErrorIfNeeded(reply, error, completionHandler)) NS_VOIDRETURN;
        completionHandler(nullptr);
    });
}

void XPCManager::openFile(std::string path, std::function<void (std::variant<int, NSError *>)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("openFile")},
        {"filePath", xpc_string_create(path.data())},
        {"authData", xpc_data_create(_authorization.bytes, _authorization.length)}
    };
    
    XPCCommon::sendMessageAndReleaseValues(_session, input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        if (handleErrorIfNeeded(reply, error, ^(NSError *error) { completionHandler(error); })) NS_VOIDRETURN;
        
        int fd = xpc_dictionary_dup_fd(reply, "fd");
        completionHandler(fd);
    });
}

BOOL XPCManager::handleErrorIfNeeded(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error, std::function<void (NSError * _Nullable)> errorHandler) {
    if (error) {
        const char *description = xpc_rich_error_copy_description(error);
        NSString *string = [[NSString alloc] initWithCString:description encoding:NSUTF8StringEncoding];
        delete description;
        
        errorHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconXPCCommonError userInfo:@{NSLocalizedDescriptionKey: string}]);
        [string release];
        
        return YES;
    } else if (xpc_get_type(reply) == XPC_TYPE_DICTIONARY) {
        size_t nsErrorLength;
        const void *nsErrorBytes = xpc_dictionary_get_data(reply, "nsError", &nsErrorLength);
        
        if (nsErrorLength > 0) {
            NSData *nsErrorData = [[NSData alloc] initWithBytes:nsErrorBytes length:nsErrorLength];
            NSError * _Nullable unarchivingError = nullptr;
            NSError *nsError = [NSKeyedUnarchiver unarchivedObjectOfClass:NSError.class fromData:nsErrorData error:&unarchivingError];
            [nsErrorData release];
            
            assert(!unarchivingError);
            errorHandler(nsError);
            
            return YES;
        } else {
            const char * _Nullable description = xpc_dictionary_get_string(reply, "richErrorDescription");
            
            if (description) {
                NSString *string = [[NSString alloc] initWithCString:description encoding:NSUTF8StringEncoding];
                
                errorHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconXPCCommonError userInfo:@{NSLocalizedDescriptionKey: string}]);
                
                [string release];
                
                return YES;
            } else {
                return NO;
            }
        }
    } else {
        return NO;
    }
}
