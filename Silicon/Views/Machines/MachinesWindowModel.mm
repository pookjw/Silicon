//
//  MachinesWindowModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "MachinesWindowModel.hpp"
#import "constants.hpp"
#import <Virtualization/Virtualization.h>

std::shared_ptr<Cancellable> MachinesWindowModel::downloadIPSW(NSURL *outputURL, std::function<void(NSProgress *)> progressHandler, std::function<void(NSError * _Nullable)> completionHandler) {
    __block NSURLSessionDownloadTask * _Nullable downloadTask = nullptr;
    
    std::shared_ptr<Cancellable> cancellable = std::make_shared<Cancellable>(^{
        [downloadTask cancel];
    });
    
    //
    
    [VZMacOSRestoreImage fetchLatestSupportedWithCompletionHandler:^(VZMacOSRestoreImage * _Nullable restoreImage, NSError * _Nullable error) {
        if (error) {
            completionHandler(error);
            return;
        }
        
        if (cancellable.get()->isCancelled()) {
            completionHandler([NSError errorWithDomain:Silicon::constants::SiliconErrorDomain code:NSUserCancelledError userInfo:nullptr]);
            return;
        }
        
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        configuration.allowsExpensiveNetworkAccess = NO;
        configuration.waitsForConnectivity = NO;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *_downloadTask = [session downloadTaskWithURL:restoreImage.URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [downloadTask release];
            
            if (error) {
                completionHandler(error);
                return;
            }
            
            NSURL *url = [outputURL URLByAppendingPathComponent:response.suggestedFilename];
            NSError * _Nullable ioError = nullptr;
            [NSFileManager.defaultManager moveItemAtURL:location toURL:url error:&ioError];
            completionHandler(ioError);
        }];
        
        downloadTask = [_downloadTask retain];
        progressHandler(_downloadTask.progress);
        [_downloadTask resume];
        [session finishTasksAndInvalidate];
    }];
    
    return cancellable;
}
