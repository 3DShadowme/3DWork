#import "Helpers.h"

UIColor *FMColorFromString(NSString *name) {
    if (name.length == 0) return [UIColor colorWithWhite:0.80 alpha:1.0];

    if ([name hasPrefix:@"#"] && name.length >= 7) {
        unsigned int r = 0, g = 0, b = 0;
        NSString *rs = [name substringWithRange:NSMakeRange(1, 2)];
        NSString *gs = [name substringWithRange:NSMakeRange(3, 2)];
        NSString *bs = [name substringWithRange:NSMakeRange(5, 2)];
        [[NSScanner scannerWithString:rs] scanHexInt:&r];
        [[NSScanner scannerWithString:gs] scanHexInt:&g];
        [[NSScanner scannerWithString:bs] scanHexInt:&b];
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
    }

    NSDictionary *map = @{
        @"红": [UIColor systemRedColor],
        @"橙": [UIColor systemOrangeColor],
        @"黄": [UIColor systemYellowColor],
        @"绿": [UIColor systemGreenColor],
        @"青": [UIColor systemTealColor],
        @"蓝": [UIColor systemBlueColor],
        @"紫": [UIColor systemPurpleColor],
        @"粉": [UIColor systemPinkColor],
        @"白": [UIColor whiteColor],
        @"黑": [UIColor blackColor],
        @"灰": [UIColor systemGrayColor],
        @"金": [UIColor systemYellowColor],
        @"银": [UIColor systemGrayColor]
    };
    for (NSString *key in map) {
        if ([name containsString:key]) return map[key];
    }
    // 兜底：用字符串 hash 生成一个稳定的颜色
    NSUInteger h = [name hash];
    return [UIColor colorWithHue:(double)(h % 360) / 360.0 saturation:0.5 brightness:0.85 alpha:1.0];
}

NSString *FMHexFromColor(UIColor *color) {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02X%02X%02X",
            (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}
