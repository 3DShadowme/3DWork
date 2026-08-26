#import "FilamentStore.h"

@interface FilamentStore ()
@property (nonatomic, strong) NSMutableArray<FilamentItem *> *mutableItems;
@end

@implementation FilamentStore

+ (instancetype)sharedStore {
    static FilamentStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[FilamentStore alloc] init];
        [store reload];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableItems = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray<FilamentItem *> *)items {
    return self.mutableItems;
}

- (NSString *)storePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = paths.firstObject;
    return [dir stringByAppendingPathComponent:@"filaments.plist"];
}

- (void)reload {
    NSString *path = [self storePath];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    [self.mutableItems removeAllObjects];
    if (arr) {
        for (NSDictionary *d in arr) {
            if ([d isKindOfClass:[NSDictionary class]]) {
                [self.mutableItems addObject:[[FilamentItem alloc] initWithDictionary:d]];
            }
        }
    }
    [self sortItems];
}

- (void)sortItems {
    [self.mutableItems sortUsingComparator:^NSComparisonResult(FilamentItem *a, FilamentItem *b) {
        NSComparisonResult r = [a.material compare:b.material];
        if (r == NSOrderedSame) {
            return [b.purchaseDate compare:a.purchaseDate];
        }
        return r;
    }];
}

- (void)save {
    NSMutableArray *arr = [NSMutableArray array];
    for (FilamentItem *item in self.mutableItems) {
        [arr addObject:[item dictionaryRepresentation]];
    }
    [arr writeToFile:[self storePath] atomically:YES];
}

- (void)addItem:(FilamentItem *)item {
    if (!item) return;
    [self.mutableItems addObject:item];
    [self sortItems];
    [self save];
}

- (void)updateItem:(FilamentItem *)item {
    if (!item) return;
    for (NSInteger i = 0; i < self.mutableItems.count; i++) {
        if ([self.mutableItems[i].uuid isEqualToString:item.uuid]) {
            self.mutableItems[i] = item;
            break;
        }
    }
    [self sortItems];
    [self save];
}

- (void)removeItem:(FilamentItem *)item {
    if (!item) return;
    for (NSInteger i = 0; i < self.mutableItems.count; i++) {
        if ([self.mutableItems[i].uuid isEqualToString:item.uuid]) {
            [self.mutableItems removeObjectAtIndex:i];
            break;
        }
    }
    [self save];
}

- (NSArray<NSString *> *)materialSections {
    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
    for (FilamentItem *item in self.mutableItems) {
        [set addObject:item.material];
    }
    return set.array;
}

- (NSArray<FilamentItem *> *)itemsForMaterial:(NSString *)material {
    NSMutableArray *result = [NSMutableArray array];
    for (FilamentItem *item in self.mutableItems) {
        if ([item.material isEqualToString:material]) {
            [result addObject:item];
        }
    }
    return result;
}

- (NSInteger)totalRemaining {
    NSInteger s = 0;
    for (FilamentItem *item in self.mutableItems) s += item.remainingWeight;
    return s;
}

- (NSInteger)totalUsed {
    NSInteger s = 0;
    for (FilamentItem *item in self.mutableItems) s += item.usedWeight;
    return s;
}

@end
