platform :ios, '10.0'

target 'McAdViewControllerExample' do
  use_frameworks!

  pod 'Google-Mobile-Ads-SDK', '~> 7.19'

  puts "Downloading McAdViewController..."
  require 'open-uri'
  open('./McAdViewControllerExample/McAdViewController.swift', 'wb') do |file|
    file << open('http://localhost/McAdViewController.swift').read
  end
  puts "Successfully downloaded McAdViewController! :)"

end
