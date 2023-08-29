//
//  Cancellable.cc
//  Silicon
//
//  Created by Jinwoo Kim on 8/27/23.
//

#import "Cancellable.hpp"

Cancellable::~Cancellable() {
    cancel();
}

void Cancellable::cancel() {
    _mtx.lock();
    if (_isCancelled) {
        _mtx.unlock();
        return;
    }
    _cancellationHandler();
    _isCancelled = true;
    _mtx.unlock();
}

bool Cancellable::isCancelled() {
    bool isCancelled;
    
    _mtx.lock();
    isCancelled = _isCancelled;
    _mtx.unlock();
    
    return isCancelled;
}
