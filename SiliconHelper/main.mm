//
//  main.mm
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <Foundation/Foundation.h>
#import "SVHelper.hpp"
#import "XPCCommon.hpp"

int main(int argc, const char * argv[]) {
    NSLog(@"Initialized!");
    
    xpc_rich_error_t error = NULL;
    
    SVHelper helper {&error};
    assert(!error);
    xpc_release(error);
    error = NULL;
    
    helper.run(&error);
    assert(!error);
    xpc_release(error);
    error = NULL;
    
    return EXIT_SUCCESS;
}
