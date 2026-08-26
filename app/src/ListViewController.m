#import "ListViewController.h"
#import "FilamentStore.h"
#import "FilamentItem.h"
#import "EditViewController.h"
#import "Helpers.h"

@interface ListViewController ()
@property (nonatomic, strong) NSArray<NSString *> *sections;
@property (nonatomic, strong) UIView *statsHeader;
@property (nonatomic, strong) UILabel *statCountLabel;
@property (nonatomic, strong) UILabel *statRemainLabel;
@property (nonatomic, strong) UILabel *statUsedLabel;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation ListViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"耗材管理";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    self.tableView.tableHeaderView = [self makeStatsHeader];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addTapped)];
    self.navigationItem.rightBarButtonItem = add;

    // 空状态提示
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"暂无耗材\n点击右上角 + 添加";
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    [self.emptyLabel sizeToFit];

    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

#pragma mark - UI

- (UIView *)makeStatsHeader {
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 120)];

    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    card.layer.cornerRadius = 14;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:card];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:container.topAnchor constant:8],
        [card.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:16],
        [card.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-16],
        [card.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-8]
    ]];

    UIView *c1 = [self statBlockWithTitle:@"卷数" valueLabel:&_statCountLabel];
    UIView *c2 = [self statBlockWithTitle:@"余量(g)" valueLabel:&_statRemainLabel];
    UIView *c3 = [self statBlockWithTitle:@"已用(g)" valueLabel:&_statUsedLabel];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[c1, c2, c3]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor]
    ]];

    return container;
}

- (UIView *)statBlockWithTitle:(NSString *)title valueLabel:(UILabel *__strong *)outLabel {
    UIView *block = [[UIView alloc] init];
    block.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *value = [[UILabel alloc] init];
    value.text = @"0";
    value.font = [UIFont monospacedDigitFontOfSize:24 weight:UIFontWeightSemibold];
    value.textColor = [UIColor labelColor];
    value.textAlignment = NSTextAlignmentCenter;
    value.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *cap = [[UILabel alloc] init];
    cap.text = title;
    cap.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cap.textColor = [UIColor secondaryLabelColor];
    cap.textAlignment = NSTextAlignmentCenter;
    cap.translatesAutoresizingMaskIntoConstraints = NO;

    [block addSubview:value];
    [block addSubview:cap];
    [NSLayoutConstraint activateConstraints:@[
        [value.topAnchor constraintEqualToAnchor:block.topAnchor constant:14],
        [value.centerXAnchor constraintEqualToAnchor:block.centerXAnchor],
        [cap.topAnchor constraintEqualToAnchor:value.bottomAnchor constant:4],
        [cap.centerXAnchor constraintEqualToAnchor:block.centerXAnchor],
        [cap.bottomAnchor constraintEqualToAnchor:block.bottomAnchor constant:-14]
    ]];

    if (outLabel) *outLabel = value;
    return block;
}

- (UIImage *)swatchForColor:(NSString *)name {
    UIColor *c = FMColorFromString(name);
    CGSize s = CGSizeMake(22, 22);
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:s];
    return [r imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ctx) {
        [c setFill];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, s.width, s.height) cornerRadius:6] fill];
    }];
}

#pragma mark - Data

- (void)refresh {
    self.sections = [[FilamentStore sharedStore] materialSections];
    [self.statCountLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[FilamentStore sharedStore].items.count]];
    [self.statRemainLabel setText:[NSString stringWithFormat:@"%ld", (long)[[FilamentStore sharedStore] totalRemaining]]];
    [self.statUsedLabel setText:[NSString stringWithFormat:@"%ld", (long)[[FilamentStore sharedStore] totalUsed]]];

    BOOL empty = [FilamentStore sharedStore].items.count == 0;
    self.tableView.backgroundView = empty ? self.emptyLabel : nil;

    [self.tableView reloadData];
}

- (FilamentItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *material = self.sections[indexPath.section];
    NSArray *arr = [[FilamentStore sharedStore] itemsForMaterial:material];
    return arr[indexPath.row];
}

#pragma mark - Actions

- (void)addTapped {
    EditViewController *edit = [[EditViewController alloc] initWithItem:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:edit];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count ?: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sections.count == 0) return 0;
    NSString *material = self.sections[section];
    return [[[FilamentStore sharedStore] itemsForMaterial:material] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sections.count == 0) return nil;
    NSString *material = self.sections[section];
    NSArray *arr = [[FilamentStore sharedStore] itemsForMaterial:material];
    NSInteger rem = 0;
    for (FilamentItem *it in arr) rem += it.remainingWeight;
    return [NSString stringWithFormat:@"%@  ·  %lu 卷  ·  余 %ldg", material, (unsigned long)arr.count, (long)rem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    FilamentItem *item = [self itemAtIndexPath:indexPath];

    cell.textLabel.text = item.name.length ? item.name : @"(未命名)";
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    double pct = item.remainingPercent * 100.0;
    NSString *brand = item.brand.length ? item.brand : @"—";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@   余 %ldg (%.0f%%)   用 %ldg",
                                 brand, (long)item.remainingWeight, pct, (long)item.usedWeight];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    cell.imageView.image = [self swatchForColor:item.colorName];
    cell.imageView.layer.cornerRadius = 6;
    cell.imageView.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FilamentItem *item = [self itemAtIndexPath:indexPath];
    EditViewController *edit = [[EditViewController alloc] initWithItem:item];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:edit];
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections.count > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FilamentItem *item = [self itemAtIndexPath:indexPath];
        [[FilamentStore sharedStore] removeItem:item];
        [self refresh];
    }
}

@end
