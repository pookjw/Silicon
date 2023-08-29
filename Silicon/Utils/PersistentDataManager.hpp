//
//  PersistentDataManager.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import <CoreData/CoreData.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class PersistentDataManager {
public:
    static PersistentDataManager& getInstance() {
        static PersistentDataManager instance; // Magic Statics
        return instance;
    }
    
    PersistentDataManager(const PersistentDataManager&) = delete;
    PersistentDataManager& operator=(const PersistentDataManager&) = delete;
    
    NSManagedObjectContext *context();
    NSOperationQueue *queue();
    void initialize(std::function<void (NSError * _Nullable)> completionHandler);
private:
    PersistentDataManager();
    ~PersistentDataManager();
    
    NSManagedObjectContext *_context;
    NSPersistentContainer *_container;
    NSOperationQueue *_queue;
    
    bool _isInitialized = false;
    
    NSManagedObjectModel *_managedObjectModel();
};

NS_HEADER_AUDIT_END(nullability, sendability)
