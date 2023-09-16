//
//  XPCManager.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/16/23.
//

#import "XPCManager.hpp"
#import "XPCCommon.hpp"
#import "constants.hpp"
#import <unordered_map>
#import <ranges>
#import <vector>
#import <algorithm>

XPCManager::XPCManager() : _session(xpc_null_create()) {
    xpc_rich_error_t error = nullptr;
    xpc_session_t session = xpc_session_create_xpc_service("com.pookjw.Silicon.XPCService", nullptr, XPC_SESSION_CREATE_INACTIVE, &error);
    assert(!error);
    
    assert(xpc_session_activate(session, &error));
    assert(!error);
    
    _session = session;
}

XPCManager::~XPCManager() {
    if (xpc_get_type(_session) == XPC_TYPE_SESSION) {
        xpc_session_cancel(_session);
    }
    xpc_release(_session);
}

void XPCManager::installDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("installDaemon")}
    };
    
    sendMessageAndReleaseValues(input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        if (handleErrorIfNeeded(reply, error, completionHandler)) return;
        completionHandler(nullptr);
    });
}

void XPCManager::uninstallDaemon(std::function<void (NSError * _Nullable)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("uninstallDaemon")}
    };
    
    sendMessageAndReleaseValues(input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        if (handleErrorIfNeeded(reply, error, completionHandler)) return;
        completionHandler(nullptr);
    });
}

void XPCManager::openFile(std::string path, std::function<void (std::variant<int, NSError *>)> completionHandler) {
    std::unordered_map<std::string, xpc_object_t> input {
        {"function", xpc_string_create("openFile")},
        {"filePath", xpc_string_create(path.data())}
    };
    
    sendMessageAndReleaseValues(input, ^(xpc_object_t _Nullable reply, xpc_rich_error_t _Nullable error) {
        
    });
}

void XPCManager::sendMessageAndReleaseValues(std::unordered_map<std::string, xpc_object_t> message, std::function<void (xpc_object_t _Nullable, xpc_rich_error_t _Nullable)> completionHandler) {
    auto keys = message | std::views::transform([](std::pair<std::string, xpc_object_t> pair) {
        return pair.first.data();
    });
    
    auto values = message | std::views::transform([](std::pair<std::string, xpc_object_t> pair) {
        return pair.second;
    });
    
    std::vector<const char *> keysArr {keys.begin(), keys.end()};
    std::vector<xpc_object_t> valuesArr {values.begin(), values.end()};
    
    xpc_object_t dictionary = xpc_dictionary_create(keysArr.data(), valuesArr.data(), keysArr.size());
    
    std::for_each(values.begin(), values.end(), [](xpc_object_t object) {
        xpc_release(object);
    });
    
    xpc_session_send_message_with_reply_async(_session, dictionary, ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
        completionHandler(reply, error);
    });
    
    xpc_release(dictionary);
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
            xpc_rich_error_t _Nullable richError = xpc_dictionary_get_value(reply, "richError");
            
            if (richError) {
                const char *description = xpc_rich_error_copy_description(richError);
                NSString *string = [[NSString alloc] initWithCString:description encoding:NSUTF8StringEncoding];
                delete description;
                
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
