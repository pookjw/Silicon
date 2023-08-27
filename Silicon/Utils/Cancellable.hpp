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
    Cancellable(std::function<void()> cancellationHandler) : cancellationHandler(cancellationHandler) {};
    ~Cancellable();
    
    void cancel();
    bool isCancelled();
    
    Cancellable(const Cancellable&) = delete;
    Cancellable& operator=(const Cancellable&) = delete;
private:
    std::function<void()> cancellationHandler;
    bool _isCancelled = false;
    std::mutex mtx;
};
