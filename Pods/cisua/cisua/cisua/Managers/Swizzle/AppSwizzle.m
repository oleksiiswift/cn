//
//  Swizzle.m
//  cisua
//
//  Created by Anton Litvinov on 28.01.2020.
//

#import "AppSwizzle.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIApplication (AppSwizzle)

//+(void)load {
//    [AppSwizzle shared];
//}

+(Class)delegateClass {
    return [[[UIApplication sharedApplication] delegate] class];
}

@end

@implementation AppSwizzle

typedef void (*ApplicationDidBecomeActiveType)(id self,
                                               SEL selector,
                                               UIApplication *application);
static ApplicationDidBecomeActiveType applicationDidBecomeActiveOriginal;



typedef BOOL (*ApplicationOpenUrlOptionsType)(id self,
                                              SEL selector,
                                              UIApplication *application,
                                              NSURL *url,
                                              NSDictionary<UIApplicationOpenURLOptionsKey, id> *options);
static ApplicationOpenUrlOptionsType applicationOpenUrlOptionsOriginal;


typedef void (^ RestorationHandler)(NSArray<id<UIUserActivityRestoring>>*);
typedef BOOL (*ApplicationContinueUserActivityRestorationType)(id self,
                                                               SEL selector,
                                                               UIApplication *application,
                                                               NSUserActivity *userActivity,
                                                               RestorationHandler restorationHandler);
static ApplicationContinueUserActivityRestorationType applicationContinueUserActivityRestorationOriginal;




typedef BOOL (*ApplicationDidFinishLaunchWithOptionsType)(id self,
                                              SEL selector,
                                              UIApplication *application,
                                              NSDictionary<UIApplicationLaunchOptionsKey,id>* options);
static ApplicationDidFinishLaunchWithOptionsType applicationDidFinishLaunchWithOptionsOriginal;


typedef BOOL (*ApplicationDidRegisterForRemoteNotificationsDeviceTokenType)(id self,
                                              SEL selector,
                                              UIApplication *application,
                                              NSData *deviceToken);
static ApplicationDidRegisterForRemoteNotificationsDeviceTokenType applicationDidRegisterForRemoteNotificationsDeviceTokenOriginal;


typedef void (^ CompletionHandler)(UIBackgroundFetchResult);
typedef BOOL (*ApplicationDidReceiveRemoteNotificationType)(id self,
                                                               SEL selector,
                                                               UIApplication *application,
                                                               NSDictionary *userInfo,
                                                               CompletionHandler completionHandler);
static ApplicationDidReceiveRemoteNotificationType applicationDidReceiveRemoteNotificationOriginal;



+(AppSwizzle *) shared {
    static AppSwizzle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AppSwizzle new];
        [sharedInstance swizzlingLifeCycleMethods];
    });
    return sharedInstance;
}

void (^didBecomeActiveHandler)(UIApplication*);
void (^openUrlOptionsHandler)(UIApplication*, NSURL*, NSDictionary<UIApplicationOpenURLOptionsKey, id>*);
void (^continueUserActivityHandler)(UIApplication*, NSUserActivity*);

void (^didFinishLaunchingWithOptionsHandler)(UIApplication*, NSDictionary<UIApplicationLaunchOptionsKey,id>*);
void (^didRegisterForRemoteNotificationsWithDeviceTokenHandler)(UIApplication*, NSData*);
void (^didReceiveRemoteNotificationHandler)(UIApplication*, NSDictionary*);

-(void)applicationDidFinishLaunchingWithOptionsHandler:(void (^)(UIApplication*, NSDictionary<UIApplicationLaunchOptionsKey,id>*)) handler {
    didFinishLaunchingWithOptionsHandler = handler;
}
-(void)applicationDidRegisterForRemoteNotificationsWithDeviceTokenHandler:(void (^)(UIApplication*, NSData*)) handler {
    didRegisterForRemoteNotificationsWithDeviceTokenHandler = handler;
}
-(void)applicationDidReceiveRemoteNotificationHandler:(void (^)(UIApplication*, NSDictionary*)) handler {
    didReceiveRemoteNotificationHandler = handler;
}

-(void)applicationDidBecomeActiveHandler:(void (^)(UIApplication*)) handler {
    didBecomeActiveHandler = handler;
}

-(void)applicationOpenUrlOptionsHandler:(void (^)(UIApplication*, NSURL*, NSDictionary<UIApplicationOpenURLOptionsKey,id>*)) handler {
    openUrlOptionsHandler = handler;
}

