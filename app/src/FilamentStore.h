#import <Foundation/Foundation.h>
#import "FilamentItem.h"

@interface FilamentStore : NSObject

+ (instancetype)sharedStore;

@property (nonatomic, strong, readonly) NSMutableArray<FilamentItem *> *items;

- (void)addItem:(FilamentItem *)item;
- (void)updateItem:(FilamentItem *)item;
- (void)removeItem:(FilamentItem *)item;
- (void)save;
- (void)reload;

- (NSArray<NSString *> *)materialSections;
- (NSArray<FilamentItem *> *)itemsForMaterial:(NSString *)material;

- (NSInteger)totalRemaining;
- (NSInteger)totalUsed;

@end
