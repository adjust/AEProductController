AEProductController
===================

Small wrapper for `SKStoreProductViewController` that handles tracking links.

## Why?

Apple's `SKStoreProductViewController` doesn't allow the use of affiliate links. This wrapper offers the convenient user experience of the new In-App App Store view while opening your affiliate link in the background including all redirects.

## How?

Download or clone this repo and add the `AEProductController` subdirectory into your Xcode project by dragging it into the Project Navigator.

Open the source file of your view controller that should present the `SKStoreProductViewController` and add the following line at the top of the file:

    #import "AEProductController.h"

In the private interface of your class add the following property:

    @property (nonatomic) AEProductController *productController;

In the method that should trigger the presentation of the `SKStoreProductViewController` add the following lines:

    self.productController = [AEProductController controllerWithProductId:@"<appId>" callbackUrl:@"<url>"];
    [self.productController showInViewController:self];

Replace the placeholders `<appId>` and `<url>` with your appId and your affiliate link. This appId is part of the iTunes URL: If this was your app `https://itunes.apple.com/us/app/spray-can/id315215396?mt=8`, then your appId would be `315215396`.

This presents the `SKStoreProductViewController` and calls the affiliate link including all redirects in the background.
