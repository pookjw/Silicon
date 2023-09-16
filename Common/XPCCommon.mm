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

void XPCCommon::sendReplyWithRichError(xpc_rich_error_t error, xpc_session_t peer, xpc_object_t message) {
    xpc_object_t reply = xpc_dictionary_create_reply(message);
    xpc_dictionary_set_value(reply, "richError", error);
    
    xpc_rich_error_t _Nullable sendError = xpc_session_send_message(peer, reply);
    xpc_release(reply);
    assert(!sendError);
    xpc_release(sendError);
}

void XPCCommon::sendReplyWithNSError(NSError *error, xpc_session_t peer, xpc_object_t message) {
    NSError * _Nullable archiveError = nullptr;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:error requiringSecureCoding:YES error:&archiveError];
    assert(!archiveError);
    
    xpc_object_t reply = xpc_dictionary_create_reply(message);
    xpc_dictionary_set_data(reply, "nsError", data.bytes, data.length);
    
    xpc_rich_error_t _Nullable sendError = xpc_session_send_message(peer, reply);
    xpc_release(reply);
    assert(!sendError);
    xpc_release(sendError);
}

void XPCCommon::sendReplyWithNull(xpc_session_t peer, xpc_object_t message) {
    xpc_object_t reply = xpc_dictionary_create_reply(message);
    xpc_rich_error_t _Nullable sendError = xpc_session_send_message(peer, reply);
    xpc_release(reply);
    assert(!sendError);
    xpc_release(sendError);
}
