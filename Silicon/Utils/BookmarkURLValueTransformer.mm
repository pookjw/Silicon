//
//  BookmarkURLValueTransformer.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "BookmarkURLValueTransformer.hpp"

@implementation BookmarkURLValueTransformer

+ (BOOL)registerIfNeeded {
    if ([NSValueTransformer.valueTransformerNames containsObject:NSStringFromClass(self)]) {
        BookmarkURLValueTransformer *transformer = [BookmarkURLValueTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:NSStringFromClass(self)];
        [transformer release];
        
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return NSURL.class;
}

+ (NSArray *)allowedTopLevelClasses {
    return @[NSURL.class];
}

- (id)transformedValue:(id)value {
    NSError * _Nullable error = nullptr;
    
    BOOL bookmarkDataIsStale;
    NSURL *result = [[NSURL alloc] initByResolvingBookmarkData:value options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nullptr bookmarkDataIsStale:&bookmarkDataIsStale error:&error];
    
    if (bookmarkDataIsStale) {
        NSLog(@"Stale!");
        [result release];
        return nullptr;
    }
    
    if (error) {
        [NSException exceptionWithName:NSInconsistentArchiveException reason:error.localizedDescription userInfo:nullptr];
    }
    
    return [result autorelease];
}

- (id)reverseTransformedValue:(id)value {
    NSError * _Nullable error = nullptr;
    NSData *result = [static_cast<NSURL *>(value) bookmarkDataWithOptions:NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess includingResourceValuesForKeys:nullptr relativeToURL:nullptr error:&error];
    
    if (error) {
        [NSException exceptionWithName:NSInconsistentArchiveException reason:error.localizedDescription userInfo:nullptr];
    }
    
    return result;
}

@end
