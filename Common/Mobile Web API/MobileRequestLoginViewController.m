#import <QuartzCore/QuartzCore.h>

#import "MobileRequestLoginViewController.h"
#import "MobileKeychainServices.h"

@interface MobileRequestLoginViewController ()
@property (nonatomic,retain) NSDictionary *tableCells;

@property (nonatomic,assign) UITableView *tableView;
@property (nonatomic,assign) UITextField *usernameField;
@property (nonatomic,assign) UITextField *passwordField;
@property (nonatomic,assign) UISwitch *saveCredentials;
@property (nonatomic,assign) UIButton *loginButton;

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,retain) UIView *activityView;

@property (nonatomic) BOOL dismissAfterAlert;

@property (nonatomic,readonly) BOOL shouldSaveLogin;
@property (nonatomic) BOOL showActivityView;

- (void)setupTableCells;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
@end

@implementation MobileRequestLoginViewController
#pragma mark -
@synthesize delegate = _delegate;

@synthesize activityView = _activityView;
@synthesize dismissAfterAlert = _dismissAfterAlert;
@synthesize loginButton = _loginButton;
@synthesize password = _password;
@synthesize passwordField = _passwordField;
@synthesize saveCredentials = _saveCredentials;
@synthesize tableCells = _tableCells;
@synthesize tableView = _tableView;
@synthesize username = _username;
@synthesize usernameField = _usernameField;

@dynamic shouldSaveLogin;
@dynamic showActivityView;
#pragma mark -

- (id)initWithIdentifier:(NSString*)identifier {
    NSDictionary *keychainItem = MobileKeychainFindItem(identifier, YES);
    
    return [self initWithUsername:[keychainItem objectForKey:(id)kSecAttrAccount]
                         password:[keychainItem objectForKey:(id)kSecValueData]];
}

- (id)initWithUsername:(NSString*)aUsername password:(NSString*)aPassword;
{
    self = [super init];
    if (self) {
        self.username = aUsername;
        self.password = aPassword;
        self.wantsFullScreenLayout = YES;
    }
    
    return self;
}

- (void)dealloc {
    self.username = nil;
    self.password = nil;
    self.tableCells = nil;
    self.activityView = nil;
    [super dealloc];
}

