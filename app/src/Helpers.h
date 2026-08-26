#import <UIKit/UIKit.h>

// 把颜色名或 #RRGGBB 解析为 UIColor
UIColor *FMColorFromString(NSString *name);

// 把 UIColor 转成 #RRGGBB
NSString *FMHexFromColor(UIColor *color);
