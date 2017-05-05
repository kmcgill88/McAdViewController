platform :ios, '10.0'

target 'McAdViewControllerExample' do
  use_frameworks!

  pod 'Google-Mobile-Ads-SDK', '~> 7.20'

  puts "Downloading McAdViewController..."
  require 'open-uri'
  open('./McAdViewControllerExample/McAdViewController.swift', 'wb') do |file|
    file << open('https://raw.githubusercontent.com/kmcgill88/McAdViewController/master/McAdViewControllerExample/McAdViewController.swift').read
  end
  puts "Successfully downloaded McAdViewController! :)"

end
