//
//  main.c
//  SiliconXPCService
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <xpc/xpc.h>
#import "SVService.hpp"
#import "XPCCommon.hpp"

int main(int argc, const char *argv[]) {
    xpc_rich_error_t error = NULL;
    
    SVService service {&error};
    assert(!error);
    xpc_release(error);
    error = NULL;
    
    service.run(&error);
    assert(!error);
    xpc_release(error);
    error = NULL;
    
    return EXIT_SUCCESS;
}
