#import <Foundation/Foundation.h>

extern NSString *const kMaterialPLA;
extern NSString *const kMaterialABS;
extern NSString *const kMaterialPETG;
extern NSString *const kMaterialTPU;
extern NSString *const kMaterialResin;
extern NSString *const kMaterialNylon;
extern NSString *const kMaterialOther;

@interface FilamentItem : NSObject <NSCopying>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *material;
@property (nonatomic, copy) NSString *colorName;     // 颜色名或 #RRGGBB
@property (nonatomic, assign) NSInteger totalWeight;     // 总重(g)
@property (nonatomic, assign) NSInteger remainingWeight; // 剩余(g)
@property (nonatomic, strong) NSDate *purchaseDate;
@property (nonatomic, copy) NSString *note;

- (NSDictionary *)dictionaryRepresentation;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (double)remainingPercent;
- (NSInteger)usedWeight;
+ (NSArray<NSString *> *)allMaterials;

@end
