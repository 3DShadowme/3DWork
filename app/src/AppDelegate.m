#import "AppDelegate.h"
#import "ListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    ListViewController *list = [[ListViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
    nav.navigationBar.prefersLargeTitles = YES;

    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
