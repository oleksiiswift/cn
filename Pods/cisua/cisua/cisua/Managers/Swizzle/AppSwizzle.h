//
//  Swizzle.h
//  cisua
//
//  Created by Anton Litvinov on 28.01.2020.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSwizzle: NSObject

+(AppSwizzle *)shared;

-(void)applicationDidFinishLaunchingWithOptionsHandler:(void (^)(UIApplication*,  NSDictionary<UIApplicationLaunchOptionsKey,id>* _Nullable )) handler;
-(void)applicationDidRegisterForRemoteNotificationsWithDeviceTokenHandler:(void (^)(UIApplication*, NSData*)) handler;
-(void)applicationDidReceiveRemoteNotificationHandler:(void (^)(UIApplication*, NSDictionary*)) handler;

-(void)applicationDidBecomeActiveHandler:(void (^)(UIApplication*)) handler;
-(void)applicationOpenUrlOptionsHandler:(void (^)(UIApplication*, NSURL*,  NSDictionary<UIApplicationOpenURLOptionsKey, id>* _Nullable )) handler;
-(void)applicationContinueUserActivityHandler:(void (^)(UIApplication*, NSUserActivity*)) handler;

@end

NS_ASSUME_NONNULL_END
