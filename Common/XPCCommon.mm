//
//  XPCCommon.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/14/23.
//

#import "XPCCommon.hpp"

std::string XPCCommon::authRightName() {
    return "Silicon.Authorization";
}

void XPCCommon::sendReply(std::variant<NSError *, xpc_rich_error_t, std::nullptr_t> result, xpc_session_t  _Nonnull peer, xpc_object_t  _Nonnull message) {
    xpc_object_t reply = xpc_dictionary_create_reply(message);
    
    if (NSError **nsError_p = std::get_if<NSError *>(&result)) {
        if (NSError *nsError = *nsError_p) {
            NSError * _Nullable archiveError = nullptr;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:nsError requiringSecureCoding:YES error:&archiveError];
            assert(!archiveError);
            
            xpc_object_t reply = xpc_dictionary_create_reply(message);
            xpc_dictionary_set_data(reply, "nsError", data.bytes, data.length);
        }
    } else if (xpc_rich_error_t *richError_p = std::get_if<xpc_rich_error_t>(&result)) {
        if (xpc_rich_error_t richError = *richError_p) {
            xpc_dictionary_set_value(reply, "richError", richError);
        }
    }
    
    xpc_rich_error_t _Nullable sendError = xpc_session_send_message(peer, reply);
    xpc_release(reply);
    assert(!sendError);
    xpc_release(sendError);
}
