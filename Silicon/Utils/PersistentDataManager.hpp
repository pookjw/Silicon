//
//  PersistentDataManager.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import <CoreData/CoreData.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class PersistentDataManager {
public:
    static PersistentDataManager& getInstance() {
        static PersistentDataManager instance; // Magic Statics
        return instance;
    }
    
    PersistentDataManager(const PersistentDataManager&) = delete;
    PersistentDataManager& operator=(const PersistentDataManager&) = delete;
private:
    PersistentDataManager();
};

NS_HEADER_AUDIT_END(nullability, sendability)
