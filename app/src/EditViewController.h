#import <UIKit/UIKit.h>
#import "FilamentItem.h"

@interface EditViewController : UIViewController
- (instancetype)initWithItem:(FilamentItem *)item; // item 为 nil 表示新增
@end
