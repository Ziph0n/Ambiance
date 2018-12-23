#import <UIKit/UIKit.h>
#import <substrate.h>
#import <spawn.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <objc/runtime.h>

#ifdef __cplusplus
extern "C" {
#endif
    
void FBShowTwitterFollowAlert(NSString *title, NSString *welcomeMessage, NSString *twitterUsername);
 
void FBOpenTwitterUsername(NSString *username);

#ifdef __cplusplus
}
#endif
