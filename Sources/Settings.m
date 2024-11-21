#import "Settings.h"
#import "Logger.h"
#import "Utils.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <objc/message.h>

extern id gBridge;

@implementation BunnySettingsViewController

- (instancetype)initWithVersion:(NSString *)version {
    self = [super init];
    if (self) {
        self.title = [NSString stringWithFormat:@"Bunny v%@ Recovery Menu", version];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStyleInsetGrouped];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate                                  = self;
    tableView.dataSource                                = self;
    [self.view addSubview:tableView];

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }

    NSArray *options = @[
        @{
            @"title" : @"Refetch Bundle",
            @"icon" : @"arrow.triangle.2.circlepath",
            @"destructive" : @NO
        },
        @{@"title" : @"Load Custom Bundle", @"icon" : @"link.badge.plus", @"destructive" : @NO}, @{
            @"title" : @"Reset Custom Bundle URL",
            @"icon" : @"arrow.counterclockwise",
            @"destructive" : @YES
        },
        @{@"title" : @"Delete All Plugins", @"icon" : @"trash", @"destructive" : @YES},
        @{@"title" : @"Delete All Themes", @"icon" : @"trash", @"destructive" : @YES},
        @{@"title" : @"Delete All Mod Data", @"icon" : @"trash.fill", @"destructive" : @YES},
        @{@"title" : @"Open App Folder", @"icon" : @"folder", @"destructive" : @NO}, @{
            @"title" : @"Open GitHub Issue",
            @"icon" : @"exclamationmark.bubble",
            @"destructive" : @NO
        }
    ];

    NSDictionary *option = options[indexPath.row];
    cell.textLabel.text  = option[@"title"];

    UIImageConfiguration *config =
        [UIImageSymbolConfiguration configurationWithPointSize:22
                                                        weight:UIImageSymbolWeightRegular];
    UIImage *icon        = [UIImage systemImageNamed:option[@"icon"] withConfiguration:config];
    cell.imageView.image = icon;
    cell.imageView.tintColor =
        [option[@"destructive"] boolValue] ? UIColor.systemRedColor : UIColor.systemBlueColor;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    void (^performAction)(void) = ^{
        switch (indexPath.row) {
        case 0:
            [self refetchBundle];
            break;
        case 1:
            [self loadCustomBundle];
            break;
        case 2:
            [self resetCustomBundle];
            break;
        case 3:
            [self deletePlugins];
            break;
        case 4:
            [self deleteThemes];
            break;
        case 5:
            [self deleteAllData];
            break;
        case 6:
            [self openDocumentsDirectory];
            break;
        case 7:
            [self openGitHub];
            break;
        }
    };

    if (indexPath.row !=
        1) {
        NSString *actionText;
        switch (indexPath.row) {
        case 0:
            actionText = @"refetch the bundle";
            break;
        case 2:
            actionText = @"reset the custom bundle URL";
            break;
        case 3:
            actionText = @"delete all plugins";
            break;
        case 4:
            actionText = @"delete all themes";
            break;
        case 5:
            actionText = @"delete all mod data";
            break;
        case 6:
            actionText = @"open the app folder";
            break;
        case 7:
            actionText = @"open a GitHub issue";
            break;
        default:
            actionText = @"perform this action";
            break;
        }

        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Confirm Action"
                             message:[NSString stringWithFormat:@"Are you sure you want to %@?",
                                                                actionText]
                      preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction
                             actionWithTitle:@"Confirm"
                                       style:UIAlertActionStyleDestructive
                                     handler:^(UIAlertAction *action) { performAction(); }]];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        performAction();
    }
}

