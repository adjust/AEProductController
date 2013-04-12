//
//  AEProductController.m
//  AEProductController
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AEProductController.h"
#import "AFNetworking.h"
#import "AELogger.h"
#import <StoreKit/StoreKit.h>

@interface AEProductController() <SKStoreProductViewControllerDelegate>

@property (copy) NSString *productId;
@property (copy) NSString *callbackUrl;
@property (retain) AELogger *logger;
@property (retain) NSURL *iTunesURL;

@end


@implementation AEProductController

+ (BOOL)isAvailable {
    BOOL available = (NSClassFromString(@"SKStoreProductViewController") != nil);
    return available;
}

- (id)initWithProductId:(NSString *)product callbackUrl:(NSString *)callback {
    self = [super init];
    if (self == nil) return nil;

    self.productId = product;
    self.callbackUrl = callback;
    self.logger = [AELogger loggerWithTag:@"AEProductController" enabled:YES];

    return self;
}

+ (AEProductController *)controllerWithProductId:(NSString *)productId callbackUrl:(NSString *)callbackUrl {
    return [[[AEProductController alloc] initWithProductId:productId callbackUrl:callbackUrl] autorelease];
}

- (void)showInViewController:(UIViewController *)viewController {
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ([[vComp objectAtIndex:0] intValue] >= 6) {
        // Prepare the product view controller by providing the product ID.
        SKStoreProductViewController *productViewController = [[[SKStoreProductViewController alloc] init] autorelease];
        productViewController.delegate = self;
        NSDictionary *storeParameters = [NSDictionary dictionaryWithObject:self.productId forKey:SKStoreProductParameterITunesItemIdentifier];
        
        // Present the product view controller
        [viewController presentViewController:productViewController animated:YES completion:^(void) {
            [self.logger log:@"Presented product view controller."];
        }];
        
        // Try to load the product and dismiss the product view controller in case of failure
        [productViewController loadProductWithParameters:storeParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self.logger log:@"Presented product: %@", self.productId];
            } else {
                [self.logger log:@"Failed to load product: %@", error];
            }
        }];
        
        // Execute the callback and follow all redirects
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.callbackUrl]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
            NSString *url = request.URL.absoluteString;
            if (redirectResponse == nil) {
                [self.logger log:@"Callback started: %@", url];
            } else {
                [self.logger log:@"Callback redirected to: %@", url];
            }
            return request;
        }];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.logger log:@"Callback finished."];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.logger log:@"Callback failed."];
        }];
        [operation start];
    } else {
        // Open AppStore app if iOS version < 6
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:callbackUrl]] delegate:self startImmediately:YES];
        [conn release];
    }
}

// SKStoreProductViewControllerDelegate method that dismisses the product view controller
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [self.logger log:@"Dismissed product view controller."];
    }];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.iTunesURL = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] openURL:self.iTunesURL];
}

@synthesize productId;
@synthesize callbackUrl;
@synthesize iTunesURL;

@end
