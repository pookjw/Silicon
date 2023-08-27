//
//  main.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.hpp"

int main(int argc, const char * argv[]) {
    NSApplication *sharedApplication = NSApplication.sharedApplication;
    AppDelegate *delegate = [AppDelegate new];
    sharedApplication.delegate = delegate;
    [delegate release];
    [sharedApplication run];
    
    return EXIT_SUCCESS;
}
