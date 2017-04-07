platform :ios, '10.0'

target 'McAdViewControllerExample' do
  use_frameworks!

  # Pods for McAdViewControllerExample
  pod 'Google-Mobile-Ads-SDK'

  puts "Downloading McAdViewController..."
  require 'open-uri'
  open('./McAdViewController.swift', 'wb') do |file|
    file << open('http://localhost/McAdViewController.swift').read
  end
  puts "Successfully downloaded McAdViewController! :)"

end
