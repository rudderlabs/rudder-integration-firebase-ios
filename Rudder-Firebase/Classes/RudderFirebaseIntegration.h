//
//  RudderAdjustIntegration.h
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import "RudderUtils.h"

@import FirebaseCore;
@import FirebaseAnalytics;

NS_ASSUME_NONNULL_BEGIN

@interface RudderFirebaseIntegration : NSObject<RSIntegration>

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig*) rudderConfig;

@property (strong) RudderUtils *rudderUtils;

@end

NS_ASSUME_NONNULL_END
