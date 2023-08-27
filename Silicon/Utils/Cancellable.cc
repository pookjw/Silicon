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
    mtx.lock();
    if (_isCancelled) {
        mtx.unlock();
        return;
    }
    cancellationHandler();
    _isCancelled = true;
    mtx.unlock();
}

bool Cancellable::isCancelled() {
    bool isCancelled;
    
    mtx.lock();
    isCancelled = _isCancelled;
    mtx.unlock();
    
    return isCancelled;
}
