require 'closure-compiler'
require 'guard'

#Setup Guard Singleton
Guard.setup
Guard::Dsl.evaluate_guardfile(:guardfile => 'Guardfile')

CoffeeScriptOutput = Guard.guards('coffeescript').options[:output]
OutputRoot = "output"


# Eliminate any specially marked returns in the CoffeeScript generated JavaScript.
def remove_goog_scope_returns!(js_file_path)
  js = File.read js_file_path
  open(js_file_path, "w") do |f|
    f.write js.gsub 'return "eliminate-this-line"', ''
  end
end


task :compile_coffeescript do
  Guard.guards('coffeescript').run_all
  CoffeeScriptOutput
  FileList.new("#{CoffeeScriptOutput}/**/*.js")
    .each{|path| remove_goog_scope_returns!(path)}
end

task :minify => [:compile_coffeescript] do
  Closure::Compiler
    .new(compilation_level: 'ADVANCED_OPTIMIZATIONS',
         manage_closure_dependencies: true,
         js_output_file: "#{OutputRoot}/sliced_bananas.min.js")
    .compile_files(FileList.new("vendor/closure-library/closure/goog/base.js",
                                "vendor/closure-library/closure/goog/object/*.js",
                                "#{CoffeeScriptOutput}/**/*.js"))
end