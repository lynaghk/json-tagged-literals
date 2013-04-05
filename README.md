# Sliced Bananas

An extensible tagged literal system for JSON


This project is inspired by [EDN](https://github.com/edn-format/edn), which provides much richer data structures than JSON.
However if you're stuck with JSON for performance or interoperability, make the best of your bad cerealization by adding sliced bananas.

## Development

You'll need Ruby and bundler to build the project.
Use [RVM](https://rvm.io/) to grab Ruby 1.9.3, install the bundler rubygem, then

    bundle install
    git submodule update --init

to get all of the dependencies.
Then run

    bundle exec rake minify 

to run CoffeeScript and minify its output with the Google Closure compiler.
