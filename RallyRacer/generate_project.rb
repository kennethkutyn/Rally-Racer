#!/usr/bin/env ruby
# Generates an Xcode project for RallyRacer with SPM dependencies
# Usage: ruby generate_project.rb

require 'xcodeproj'

project_path = 'RallyRacer.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Create groups matching directory structure
main_group = project.main_group
target_name = 'RallyRacer'

# Source group
src = main_group.new_group('RallyRacer', 'RallyRacer')
models = src.new_group('Models', 'Models')
game = src.new_group('Game', 'Game')
views = src.new_group('Views', 'Views')
services = src.new_group('Services', 'Services')
utilities = src.new_group('Utilities', 'Utilities')
resources = src.new_group('Resources', 'Resources')

# Create target
target = project.new_target(:application, target_name, :ios, '17.0')
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.kenkutyn.RallyRacer'
  config.build_settings['INFOPLIST_FILE'] = 'RallyRacer/Info.plist'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['INFOPLIST_KEY_UISupportedInterfaceOrientations'] = 'UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
end

# Add source files
swift_files = {
  src => ['RallyRacerApp.swift', 'AppState.swift'],
  models => ['CarConfig.swift', 'GameConstants.swift', 'ColorPalette.swift'],
  game => ['GameScene.swift', 'BackgroundNode.swift', 'RoadNode.swift', 'PlayerNode.swift',
           'ObstacleNode.swift', 'SceneryNode.swift', 'HUDNode.swift', 'TouchControlNode.swift'],
  views => ['ContentView.swift', 'MainMenuView.swift', 'DeathScreenView.swift',
           'GarageView.swift', 'GaragePreviewScene.swift', 'LeaderboardView.swift', 'ColorSwatchGrid.swift'],
  services => ['FirebaseService.swift', 'AnalyticsService.swift', 'GarageStorage.swift'],
  utilities => ['ColorExtensions.swift', 'GradientTexture.swift'],
}

swift_files.each do |group, files|
  files.each do |file|
    ref = group.new_file(file)
    target.source_build_phase.add_file_reference(ref)
  end
end

# Add resources
assets_ref = resources.new_file('Assets.xcassets')
target.resources_build_phase.add_file_reference(assets_ref)

# Add Info.plist reference (not added to build phase)
src.new_file('Info.plist')

# Add font resources
fonts_group = resources.new_group('Fonts', 'Fonts')
['BungeeShade-Regular.ttf', 'RussoOne-Regular.ttf'].each do |font|
  ref = fonts_group.new_file(font)
  target.resources_build_phase.add_file_reference(ref)
end

# ============================================================
# Swift Package Manager Dependencies
# ============================================================

# --- Amplitude-Swift ---
amplitude_pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
amplitude_pkg.repositoryURL = 'https://github.com/amplitude/Amplitude-Swift.git'
amplitude_pkg.requirement = { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '1.0.0' }
project.root_object.package_references << amplitude_pkg

amplitude_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
amplitude_dep.product_name = 'AmplitudeSwift'
amplitude_dep.package = amplitude_pkg
target.package_product_dependencies << amplitude_dep

project.save

puts "Project generated at #{project_path} with SPM: Amplitude-Swift"
puts "Firebase uses live REST API (same as web version, no SDK needed)"
