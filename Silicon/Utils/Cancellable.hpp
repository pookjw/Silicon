//
//  Cancellable.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import <functional>
#import <mutex>

class Cancellable {
public:
    Cancellable(std::function<void ()> cancellationHandler) : _cancellationHandler(cancellationHandler) {};
    ~Cancellable();
    
    void cancel();
    bool isCancelled();
    
    Cancellable(const Cancellable&) = delete;
    Cancellable& operator=(const Cancellable&) = delete;
private:
    const std::function<void ()> _cancellationHandler;
    bool _isCancelled = false;
    std::mutex _mtx;
};
