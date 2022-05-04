//
//  _AppDelegate.m
//  Rudder-Firebase
//
//  Created by arnabp92 on 02/11/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>
#import "RudderFirebaseFactory.h"

@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *DATA_PLANE_URL = @"https://rudderstacbumvdrexzj.dataplane.rudderstack.com";
    NSString *WRITE_KEY = @"203EnCjvGV6qhvrcaz7MyWiQmJx";
    
    // Override point for customization after application launch.
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
    [builder withFactory:[RudderFirebaseFactory instance]];
    [builder withLoglevel:RSLogLevelNone];
    [builder withTrackLifecycleEvens:@NO];
    [RSClient getInstance:WRITE_KEY config:[builder build]];
    
    [self sendEvents];
    return YES;
}

-(void) sendEvents {
    //    [[RSClient getInstance] reset];
        [self identify1];
    //    [self identify2];
    //    [self trackProductAtRoot];
    //    [self trackProductsArray];
    //    [self trackAllProperty];
    //    [self customTrackCall];
    //    [self screenCall];
        
    //    [[RSClient getInstance] track:@"Order Completed" properties:@{
    //        @"coupon" : @"",
    //        @"extra" : @"",
    //        @"products" : @""
    //    }];
        
        [self track_Payment_Info_Entered];
//        [self track_Product_Added];
//        [self track_Product_Added_to_Wishlist];
//        [self track_Checkout_Started];
//        [self track_Order_Completed];
//        [self track_Order_Refunded];
//        [self track_Products_Searched];
//        [self track_Cart_Shared];
//        [self track_Product_Shared];
//        [self track_Product_Viewed];
//        [self track_Product_List_Viewed];
//        [self track_Product_Removed];
//        [self track_Product_Clicked];
//        [self track_Promotion_Viewed];
//        [self track_Promotion_Clicked];
//        [self track_Cart_Viewed];
}

-(void) track_Payment_Info_Entered {
    [[RSClient getInstance] track:@"Payment Info Entered" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"currency" : @"INR",
        @"revenue" : @"123.23",
        @"value" : @124,
        @"total" : @125,
        @"payment_method" : @"G-PAY",
        @"coupon" : @"Off-100%"
    }];
}

-(void) track_Product_Added {
    [[RSClient getInstance] track:@"Product Added" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"product_id" : @"product_id_4",
        @"currency" : @"INR",
        @"price" : @4000,
        @"quantity" : @400,
        @"category" : @"category_4",
        @"extra" : @"extra_4",
        @"value" : @124,
        @"total" : @125,
    }];
}

-(void) track_Product_Added_to_Wishlist {
    [[RSClient getInstance] track:@"Product Added to Wishlist" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"product_id" : @"product_id_4",
        @"currency" : @"INR",
        @"price" : @4000,
        @"quantity" : @400,
        @"category" : @"category_4",
        @"extra" : @"extra_4",
        @"value" : @"124ajs",
        @"total" : @125,
    }];
}

-(void) track_Checkout_Started {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1_11",
        @"name" : @"name_11",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_22",
        @"name" : @"name_22",
        @"price" : @"2000",
        @"quantity" : @"200",
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    
    [[RSClient getInstance] track:@"Checkout Started" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4", //
        @"products" : products,
        @"value" : @124.23,
        @"total" : @125,
        
        
        @"coupon" : @"Off-100%", //
    }];
}

-(void) track_Order_Completed {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1",
        @"name" : @"name_1",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_2",
        @"name" : @"name_2",
        @"price" : @2000,
        @"quantity" : @200,
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    [[RSClient getInstance] track:@"Order Completed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"products" : products,
        @"revenue" : @"123.56",
        @"value" : @124,
        @"total" : @125,
        @"coupon" : @"Off-100%",
        @"affiliation" : @"affiliation_1",
        @"shipping" : @126,
        @"tax" : @127,
        @"order_id" : @"order_id_1"
    }];
}

-(void) track_Order_Refunded {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1",
        @"name" : @"name_1",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_2",
        @"name" : @"name_2",
        @"price" : @2000,
        @"quantity" : @200,
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    
    [[RSClient getInstance] track:@"Order Refunded" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"products" : products,
        @"revenue" : @"123",
        @"value" : @124,
        @"total" : @125,
        @"coupon" : @100,
        @"affiliation" : @"affiliation_1",
        @"shipping" : @126,
        @"tax" : @127,
        @"order_id" : @"transaction_1"
    }];
}

-(void) track_Products_Searched {
    [[RSClient getInstance] track:@"Products Searched" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"query" : @"www.google.com",
        @"extra" : @567.67
    }];
}

-(void) track_Cart_Shared {
    [[RSClient getInstance] track:@"Cart Shared" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"cart_id" : @"order_id_1",
        @"share_via" : @"share_via_1",
        @"extra" : @567.67
    }];
}

-(void) track_Product_Shared {
    [[RSClient getInstance] track:@"Product Shared" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"share_via" : @"share_via_1",
        @"cart_id" : @"order_id_1"
    }];
}

