#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern BOOL isJailbroken;
NSURL *getPyoncordDirectory(void);
UIColor *hexToUIColor(NSString *hex);
void showErrorAlert(NSString *title, NSString *message, void (^completion)(void));