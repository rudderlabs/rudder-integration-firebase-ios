//
//  _ViewController.m
//  Rudder-Firebase
//
//  Created by arnabp92 on 02/11/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

RSClient *client;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    client = [RSClient sharedInstance];
}

- (IBAction)identify:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *traits = [[NSMutableDictionary alloc] init];
    [traits setValue:@"random@example.com" forKey:@"email"];
    [traits setValue:@"FirstName" forKey:@"fname"];
    [traits setValue:@"LastName" forKey:@"lname"];
    [traits setValue:@"1234567890" forKey:@"phone"];
    [client identify:@"iOS User 1" traits:traits];
}

// Events with multiple products array
- (IBAction)checkoutStartedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    
    [client track:@"Checkout Started" properties:properties];
}

- (IBAction)orderCompletedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    [client track:@"Order Completed" properties:properties];
    
    properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@(200) forKey:@"value"];
    [client track:@"Order Completed" properties:properties];
    
    properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@(300) forKey:@"total"];
    [client track:@"Order Completed" properties:properties];
}

- (IBAction)orderRefundedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    [client track:@"Order Refunded" properties:properties];
}

- (IBAction)productListViewedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    [client track:@"Product List Viewed" properties:properties];
}

- (IBAction)cartViewedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    [client track:@"Cart Viewed" properties:properties];
}

// Events with single products array

- (IBAction)productAddedEvent:(id)sender {
    [client track:@"Product Added" properties:[self getStandardCustomAndProductAtRoot]];
}

- (IBAction)productAddedToWishlistEvent:(id)sender {
    [client track:@"Product Added to Wishlist" properties:[self getStandardCustomAndProductAtRoot]];
}

- (IBAction)productViewedEvent:(id)sender {
    [client track:@"Product Viewed" properties:[self getStandardCustomAndProductAtRoot]];
}

- (IBAction)productRemovedEvent:(id)sender {
    [client track:@"Product Removed" properties:[self getStandardCustomAndProductAtRoot]];
}

// Events without products properties
- (IBAction)paymentInfoEnteredEvent:(id)sender {
    [client track:@"Payment Info Entered" properties:[self getStandardAndCustomProperties]];
}

- (IBAction)productsSearchedEvent:(id)sender {
    [client track:@"Products Searched" properties:[self getStandardAndCustomProperties]];
}

- (IBAction)cartSharedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"item value - 1" forKey:@"cart_id"];
    [client track:@"Cart Shared" properties:properties];
    
    properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"item value - 2" forKey:@"product_id"];
    [client track:@"Cart Shared" properties:properties];
}

- (IBAction)productSharedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"item value - 1" forKey:@"cart_id"];
    [client track:@"Product Shared" properties:properties];
    
    properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"item value - 2" forKey:@"product_id"];
    [client track:@"Product Shared" properties:properties];
}

- (IBAction)productClickedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"Item id - 1" forKey:@"product_id"];
    [client track:@"Product Clicked" properties:properties];
}

- (IBAction)promotionViewedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"promotion name-1" forKey:@"name"];
    [client track:@"Promotion Viewed" properties:properties];
}

- (IBAction)promotionClickedEvent:(id)sender {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:@"promotion name-1" forKey:@"name"];
    [client track:@"Promotion Clicked" properties:properties];
}

-(NSMutableArray *) getMultipleProducts {
    NSMutableDictionary *product1 = [[NSMutableDictionary alloc] init];
    [product1 setObject:@"RSPro1" forKey:@"product_id"];
    [product1 setObject:@"RSMonopoly1" forKey:@"name"];
    [product1 setObject:@(1000.2) forKey:@"price"];
    [product1 setObject:@"100" forKey:@"quantity"];
    [product1 setObject:@"RSCat1" forKey:@"category"];
    
    NSMutableDictionary *product2 = [[NSMutableDictionary alloc] init];
    [product2 setObject:@"Pro2" forKey:@"product_id"];
    [product2 setObject:@"Games2" forKey:@"name"];
    [product2 setObject:@"2000.20" forKey:@"price"];
    [product2 setObject:@(200) forKey:@"quantity"];
    [product2 setObject:@"RSCat2" forKey:@"category"];
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    [products addObject:product1];
    [products addObject:product2];
    
    return products;
}

-(NSMutableDictionary<NSString *,NSObject *> *) getStandardAndCustomProperties {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@(100.0) forKey:@"revenue"];
    [properties setValue:@"payment type 1" forKey:@"payment_method"];
    [properties setValue:@"100% off coupon" forKey:@"coupon"];
    [properties setValue:@"Search query" forKey:@"query"];
    [properties setValue:@"item list id 1" forKey:@"list_id"];
    [properties setValue:@"promotion id 1" forKey:@"promotion_id"];
    [properties setValue:@"creative name 1" forKey:@"creative"];
    [properties setValue:@"affiliation value 1" forKey:@"affiliation"];
    [properties setValue:@"method 1" forKey:@"share_via"];
    [properties setValue:@"INR" forKey:@"currency"];
    [properties setValue:@"500" forKey:@"shipping"];
    [properties setValue:@(15) forKey:@"tax"];
    [properties setValue:@"transaction id 1" forKey:@"order_id"];
    [properties setValue:@"value 1" forKey:@"key1"];
    [properties setValue:@(100) forKey:@"key2"];
    [properties setValue:@(200.25) forKey:@"key3"];
    
    return  properties;
}

-(NSMutableDictionary<NSString *,NSObject *> *) getStandardCustomAndProductAtRoot {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    //Product properties at root
    [properties setValue:@"RSPro1" forKey:@"product_id"];
    [properties setValue:@"RSMonopoly1" forKey:@"name"];
    [properties setValue:@(1000.2) forKey:@"price"];
    [properties setValue:@"100" forKey:@"quantity"];
    [properties setValue:@"RSCat1" forKey:@"category"];
    
    return properties;
}

// Custom events

- (IBAction)customTrackEventWithoutProperties:(id)sender {
    [client track:@"Track Event 1"];
}

- (IBAction)customTrackEventWithProperties:(id)sender {
    [client track:@"Track Event 2" properties:[self getCustomProperties]];
}

// Screen events

- (IBAction)screenEventWithoutProperties:(id)sender {
    [client screen:@"View Controller 1"];
}

- (IBAction)screenEventWithProperties:(id)sender {
    [client screen:@"View Controller 2" properties:[self getCustomProperties]];
}

-(NSMutableDictionary<NSString *,NSObject *> *) getCustomProperties {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@"value 1" forKey:@"key1"];
    [properties setValue:@(100) forKey:@"key2"];
    [properties setValue:@(200.25) forKey:@"key3"];
    
    return properties;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
