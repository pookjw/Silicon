//
//  main.c
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <xpc/xpc.h>
#import "SVService.hpp"

void handleError(xpc_rich_error_t error) {
    if (!error) return;
    
    const char *description = xpc_rich_error_copy_description(error);
    NSString *descriptionString = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
    delete description;
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:descriptionString userInfo:nullptr];
}

int main(int argc, const char *argv[]) {
    xpc_rich_error_t error = NULL;
    
    SVService service {&error};
    handleError(error);
    xpc_release(error);
    
    service.run(&error);
    handleError(error);
    xpc_release(error);
}