#pragma mark - View Setup
- (void)setupTableCells
{
    NSMutableDictionary *cells = [NSMutableDictionary dictionary];
    UIEdgeInsets textCellInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    
    {
        UITableViewCell *usernameCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *userField = [[[UITextField alloc] init] autorelease];
        userField.adjustsFontSizeToFitWidth = YES;
        userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userField.autocorrectionType = UITextAutocorrectionTypeNo;
        userField.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight);
        userField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        userField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        userField.delegate = self;
        userField.keyboardType = UIKeyboardTypeEmailAddress;
        userField.minimumFontSize = 10.0;
        userField.placeholder = @"Username or Email";
        userField.returnKeyType = UIReturnKeyNext;
        userField.textAlignment = UITextAlignmentLeft;
        
        if ([self.username length]) {
            userField.text = self.username;
        }
        
        userField.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, 320, 40), textCellInsets);
        
        self.usernameField = userField;
        [usernameCell.contentView addSubview:userField];
        [cells setObject:usernameCell
                  forKey:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    {
        UITextField *passField = [[[UITextField alloc] init] autorelease];
        passField.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth);
        passField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        passField.delegate = self;
        passField.placeholder = @"Password";
        passField.returnKeyType = UIReturnKeyDone;
        passField.secureTextEntry = YES;
        
        if ([self.password length]) {
            passField.text = self.password;
        }
        
        passField.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, 320, 40), textCellInsets);
        
        self.passwordField = passField;
        
        UITableViewCell *passwordCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [passwordCell.contentView addSubview:passField];
        
        [cells setObject:passwordCell
                  forKey:[NSIndexPath indexPathForRow:1 inSection:0]];
    }
    
    {
        UITableViewCell *buttonCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        buttonCell.accessoryType = UITableViewCellAccessoryNone;
        buttonCell.editingAccessoryType = UITableViewCellAccessoryNone;
        buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        buttonCell.backgroundColor = [UIColor clearColor];
        buttonCell.layer.borderWidth = 0;
        buttonCell.userInteractionEnabled = YES;
        [buttonCell layoutIfNeeded];
        
        UIView *transparentView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,44)] autorelease];
        transparentView.backgroundColor = [UIColor clearColor];
        [buttonCell setBackgroundView:transparentView];
        
        UIEdgeInsets buttonInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        CGRect loginFrame = CGRectMake(0,0,320,44);
        loginFrame = UIEdgeInsetsInsetRect(loginFrame, buttonInsets);
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        loginButton.frame = loginFrame;
        loginButton.enabled = NO;
        
        [loginButton setTitle:@"Log In"
                     forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor grayColor]
                     forState:UIControlStateDisabled];
        [loginButton addTarget:self
                        action:@selector(loginButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        
        self.loginButton = loginButton;
        [buttonCell addSubview:loginButton];
        
        [cells setObject:buttonCell
                  forKey:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    
    {
        UISwitch *saveToggle = [[[UISwitch alloc] init] autorelease];
        saveToggle.on = ([self.username length] > 0);

        UITableViewCell *saveCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        saveCell.selectionStyle = UITableViewCellSelectionStyleNone;
        saveCell.accessoryView = saveToggle;
        
        saveCell.textLabel.text = @"Remember Login?";
        
        [cells setObject:saveCell
                  forKey:[NSIndexPath indexPathForRow:0 inSection:2]];
    }
    
    NSLog(@"Created %d cells", [cells count]);
    self.tableCells = cells;
}

- (void)loadView {
    CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:mainFrame];
    CGPoint origin = mainFrame.origin;
    
    mainView.backgroundColor = [UIColor colorWithRed:0.725
                                               green:0.776
                                                blue:0.839
                                               alpha:1.0];
    [self setupTableCells];
    
    {
        CGRect navBarFrame = CGRectMake(origin.x, origin.y, 320, 44);
        UINavigationBar *navBar = [[[UINavigationBar alloc] initWithFrame:navBarFrame] autorelease];
        UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle:@"Touchstone"] autorelease];
        UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(cancelButtonPressed:)] autorelease];
        [navItem setLeftBarButtonItem:cancelItem];
        [navBar setItems:[NSArray arrayWithObject:navItem]];
        
        origin.y = CGRectGetMaxY(navBarFrame);
        
        [mainView addSubview:navBar];
    }
    
    {
        UITableView *tableView = [[[UITableView alloc] initWithFrame:CGRectZero
                                                               style:UITableViewStyleGrouped] autorelease];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        
        CGRect tableViewRect = CGRectZero;
        tableViewRect.origin = origin;
        tableViewRect.size = mainFrame.size;
        tableView.frame = tableViewRect;
        
        origin.y = CGRectGetMaxY(tableViewRect);
        self.tableView = tableView;
        [mainView addSubview:tableView];
    }
    
    {
        UIView *promptView = [[[UIView alloc] initWithFrame:CGRectMake(64, 164, 190, 132)] autorelease];
        promptView.backgroundColor = [UIColor colorWithWhite:0.0
                                                       alpha:1.0];
        promptView.layer.borderColor = [[UIColor whiteColor] CGColor];
        promptView.layer.borderWidth = 2.0;
        promptView.layer.cornerRadius = 5.0;
        
        {
            UILabel *infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 47)] autorelease];
            infoLabel.text = @"Logging into Touchstone";
            infoLabel.numberOfLines = 2;
            infoLabel.lineBreakMode = UILineBreakModeWordWrap;
            infoLabel.backgroundColor = [UIColor clearColor];
            infoLabel.textAlignment = UITextAlignmentCenter;
            infoLabel.textColor = [UIColor whiteColor];
            [promptView addSubview:infoLabel];
        }
        
        {
            UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
            activityView.frame = CGRectMake(77, 75, 37, 37);
            activityView.hidesWhenStopped = NO;
            [activityView startAnimating];
            [promptView addSubview:activityView];
        }
        
        self.activityView = promptView;
    }
    
    [self setView:[mainView autorelease]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Event Handlers
- (IBAction)cancelButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate cancelWasPressedForLoginRequest:self];
    }
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)loginButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate loginRequest:self
                 didEndWithUsername:self.usernameField.text
                           password:self.passwordField.text
                    shouldSaveLogin:self.shouldSaveLogin];
    }
    
    self.showActivityView = YES;
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    CGRect tableFrame = self.tableView.frame;
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardFrame = [self.view convertRect:keyboardFrame
                                  fromView:nil];
    
    tableFrame.size.height -= keyboardFrame.origin.y;
    self.tableView.frame = tableFrame;
    [self.view setNeedsLayout];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tableFrame = self.tableView.frame;
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    keyboardFrame = [self.view convertRect:keyboardFrame
                                  fromView:nil];
    
    tableFrame.size.height += keyboardFrame.origin.y;
    self.tableView.frame = tableFrame;
}


#pragma mark - Dynamic Property Methods
- (void)setShowActivityView:(BOOL)showView
{
    if (showView)
    {
        if (self.activityView.superview == nil)
        {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self.usernameField resignFirstResponder];
            [self.passwordField resignFirstResponder];
            [self.view addSubview:self.activityView];
        }
    }
    else
    {
        if (self.activityView.superview)
        {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.usernameField resignFirstResponder];
            [self.passwordField resignFirstResponder];
            [self.activityView removeFromSuperview];
        }
    }
}

- (BOOL)showActivityView
{
    return ([self.activityView isDescendantOfView:self.view] == NO);
}

- (BOOL)shouldSaveLogin
{
    return self.saveCredentials.isOn;
}


#pragma mark - Public Methods
- (void)authenticationDidFailWithError:(NSString*)error
                             willRetry:(BOOL)retry
{
    self.showActivityView = NO;
    self.dismissAfterAlert = !retry;
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Touchstone"
                                                     message:error
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK",nil] autorelease];
    alert.delegate = self;
    [alert show];
}

- (void)authenticationDidSucceed
{
    self.showActivityView = NO;
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.loginButton.enabled = ([self.usernameField.text length] > 0) && ([self.passwordField.text length] > 0);
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    } else if ([string isEqualToString:@"\t"]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameField])
    {
        [self.passwordField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.dismissAfterAlert)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UITableView Data Source
- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableCells objectForKey:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger maxSection = 0;
    
    for (NSIndexPath *indexPath in self.tableCells)
    {
        if (indexPath.section > maxSection)
        {
            maxSection = indexPath.section;
        }
    }
    
    return (maxSection + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    for (NSIndexPath *indexPath in self.tableCells)
    {
        if (indexPath.section == section)
        {
            ++rowCount;
        }
    }
    
    return rowCount;
}

@end
