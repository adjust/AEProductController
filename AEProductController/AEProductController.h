//
//  AEProductController.h
//  AEProductController
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AEProductController : NSObject

// Check if SKStoreProductViewController is available.
// Use AEProductController only if this returns YES.
+ (BOOL)isAvailable;

- (id)initWithProductId:(NSString *)productId callbackUrl:(NSString *)callbackUrl;
+ (AEProductController *)controllerWithProductId:(NSString *)productId callbackUrl:(NSString *)callbackUrl;

- (void)showInViewController:(UIViewController *)viewController;

@end
