//
//  MachinesWindowModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import <Foundation/Foundation.h>
#import "Cancellable.hpp"
#import <functional>
#import <memory>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class MachinesWindowModel {
public:
     std::shared_ptr<Cancellable> downloadIPSW(NSURL *outputURL, std::function<void(NSProgress *)> progressHandler, std::function<void(NSError * _Nullable)> completionHandler);
};

NS_HEADER_AUDIT_END(nullability, sendability)
