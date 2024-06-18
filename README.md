# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline tool** for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

With RudderStack, you can build customer data pipelines that connect your whole customer data stack and then make them smarter by triggering enrichment and activation in customer tools based on analysis in your data warehouse. Its easy-to-use SDKs and event source integrations, Cloud Extract integrations, transformations, and expansive library of destination and warehouse integrations makes building customer data pipelines for both event streaming and cloud-to-warehouse ELT simple. 

| Try **RudderStack Cloud Free** - a no time limit, no credit card required, completely free tier of [RudderStack Cloud](https://resources.rudderstack.com/rudderstack-cloud). Click [here](https://app.rudderlabs.com/signup?type=freetrial) to start building a smarter customer data pipeline today, with RudderStack Cloud Free. |
|:------|

Questions? Please join our [Slack channel](https://resources.rudderstack.com/join-rudderstack-slack) or read about us on [Product Hunt](https://www.producthunt.com/posts/rudderstack).

## Integrating Firebase with the RudderStack iOS SDK

> **_NOTE:_** `Rudder-Firebase` version `3.3.0` is compatible with the `FirebaseAnalytics` version `10.28.0`. 

1. Add [Firebase](http://firebase.google.com) as a destination in the [RudderStack dashboard](https://app.rudderstack.com/).

2. Rudder-Firebase is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile and followed by `pod install`:

```ruby
pod 'Rudder-Firebase', '~> 3.3.0'
```

3. Download the `GoogleService-Info.plist` from your Firebase console and put it in your project.

## Initializing ```RudderClient```

Put this code in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```
```
RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
[builder withDataPlaneUrl:DATA_PLANE_URL];
[builder withFactory:[RudderFirebaseFactory instance]];
[builder withLoglevel:RSLogLevelDebug];
[RSClient getInstance:WRITE_KEY config:[builder build]];
```

## Setup the sample iOS app

1. Make a copy of the `SampleRudderConfig.plist` into the RudderConfig directory and rename it to `RudderConfig.plist`.
2. Fill the required details e.g., `WRITE_KEY` and `PROD_DATA_PLANE_URL`.
3. Start sending the events

## Sending Events

Follow the steps from the [RudderStack iOS SDK](https://github.com/rudderlabs/rudder-sdk-ios#sending-events) repo.

## Contact Us

If you come across any issues while configuring or using this integration, please feel free to start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