-(void)applicationContinueUserActivityHandler:(void (^)(UIApplication*, NSUserActivity*)) handler {
    continueUserActivityHandler = handler;
}
-(void) swizzlingLifeCycleMethods {
    
    //### applicationDidBecomeActive:
    
    SEL selector = @selector(applicationDidBecomeActive:);
    
    Class delegateClass = UIApplication.delegateClass;
    Class selfClass = [self class];
    
    Method method = class_getInstanceMethod(selfClass,
                                            selector);
    
    BOOL didAddMethod = class_addMethod(delegateClass,
                                        selector,
                                        class_getMethodImplementation(selfClass, selector),
                                        method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    Method delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationDidBecomeActiveOriginal = (ApplicationDidBecomeActiveType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
    
    //### application:openURL:options:
    
    selector = @selector(application:openURL:options:);
    
    method = class_getInstanceMethod(selfClass,
                                     selector);
    
    didAddMethod = class_addMethod(delegateClass,
                                   selector,
                                   class_getMethodImplementation(selfClass, selector),
                                   method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationOpenUrlOptionsOriginal = (ApplicationOpenUrlOptionsType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
    
    //### application:continueUserActivity:restorationHandler:
    
    selector = @selector(application:continueUserActivity:restorationHandler:);
    
    method = class_getInstanceMethod(selfClass,
                                     selector);
    
    didAddMethod = class_addMethod(delegateClass,
                                   selector,
                                   class_getMethodImplementation(selfClass, selector),
                                   method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationContinueUserActivityRestorationOriginal = (ApplicationContinueUserActivityRestorationType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
    
    //### application:didFinishLaunchingWithOptions:
    
    selector = @selector(application:didFinishLaunchingWithOptions:);
    
    method = class_getInstanceMethod(selfClass,
                                     selector);
    
    didAddMethod = class_addMethod(delegateClass,
                                   selector,
                                   class_getMethodImplementation(selfClass, selector),
                                   method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationDidFinishLaunchWithOptionsOriginal = (ApplicationDidFinishLaunchWithOptionsType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
    if ([(NSArray*)[[NSBundle bundleForClass:UIApplication.delegateClass] objectForInfoDictionaryKey:@"UIBackgroundModes"] containsObject:@"remote-notification"] == NO) {
        return;
    }
    
    //### application:didRegisterForRemoteNotificationsWithDeviceToken:
    
    selector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    
    method = class_getInstanceMethod(selfClass,
                                     selector);
    
    didAddMethod = class_addMethod(delegateClass,
                                   selector,
                                   class_getMethodImplementation(selfClass, selector),
                                   method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationDidRegisterForRemoteNotificationsDeviceTokenOriginal = (ApplicationDidRegisterForRemoteNotificationsDeviceTokenType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
    
    //### application:didReceiveRemoteNotification:fetchCompletionHandler:
    
    selector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
    
    method = class_getInstanceMethod(selfClass,
                                     selector);
    
    didAddMethod = class_addMethod(delegateClass,
                                   selector,
                                   class_getMethodImplementation(selfClass, selector),
                                   method_getTypeEncoding(method));
    
    NSAssert(!didAddMethod, @"You should implement %@ in your AppDelegate", NSStringFromSelector(selector));
    
    delegateMethod = class_getInstanceMethod(delegateClass, selector);
    applicationDidReceiveRemoteNotificationOriginal = (ApplicationDidReceiveRemoteNotificationType) method_getImplementation(delegateMethod);
    
    method_exchangeImplementations(method, delegateMethod);
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    if (didBecomeActiveHandler != NULL) { didBecomeActiveHandler(application); }
    applicationDidBecomeActiveOriginal(self, _cmd, application);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    openUrlOptionsHandler(application, url, options);
    return applicationOpenUrlOptionsOriginal(self, _cmd, application, url, options);
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {
    if (continueUserActivityHandler != NULL) { continueUserActivityHandler(application, userActivity); }
    return applicationContinueUserActivityRestorationOriginal(self, _cmd, application, userActivity, restorationHandler);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    if (didFinishLaunchingWithOptionsHandler != NULL) { didFinishLaunchingWithOptionsHandler(application, launchOptions); }
    return applicationDidFinishLaunchWithOptionsOriginal(self, _cmd, application, launchOptions);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (didRegisterForRemoteNotificationsWithDeviceTokenHandler != NULL) { didRegisterForRemoteNotificationsWithDeviceTokenHandler(application, deviceToken); }
    applicationDidRegisterForRemoteNotificationsDeviceTokenOriginal(self, _cmd, application, deviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (didReceiveRemoteNotificationHandler != NULL) { didReceiveRemoteNotificationHandler(application, userInfo); }
    applicationDidReceiveRemoteNotificationOriginal(self, _cmd, application, userInfo, completionHandler);
}

@end
