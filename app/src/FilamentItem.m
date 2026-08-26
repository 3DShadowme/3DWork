#import "FilamentItem.h"

NSString *const kMaterialPLA   = @"PLA";
NSString *const kMaterialABS   = @"ABS";
NSString *const kMaterialPETG  = @"PETG";
NSString *const kMaterialTPU   = @"TPU";
NSString *const kMaterialResin = @"树脂";
NSString *const kMaterialNylon = @"尼龙";
NSString *const kMaterialOther = @"其他";

@implementation FilamentItem

+ (NSArray<NSString *> *)allMaterials {
    return @[kMaterialPLA, kMaterialABS, kMaterialPETG, kMaterialTPU,
             kMaterialResin, kMaterialNylon, kMaterialOther];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _uuid = [[NSUUID UUID] UUIDString];
        _material = kMaterialPLA;
        _purchaseDate = [NSDate date];
        _totalWeight = 1000;
        _remainingWeight = 1000;
    }
    return self;
}

- (NSInteger)usedWeight {
    NSInteger used = self.totalWeight - self.remainingWeight;
    return used > 0 ? used : 0;
}

- (double)remainingPercent {
    if (self.totalWeight <= 0) return 0;
    double p = (double)self.remainingWeight / (double)self.totalWeight;
    return p < 0 ? 0 : (p > 1 ? 1 : p);
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"uuid": self.uuid ?: @"",
        @"name": self.name ?: @"",
        @"brand": self.brand ?: @"",
        @"material": self.material ?: kMaterialPLA,
        @"colorName": self.colorName ?: @"",
        @"totalWeight": @(self.totalWeight),
        @"remainingWeight": @(self.remainingWeight),
        @"purchaseDate": @([self.purchaseDate timeIntervalSince1970]),
        @"note": self.note ?: @""
    };
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _uuid = dict[@"uuid"] ?: [[NSUUID UUID] UUIDString];
        _name = dict[@"name"] ?: @"";
        _brand = dict[@"brand"] ?: @"";
        _material = dict[@"material"] ?: kMaterialPLA;
        _colorName = dict[@"colorName"] ?: @"";
        _totalWeight = [dict[@"totalWeight"] integerValue];
        _remainingWeight = [dict[@"remainingWeight"] integerValue];
        NSTimeInterval t = [dict[@"purchaseDate"] doubleValue];
        _purchaseDate = t > 0 ? [NSDate dateWithTimeIntervalSince1970:t] : [NSDate date];
        _note = dict[@"note"] ?: @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FilamentItem *copy = [[FilamentItem allocWithZone:zone] init];
    copy.uuid = self.uuid;
    copy.name = self.name;
    copy.brand = self.brand;
    copy.material = self.material;
    copy.colorName = self.colorName;
    copy.totalWeight = self.totalWeight;
    copy.remainingWeight = self.remainingWeight;
    copy.purchaseDate = self.purchaseDate;
    copy.note = self.note;
    return copy;
}

@end
