#import "EditViewController.h"
#import "FilamentItem.h"
#import "FilamentStore.h"
#import "Helpers.h"

@interface EditViewController ()
@property (nonatomic, strong) FilamentItem *editingItem;
@property (nonatomic, copy) NSString *material;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *brandField;
@property (nonatomic, strong) UIButton *materialButton;
@property (nonatomic, strong) UIColorWell *colorWell;
@property (nonatomic, strong) UITextField *totalField;
@property (nonatomic, strong) UITextField *remainingField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextView *noteView;
@end

@implementation EditViewController

- (instancetype)initWithItem:(FilamentItem *)item {
    self = [super init];
    if (self) {
        _editingItem = [item copy];
        _material = item ? item.material : kMaterialPLA;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = self.editingItem ? @"编辑耗材" : @"新增耗材";

    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(saveTapped)];
    self.navigationItem.rightBarButtonItem = save;

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancel;

    [self buildForm];
}

- (void)buildForm {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];

    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    container.layer.cornerRadius = 12;
    container.clipsToBounds = YES;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:container];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [container.topAnchor constraintEqualToAnchor:scroll.topAnchor constant:16],
        [container.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor constant:16],
        [container.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor constant:-16],
        [container.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor constant:-16],
        [container.widthAnchor constraintEqualToAnchor:scroll.widthAnchor constant:-32]
    ]];

    // --- 控件 ---
    self.nameField = [self textFieldWithPlaceholder:@"如：红色PLA"];
    self.brandField = [self textFieldWithPlaceholder:@"如：eSUN"];
    self.materialButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.materialButton setTitle:self.material forState:UIControlStateNormal];
    self.materialButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    self.materialButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self setupMaterialMenu];

    self.colorWell = [[UIColorWell alloc] init];
    self.colorWell.title = @"颜色";
    if (self.editingItem.colorName.length) {
        self.colorWell.selectedColor = FMColorFromString(self.editingItem.colorName);
    }

    self.totalField = [self textFieldWithPlaceholder:@"1000"];
    self.totalField.keyboardType = UIKeyboardTypeNumberPad;
    self.remainingField = [self textFieldWithPlaceholder:@"1000"];
    self.remainingField.keyboardType = UIKeyboardTypeNumberPad;

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleInline;
    }
    self.datePicker.date = self.editingItem ? self.editingItem.purchaseDate : [NSDate date];

    self.noteView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
    self.noteView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.noteView.backgroundColor = [UIColor clearColor];
    self.noteView.layer.cornerRadius = 8;
    [self.noteView.heightAnchor constraintEqualToConstant:80].active = YES;

    if (self.editingItem) {
        self.nameField.text = self.editingItem.name;
        self.brandField.text = self.editingItem.brand;
        self.totalField.text = [NSString stringWithFormat:@"%ld", (long)self.editingItem.totalWeight];
        self.remainingField.text = [NSString stringWithFormat:@"%ld", (long)self.editingItem.remainingWeight];
        self.noteView.text = self.editingItem.note;
    }

    // --- 行 ---
    NSArray *rows = @[
        [self rowWithTitle:@"名称" control:self.nameField],
        [self rowWithTitle:@"品牌" control:self.brandField],
        [self rowWithTitle:@"材质" control:self.materialButton],
        [self rowWithTitle:@"颜色" control:self.colorWell],
        [self rowWithTitle:@"总重 (g)" control:self.totalField],
        [self rowWithTitle:@"剩余 (g)" control:self.remainingField],
        [self rowWithTitle:@"购入日期" control:self.datePicker],
        [self rowWithTitle:@"备注" control:self.noteView]
    ];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor]
    ]];

    for (NSInteger i = 0; i < rows.count; i++) {
        [stack addArrangedSubview:rows[i]];
        if (i < rows.count - 1) {
            UIView *sep = [[UIView alloc] init];
            sep.backgroundColor = [UIColor separatorColor];
            sep.translatesAutoresizingMaskIntoConstraints = NO;
            [stack addArrangedSubview:sep];
            [sep.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
            [sep.leadingAnchor constraintEqualToAnchor:stack.leadingAnchor constant:16].active = YES;
        }
    }
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)ph {
    UITextField *tf = [[UITextField alloc] init];
    tf.placeholder = ph;
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    [tf.heightAnchor constraintGreaterThanOrEqualToConstant:34].active = YES;
    return tf;
}

- (UIView *)rowWithTitle:(NSString *)title control:(UIView *)control {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.layoutMargins = UIEdgeInsetsMake(10, 16, 10, 16);

    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    lab.textColor = [UIColor secondaryLabelColor];
    lab.translatesAutoresizingMaskIntoConstraints = NO;

    control.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:lab];
    [row addSubview:control];

    [NSLayoutConstraint activateConstraints:@[
        [lab.topAnchor constraintEqualToAnchor:row.topAnchor constant:10],
        [lab.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
        [lab.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
        [control.topAnchor constraintEqualToAnchor:lab.bottomAnchor constant:6],
        [control.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
        [control.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
        [control.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-10]
    ]];
    return row;
}

- (void)setupMaterialMenu {
    NSMutableArray *acts = [NSMutableArray array];
    for (NSString *m in [FilamentItem allMaterials]) {
        UIAction *a = [UIAction actionWithTitle:m image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.material = m;
            [self.materialButton setTitle:m forState:UIControlStateNormal];
        }];
        [acts addObject:a];
    }
    UIMenu *menu = [UIMenu menuWithTitle:@"选择材质" children:acts];
    self.materialButton.menu = menu;
    self.materialButton.showsMenuAsPrimaryAction = YES;
}

#pragma mark - Actions

- (void)saveTapped {
    FilamentItem *item = self.editingItem ?: [[FilamentItem alloc] init];

    item.name = self.nameField.text ?: @"";
    item.brand = self.brandField.text ?: @"";
    item.material = self.material ?: kMaterialPLA;
    if (self.colorWell.selectedColor) {
        item.colorName = FMHexFromColor(self.colorWell.selectedColor);
    }
    NSInteger total = [self.totalField.text integerValue];
    NSInteger remain = [self.remainingField.text integerValue];
    if (total < 0) total = 0;
    if (remain < 0) remain = 0;
    if (remain > total) remain = total;
    item.totalWeight = total;
    item.remainingWeight = remain;
    item.purchaseDate = self.datePicker.date;
    item.note = self.noteView.text ?: @"";

    if (self.editingItem) {
        [[FilamentStore sharedStore] updateItem:item];
    } else {
        [[FilamentStore sharedStore] addItem:item];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
