source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def testing_pods
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.0'
  end

target 'ReactiveLists' do
    project 'ReactiveLists.xcodeproj'
    pod 'ReactiveSwift', '~> 3.0'
    pod 'Dwifft', '0.7.0'

    target 'ReactiveListsExample' do
      project 'ReactiveLists.xcodeproj'
    end
  end

  target 'ReactiveListsTests' do
    project 'ReactiveLists.xcodeproj'
    testing_pods
  end

