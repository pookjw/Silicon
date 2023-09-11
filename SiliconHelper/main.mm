//
//  main.mm
//  SiliconHelper
//
//  Created by Jinwoo Kim on 9/10/23.
//

#import <Foundation/Foundation.h>
#import "SVHelper.hpp"

void handleError(xpc_rich_error_t error) {
    if (!error) return;
    
    const char *description = xpc_rich_error_copy_description(error);
    NSString *descriptionString = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
    delete description;
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:descriptionString userInfo:nullptr];
}

int main(int argc, const char * argv[]) {
    printf("Hello World!");
    NSLog(@"Hello World!");
    xpc_rich_error_t error = NULL;
    
    SVHelper helper {&error};
    handleError(error);
    xpc_release(error);
    error = NULL;
    
    helper.run(&error);
    handleError(error);
    xpc_release(error);
    error = NULL;
    
    return EXIT_SUCCESS;
}
