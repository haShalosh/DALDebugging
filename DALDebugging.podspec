Pod::Spec.new do |s|
  s.name         = "DALDebugging"
  s.version      = "0.0.1"
  s.summary      = "Utilities I've created to help me with debugging on iOS."
  s.description  = <<-DESC
                   Debugging Utilities
                   
                   A few features:
                   * A list of private Apple methods I've found useful.
                   * Finding the property name(s) of a view (or subclass like a button or a label).
                   * A re-implementation of Apple's NSObject debugging methods so they can be used on NSProxy, iOS pre-7.x and Mac (-[NSObject _ivarDescription], -[NSObject _methodDescription] and -[NSObject _shortMethodDescription])
                   * Describe a bitmask (NSUInteger).
                   DESC
  s.homepage     = "https://github.com/haShalosh/DALDebugging"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Daniel Leber" => "haShalosh@gmail.com" }
  s.source       = { :git => "https://github.com/haShalosh/DALDebugging.git", :tag => '0.0.1' }
  s.source_files  = "DALDebugging/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true
end