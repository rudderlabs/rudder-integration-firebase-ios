require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))


firebase_sdk_version = '~> 11.15.0'
rudder_sdk_version = '~> 1.29'
deployment_target = '13.0'
firebase_analytics = 'FirebaseAnalytics'

Pod::Spec.new do |s|
  s.name             = 'Rudder-Firebase'
  s.version          = package['version']
  s.summary          = 'Privacy and Security focused Segment-alternative. Firebase Native SDK integration support.'

  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC
  s.homepage         = 'https://github.com/rudderlabs/rudder-integration-firebase-ios'
  s.license          = { :type => "Apache", :file => "LICENSE.md" }
  s.author           = { 'RudderStack' => 'arnab@rudderlabs.com' }
  s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-firebase-ios.git' , :tag => "v#{s.version}" }
  
  s.requires_arc = true
  s.source_files = 'Rudder-Firebase/Classes/**/*'
  s.static_framework = true
  s.ios.deployment_target = deployment_target
  
  if defined?($FirebaseSDKVersion)
    firebase_sdk_version = $FirebaseSDKVersion
    if (firebase_sdk_version.to_f < 9.0)
      firebase_analytics = 'Firebase/Analytics'
      deployment_target = '9.0'
    elsif (firebase_sdk_version.to_f >= 9.0) && (firebase_sdk_version.to_f < 10.0)
      deployment_target = '10.0'
    end
    Pod::UI.puts "#{s.name}: Using user specified Firebase SDK version '#{firebase_sdk_version}'"
  else
    Pod::UI.puts "#{s.name}: Using default Firebase SDK version '#{firebase_sdk_version}'"
  end
  
  if defined?($RudderSDKVersion)
    Pod::UI.puts "#{s.name}: Using user specified Rudder SDK version '#{$RudderSDKVersion}'"
    rudder_sdk_version = $RudderSDKVersion
  else
    Pod::UI.puts "#{s.name}: Using default Rudder SDK version '#{rudder_sdk_version}'"
  end
  
  s.dependency 'Rudder', rudder_sdk_version
  s.dependency firebase_analytics, firebase_sdk_version
end