-(void) track_Product_Viewed {
    [[RSClient getInstance] track:@"Product Viewed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"currency" : @"INR",
        @"price" : @4000,
        @"quantity" : @400,
        @"category" : @"category_4",
        @"extra" : @"extra_4",
        @"revenue" : @"123",
        @"value" : @124,
        @"total" : @125,
    }];
}

-(void) track_Product_List_Viewed {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1",
        @"name" : @"name_1",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_2",
        @"name" : @"name_2",
        @"price" : @2000,
        @"quantity" : @200,
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    
    [[RSClient getInstance] track:@"Product List Viewed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"products" : products,
        @"list_id" : @"list_id_1"
    }];
}

-(void) track_Product_Removed {
    [[RSClient getInstance] track:@"Product Removed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"product_id" : @"product_id_4",
        @"currency" : @"INR",
        @"price" : @4000,
        @"quantity" : @400,
        @"category" : @"category_4",
        @"extra" : @"extra_4",
        @"revenue" : @"123",
        @"value" : @124,
        @"total" : @125
    }];
}

-(void) track_Product_Clicked {
    [[RSClient getInstance] track:@"Product Clicked" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"product_id" : @"product_id_4"
    }];
}

-(void) track_Promotion_Viewed {
    [[RSClient getInstance] track:@"Promotion Viewed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"creative" : @"creative_iOS",
        @"promotion_id" : @"promotion_id_1",
        @"name" : @"name_4"
    }];
}

-(void) track_Promotion_Clicked {
    [[RSClient getInstance] track:@"Promotion Clicked" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"promotion_id" : @"promotion_id_1",
        @"creative" : @"creative_1",
        @"name" : @"name_4"
    }];
}

-(void) track_Cart_Viewed {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1",
        @"name" : @"name_1",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_2",
        @"name" : @"name_2",
        @"price" : @2000,
        @"quantity" : @200,
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    
    [[RSClient getInstance] track:@"Cart Viewed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4",
        @"products" : products,
        @"revenue" : @"123",
        @"value" : @124,
        @"total" : @125
    }];
}

-(void) identify1 {
    [[RSClient getInstance] identify:@"User_id_1"];
}

-(void) identify2 {
//    [[RSClient getInstance] identify:@"User_id_2"];
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"ios": @"Display"}
    ];
}

-(void) screenCall {
    [[RSClient getInstance] screen:@"Screen_1: _AppDelegate_1" properties:@{
        @"Custom_screen_property" : @"Custom_property_6",
    }];
}

-(void) customTrackCall {
    [[RSClient getInstance] track:@"Custom_Track_Call" properties:@{
        @"Custom_track_value_1_askasakjaldjladjaljdaljdajdaldjaljladjladjaljdaljdaljd" : @"Custom_Track_Call_6",
    }];
}

-(void) trackAllProperty {
    [[RSClient getInstance] track:@"Order Completed" properties:@{
        @"Custom_value_4" : @"Custom_Track_Call_4", //
        @"currency" : @"INR", //
        @"price" : @4000, //
        @"quantity" : @400, //
        @"category" : @"category_4", //
        @"extra" : @"extra_4", //
        
        
        
        @"revenue" : @"123", // Double
        @"value" : @124,    //Double
        @"total" : @125,    //Double
        @"payment_method" : @"G-PAY", //
        @"coupon" : @"Off-100%", //
        @"query" : @"www.google.com", //
        @"list_id" : @"list_id_1", //
        @"promotion_id" : @"promotion_id_1", //
        @"creative" : @"creative_1", //
        @"affiliation" : @"affiliation_1",
        @"shipping" : @126, //Double
        @"tax" : @127, //Double
        @"order_id" : @"order_id_1", //
        @"share_via" : @"share_via_1", //
        
        @"cart_id" : @"cart_id_1",
        @"product_id" : @"product_id_4", //
        @"name" : @"name_4", //
    }];
}

-(void) trackProductAtRoot {
    [[RSClient getInstance] track:@"Order Completed" properties:@{
        @"Custom_value_3" : @"Custom_Track_Call_3",
        @"currency" : @"INR",
        @"product_id" : @"product_id_3",
        @"name" : @"name_3",
        @"price" : @3000,
        @"quantity" : @300,
        @"category" : @"category_3",
        @"extra" : @"extra_3"
    }];
}

-(void) trackProductsArray {
    NSDictionary *product1 = @{
        @"product_id" : @"product_id_1",
        @"name" : @"name_1",
        @"price" : @1000,
        @"quantity" : @100,
        @"category" : @"category_1",
        @"extra" : @"extra_1"
    };
    NSDictionary *product2 = @{
        @"product_id" : @"product_id_2",
        @"name" : @"name_2",
        @"price" : @2000,
        @"quantity" : @200,
        @"category" : @"category_2",
        @"extra" : @"extra_2"
    };
    
    NSArray *products = [[NSArray alloc] initWithObjects:product1, product2, nil];
    [[RSClient getInstance] track:@"Order Completed" properties:@{
        @"Custom_value_1" : @"Custom_Track_Call",
        @"currency" : @"INR",
        @"products" : products
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
