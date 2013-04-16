# Sliced Bananas

An extensible tagged literal system for JSON

This project is inspired by [EDN](https://github.com/edn-format/edn), which provides much richer data structures than JSON.
However if you're stuck with JSON for performance or interoperability, make the best of your bad cerealization by adding sliced bananas.


## Usage

```javascript
var x = [1, 2, {"#inst": "2013-04-05T00:00:00.000Z"}];
var res = SlicedBananas.deserialize(SlicedBananas.DefaultTagTable, x);
res[2].constructor === Date //=> true

SlicedBananas.serialize(SlicedBananas.DefaultConstructorTable, {"aDate": new Date()})
  //=> {aDate: {#inst: "2013-04-16T20:32:20.807Z"}}

```

## Development

You'll need Ruby and bundler to build the project.
Use [RVM](https://rvm.io/) to grab Ruby 1.9.3, install the bundler rubygem, then

    bundle install
    git submodule update --init

to get all of the dependencies.
Then run

    bundle exec rake minify 

to run CoffeeScript and minify its output with the Google Closure compiler.


## Testing

Tests are written in CoffeeScript under `spec/coffeescripts`.

Start the test server with

    bundle exec rake jasmine
    
and then open up `localhost:8888` in your browser to run tests.
If you are editing tests, make sure to run

    bundle exec guard
    
so that the specs will automatically compile from CoffeeScript to JavaScript. 
