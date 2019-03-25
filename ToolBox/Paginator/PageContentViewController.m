//
//  PageContentViewController.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "PageContentViewController.h"

const NSInteger defaultCacheSize = 10;

// LRU principle based cache. This is the common cache for all the GCMPageContentViewController instances.
static NSMutableDictionary<NSString *, id> *cacheData;
static NSMutableArray<NSString *> *orderedKeys;

@implementation PageContentViewController
@synthesize state;
@synthesize shouldFetchData;

- (instancetype)init {
    if(self = [super init]) {
        self.maxCacheSize = defaultCacheSize;
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(cacheData == nil) {
        cacheData = [NSMutableDictionary dictionary];
        orderedKeys = [NSMutableArray array];
    }

    self.shouldFetchData = YES;
    self.state = PageContentStatePendingLoad;
}

- (void)dealloc {
    cacheData = nil;
    orderedKeys = nil;
}

#pragma mark - Page states
- (void)prepareForReuse:(DateSpan *)dateSpan {
    // If the page will be reused then save the loaded data in the cache before clearing the page.
    if(self.state == PageContentStateLoaded) {
        [self updateCache];
        [self clearContent];
        self.state = PageContentStatePendingLoad;
    }
    self.dateSpan = dateSpan;
}

- (void)pageDidAppear:(DateSpan *)dateSpan {
    self.dateSpan = dateSpan;
    if(self.state == PageContentStateLoaded) {
        return;
    }
    self.state = PageContentStateLoaded;
    [self updateContent];
}

#pragma mark - Data operations
- (void)updateCache {
    id object = [self objectToBeCached];
    if(object) {

        if (orderedKeys.count > 0) {
            [orderedKeys removeObject:[self.dateSpan intervalDescription]];
            [orderedKeys insertObject:[self.dateSpan intervalDescription] atIndex:0];
        } else {
            [orderedKeys addObject:[self.dateSpan intervalDescription]];
        }

        if(orderedKeys.count > self.maxCacheSize) {
            [cacheData removeObjectForKey:orderedKeys.lastObject];
            [orderedKeys removeLastObject];
        }
        [cacheData setObject:[object copy] forKey:[self.dateSpan intervalDescription]];
    }
}

- (nullable id)objectToBeCached {
    // Should be overriden by subclass
    return nil;
}

- (void)populateWithCacheObject:(id)cacheObject {
    // Should be overriden by subclass, no default behavior
}

- (void)fetchData {
    // Should be overriden by subclass, no default behavior
    // Note: Make sure to invalidate the response after the fetch if while fetching the page did change the dateSpan.
}

#pragma mark - Content update
- (void)clearContent {
    // Should be overriden by subclass, no default behavior
}

- (void)updateContent {
    id object = [cacheData objectForKey:[self.dateSpan intervalDescription]];
    if(object == nil) {
        [self fetchData];
        return;
    }

    // Object cache used, update position
    [orderedKeys removeObject:[self.dateSpan intervalDescription]];
    [orderedKeys insertObject:[self.dateSpan intervalDescription] atIndex:0];

    [self populateWithCacheObject:object];
}

#pragma mark - Public methods
- (void)updateForOrientation:(UIInterfaceOrientation)orientation {
    // Should be overriden by subclass, no default behavior
}

@end