- (void)reloadApp {
    [self
        dismissViewControllerAnimated:NO
                           completion:^{
                               if (gBridge &&
                                   [gBridge isKindOfClass:NSClassFromString(@"RCTCxxBridge")]) {
                                   BunnyLog(@"Found stored bridge reference");

                                   SEL reloadSelector = NSSelectorFromString(@"reload");
                                   if ([gBridge respondsToSelector:reloadSelector]) {
                                       BunnyLog(@"Found reload method, attempting to call");
                                       ((void (*)(id, SEL))objc_msgSend)(gBridge, reloadSelector);
                                       return;
                                   }
                               }

                               BunnyLog(@"Falling back to exit method");
                               UIApplication *app = [UIApplication sharedApplication];
                               ((void (*)(id, SEL))objc_msgSend)(app, @selector(suspend));
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC),
                                              dispatch_get_main_queue(), ^{ exit(0); });
                           }];
}

- (void)refetchBundle {
    [[NSFileManager defaultManager]
        removeItemAtURL:[getPyoncordDirectory() URLByAppendingPathComponent:@"bundle.js"]
                  error:nil];
    [self reloadApp];
}

- (void)openDocumentsDirectory {
    NSURL *documentsURL =
        [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                inDomains:NSUserDomainMask] firstObject];
    if (isJailbroken) {
        NSString *filzaPath = [NSString stringWithFormat:@"filza://view%@", documentsURL.path];
        NSURL *filzaURL =
            [NSURL URLWithString:[filzaPath stringByAddingPercentEncodingWithAllowedCharacters:
                                                [NSCharacterSet URLQueryAllowedCharacterSet]]];

        if ([[UIApplication sharedApplication] canOpenURL:filzaURL]) {
            [[UIApplication sharedApplication] openURL:filzaURL options:@{} completionHandler:nil];
        } else {
            UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
                initForOpeningContentTypes:@[ UTTypeFolder ]];
            picker.directoryURL                    = documentsURL;
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else {
        UIDocumentPickerViewController *picker =
            [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[ UTTypeFolder ]];
        picker.directoryURL = documentsURL;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)deleteAllData {
    [[NSFileManager defaultManager] removeItemAtURL:getPyoncordDirectory() error:nil];
    [self reloadApp];
}

- (void)openGitHub {
    UIDevice *device = [UIDevice currentDevice];
    NSString *appVersion =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    NSString *body =
        [NSString stringWithFormat:@"### Device Information\n"
                                    "- Device: %@\n"
                                    "- iOS Version: %@\n"
                                    "- Tweak Version: %@\n"
                                    "- App Version: %@ (%@)\n"
                                    "- Jailbroken: %@\n\n"
                                    "### Issue Description\n"
                                    "<!-- Describe your issue here -->\n\n"
                                    "### Steps to Reproduce\n"
                                    "1. \n2. \n3. \n\n"
                                    "### Expected Behavior\n\n"
                                    "### Actual Behavior\n",
                                   device.model, device.systemVersion, PACKAGE_VERSION, appVersion,
                                   buildNumber, isJailbroken ? @"Yes" : @"No"];

    NSString *encodedBody =
        [body stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                     URLQueryAllowedCharacterSet]];
    NSString *encodedTitle = [@"bug(iOS): "
        stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                               URLQueryAllowedCharacterSet]];
    NSString *urlString    = [NSString
        stringWithFormat:@"https://github.com/bunny-mod/BunnyTweak/issues/new?title=%@&body=%@",
                         encodedTitle, encodedBody];
    NSURL *url             = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)loadCustomBundle {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Load Custom Bundle"
                                            message:@"Enter the URL for your custom bundle:"
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder            = @"https://example.com/bundle.js";
        textField.keyboardType           = UIKeyboardTypeURL;
        textField.autocorrectionType     = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];

    UIAlertAction *loadAction = [UIAlertAction
        actionWithTitle:@"Load"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                    NSString *urlString = alert.textFields.firstObject.text;
                    if (urlString.length == 0) {
                        [self presentViewController:alert animated:YES completion:nil];
                        showErrorAlert(@"Invalid URL", @"Please enter a URL", nil);
                        return;
                    }

                    NSURL *url = [NSURL URLWithString:urlString];
                    if (!url || !url.scheme || !url.host) {
                        [self presentViewController:alert animated:YES completion:nil];
                        showErrorAlert(
                            @"Invalid URL",
                            @"Please enter a valid URL (e.g., https://example.com/bundle.js)", nil);
                        return;
                    }

                    if (![url.scheme isEqualToString:@"http"] &&
                        ![url.scheme isEqualToString:@"https"]) {
                        [self presentViewController:alert animated:YES completion:nil];
                        showErrorAlert(@"Invalid URL", @"URL must start with http:// or https://",
                                       nil);
                        return;
                    }

                    NSURLSession *session =
                        [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                                   defaultSessionConfiguration]];
                    [[session
                          dataTaskWithURL:url
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (error) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(
                                        @"Connection Error",
                                        [NSString stringWithFormat:@"Could not reach URL: %@",
                                                                   error.localizedDescription],
                                        nil);
                                    return;
                                }

                                if (!data) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(@"Error", @"No data received from URL", nil);
                                    return;
                                }

                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                if (httpResponse.statusCode != 200) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(
                                        @"Error",
                                        [NSString stringWithFormat:@"Server returned error %ld",
                                                                   (long)httpResponse.statusCode],
                                        nil);
                                    return;
                                }

                                NSString *contentType =
                                    httpResponse.allHeaderFields[@"Content-Type"];
                                if (![contentType containsString:@"javascript"] &&
                                    ![contentType containsString:@"text"]) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(@"Invalid Content",
                                                   @"URL must point to a JavaScript file", nil);
                                    return;
                                }

                                NSDictionary *config =
                                    @{@"customLoadUrlEnabled" : @YES,
                                      @"customLoadUrl" : urlString};
                                NSError *jsonError = nil;
                                NSData *jsonData =
                                    [NSJSONSerialization dataWithJSONObject:config
                                                                    options:0
                                                                      error:&jsonError];
                                if (jsonError) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(@"Error", @"Failed to save configuration", nil);
                                    return;
                                }

                                NSError *writeError = nil;
                                [jsonData writeToURL:[getPyoncordDirectory()
                                                         URLByAppendingPathComponent:@"loader.json"]
                                             options:NSDataWritingAtomic
                                               error:&writeError];
                                if (writeError) {
                                    [self presentViewController:alert animated:YES completion:nil];
                                    showErrorAlert(@"Error", @"Failed to save configuration file",
                                                   nil);
                                    return;
                                }

                                [self reloadApp];
                            });
                        }] resume];
                }];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:loadAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deletePlugins {
    [[NSFileManager defaultManager]
        removeItemAtURL:[getPyoncordDirectory() URLByAppendingPathComponent:@"plugins"]
                  error:nil];
    [self reloadApp];
}

- (void)deleteThemes {
    [[NSFileManager defaultManager]
        removeItemAtURL:[getPyoncordDirectory() URLByAppendingPathComponent:@"themes"]
                  error:nil];
    [self reloadApp];
}

- (void)resetCustomBundle {
    [[NSFileManager defaultManager]
        removeItemAtURL:[getPyoncordDirectory() URLByAppendingPathComponent:@"loader.json"]
                  error:nil];
    [self reloadApp];
}

@end

void showSettingsSheet(void) {
    BunnySettingsViewController *settingsVC =
        [[BunnySettingsViewController alloc] initWithVersion:PACKAGE_VERSION];

    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:settingsVC
                                                      action:@selector(dismiss)];
    settingsVC.navigationItem.rightBarButtonItem = doneButton;

    UIWindow *window = nil;
    NSSet *scenes    = [[UIApplication sharedApplication] connectedScenes];
    for (UIScene *scene in scenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            window = ((UIWindowScene *)scene).windows.firstObject;
            break;
        }
    }
    [window.rootViewController presentViewController:navController animated:YES completion:nil];
}