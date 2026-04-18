Pod::Spec.new do |s|
  s.name         = 'MetaWearCpp'
  s.version      = '0.30.0'
  s.summary      = 'MetaWear C++ SDK wrapped for Swift/Obj-C consumption'
  s.homepage     = 'https://github.com/mbientlab/MetaWear-SDK-Cpp'
  s.license      = { :type => 'MIT' }
  s.author       = 'MbientLab'
  s.source       = { :path => '.' }

  s.ios.deployment_target    = '14.0'
  s.osx.deployment_target    = '11.0'
  s.tvos.deployment_target   = '14.0'
  s.watchos.deployment_target = '7.0'

  s.static_framework = true

  s.vendored_libraries   = 'build-cmake/dist/x64/Release/libmetawear.a'
  s.source_files         = 'src/metawear/{core,peripheral,platform,processor,sensor}/*.h'
  s.header_mappings_dir  = 'src'
  s.preserve_paths       = 'src/metawear/**'
  s.module_map           = 'src/module.modulemap'

  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/src"',
    'SWIFT_INCLUDE_PATHS' => '"${PODS_TARGET_SRCROOT}/src"',
  }

  s.user_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '"${PODS_ROOT}/../../../MetaWear-SDK-Cpp/src"',
  }

  s.library = 'c++'
  s.module_name = 'MetaWearCpp'
end
