//
//  main.c
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <xpc/xpc.h>
#import <ServiceManagement/ServiceManagement.h>

int main(int argc, const char *argv[])
{
    xpc_rich_error_t error = NULL;
    
    // Set up the xpc_listener for this service. It will handle all incoming connections.
    xpc_listener_t listener = xpc_listener_create("com.pookjw.Silicon.XPCService", nullptr, XPC_LISTENER_CREATE_NONE, ^(xpc_session_t  _Nonnull peer) {
        
        // Set the incoming message handler to a block that receives the message and performs the service's task.
        xpc_session_set_incoming_message_handler(peer, ^(xpc_object_t  _Nonnull message) {
            int64_t firstNumber = xpc_dictionary_get_int64(message, "firstNumber");
            int64_t secondNumber = xpc_dictionary_get_int64(message, "secondNumber");
            
            // Create a reply and send it back to the client.
            xpc_object_t reply = xpc_dictionary_create_reply(message);
            xpc_dictionary_set_int64(reply, "result", firstNumber + secondNumber);
            xpc_rich_error_t replyError = xpc_session_send_message(peer, reply);
            xpc_release(reply);
            
            if (replyError) {
                printf("Reply failed, error: %s", xpc_rich_error_copy_description(replyError));
                xpc_release(replyError);
            }
        });
    }, &error);
    
    xpc_release(error);
    
    const char *description = xpc_listener_copy_description(listener);
    printf("Created listener: %s", description);
    delete description;
    
    // Resuming the serviceListener starts this service. This method does not return.
    dispatch_main();

    return 0;
}

/*

 To use this service from an app or other process, use xpc_session to establish a connection to the service.
 
     xpc_rich_error_t error;
     xpc_session_t session = xpc_session_create_xpc_service("com.pookjw.SiliconXPCService", NULL, 0, &error);

 Once you have a connection to the service, create a Codable request and send it to the service.

     xpc_rich_error_t error;

     xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
     xpc_dictionary_set_int64(message, "firstNumber", 23);
     xpc_dictionary_set_int64(message, "secondNumber", 19);

     xpc_object_t reply = xpc_session_send_message_with_reply_sync(session, message, &error);
     int64_t result = xpc_dictionary_get_int64(reply, "result");
     
     printf("Got result of calculation: %lld", result);

 When you're done using the connection, cancel it by doing the following:
 
     xpc_session_cancel(session);

*/
