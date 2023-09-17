//
//  XPCCommon.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/14/23.
//

#import "XPCCommon.hpp"
#import <ranges>
#import <vector>
#import <algorithm>

std::string XPCCommon::authRightName() {
    return "Silicon.Authorization";
}

void XPCCommon::sendReply(std::variant<NSError *, xpc_rich_error_t, std::nullptr_t> result, xpc_session_t  _Nonnull peer, xpc_object_t  _Nonnull message) {
    xpc_object_t reply = xpc_dictionary_create_reply(message);
    
    if (NSError **nsError_p = std::get_if<NSError *>(&result)) {
        if (*nsError_p) {
            NSError * _Nullable archiveError = nullptr;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:*nsError_p requiringSecureCoding:YES error:&archiveError];
            assert(!archiveError);
            
            xpc_dictionary_set_data(reply, "nsError", data.bytes, data.length);
        }
    } else if (xpc_rich_error_t *richError_p = std::get_if<xpc_rich_error_t>(&result)) {
        if (*richError_p) {
            const char *description = xpc_rich_error_copy_description(*richError_p);
            xpc_dictionary_set_string(reply, "richErrorDescription", description);
            delete description;
        }
    }
    
    xpc_rich_error_t _Nullable sendError = xpc_session_send_message(peer, reply);
    xpc_release(reply);
    assert(!sendError);
    xpc_release(sendError);
}

void XPCCommon::sendMessageAndReleaseValues(xpc_session_t  _Nonnull session, std::unordered_map<std::string, xpc_object_t> message, std::function<void (xpc_object_t _Nullable, xpc_rich_error_t _Nullable)> completionHandler) {
    auto keys = message | std::views::transform([](std::pair<std::string, xpc_object_t> pair) {
        char *copy = new char[pair.first.size() + 1];
        strcpy(copy, pair.first.data());
        return copy;
    });
    
    auto values = message | std::views::transform([](std::pair<std::string, xpc_object_t> pair) {
        return pair.second;
    });
    
    std::vector<char *> keysArr {keys.begin(), keys.end()};
    std::vector<xpc_object_t> valuesArr {values.begin(), values.end()};
    
    xpc_object_t dictionary = xpc_dictionary_create(keysArr.data(), valuesArr.data(), valuesArr.size());
    
    std::for_each(keys.begin(), keys.end(), [](char *key) {
        delete key;
    });
    std::for_each(values.begin(), values.end(), [](xpc_object_t object) {
        xpc_release(object);
    });
    
    xpc_session_send_message_with_reply_async(session, dictionary, ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
        completionHandler(reply, error);
    });
    
    xpc_release(dictionary);
}
