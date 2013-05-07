# Sliced Bananas

An extensible tagged literal system for JSON

This project is inspired by [EDN](https://github.com/edn-format/edn), which provides much richer data structures than JSON.
However if you're stuck with JSON for performance or interoperability, make the best of your bad cerealization by adding sliced bananas.

## Install

If you're OG, just grab `sliced_bananas.min.js` and throw it on your page.

If you're using ClojureScript, add

```clojure
[com.keminglabs/sliced-bananas "0.1.0-SNAPSHOT"]
```

to your `project.clj` dependencies and then

```clojure
(:require [com.keminglabs.SlicedBananas :as sb])
```

in your namespace form.
Note that this is a plain JavaScript library, so if you want to pass options make sure you first coerce them to a JavaScript object:
```clojure
(sb/deserialize my-js-obj
                (clj->js {"tag_table" {"inst" (fn [d] ...)}}))
```


## Usage

This library is two pure functions, `serialize` and `deserialize`, which move values between the rich semantics of your application and the impoverished semantics of JSON.
To serialize a non-JSONable value (i.e., anything beyond a string, number, true/false/null, or array or string-key'd map thereof) you provide a *tag* and a JSONable representation of the value.
To deserialize, you provide a function that takes the JSONable representation and returns the richer type.

Consider the classic problem of serializing dates.
Sliced Bananas comes with a built-in reader for the "inst" tag with the [rfc-3339](http://www.ietf.org/rfc/rfc3339.txt) string representations of dates:

```javascript
SlicedBananas.deserialize({"#inst": "2013-04-05T00:00:00.000Z"})
  .getFullYear() //=> 2013
```

Note that the argument to deserialize is a data structure, not a string; use `JSON.parse` to convert your JSON string into data and then `SlicedBananas.deserialize` to lift that data into your application domain.

Tagged literals can occur at any (potentially nested) position in JSON data:

```javascript
SlicedBananas.deserialize([0, 1, {"#inst": "2013-04-05T00:00:00.000Z"}])
  .pop().getFullYear() //=> 2013
```

Additional tags are specified as a map of tags to reader functions:

```javascript
opts = {tag_table: {inst: function(x){return new Date(Date.parse(x)).getFullYear();}}}
SlicedBananas.deserialize([0, 1, {"#inst": "2013-04-05T00:00:00.000Z"}], opts)
  //=> [0, 1, 2013]
```

and tags can be nested within each other:

```javaScript
var Order = function Order() {}

var opts = {
  tag_table: {
    order: function(x) {
      var o = new Order();
      o.id = x.id;
      o.placed_on = x.placed_on;
      return o;}}};

var d = {"#order": {"id": 123, "placed_on": {"#inst": "2013-04-05T00:00:00.000Z"}}};
var res = SlicedBananas.deserialize(d, opts);
res.constructor == Order //=> true
res.placed_on.getFullYear() == 2013 //=> true
```

By default, an error is thrown when an unknown tag is encountered, but that behavior can be changed by providing a default reader function:

```javascript
SlicedBananas.deserialize({"#trouble": true})
  //=> Raises an error!
SlicedBananas.deserialize({"#trouble": true},
                          {default_reader: function(x){return 42;}})
  //=> 42
```

To convert your application values into JSONable values, you can use the `serialize` function.
By default, only the `inst` tag is implemented:

```javascript
SlicedBananas.serialize({"aDate": new Date()})
  //=> {aDate: {#inst: "2013-04-16T20:32:20.807Z"}}
```

but as with the `deserialize` function you can pass a second argument options map.
The interesting key in this options map is `constructor_table`, which should map to an instance of [goog.structs.Map](http://docs.closure-library.googlecode.com/git/class_goog_structs_Map.html) with function constructor keys and serialization function values.
A serialization function should take your higher level type and return an array of the form `[string_tag, JSONable_value]`.
Your serialization functions will also be passed the options map given to `SlicedBananas.serialize` as the second argument; you can use this to recursively serialize composite types.

Using `goog.structs.Map` is going to be painful for anyone not using the Google Closure Library, so if you have suggestions for a nicer way to implement an open polymorphic dispatch system for serialization, please let me know.

For more usage examples, [see the tests](https://github.com/lynaghk/sliced-bananas/blob/master/spec/coffeescripts/sliced_bananas_spec.coffee).

## Serverside implementation

Since everything is just JSON, it's fairly easy to teach your server to slice some bananas.
Here's an example of serializing JodaTime dates with the [Cheshire](https://github.com/dakrone/cheshire) JSON library in Clojure:

```clojure
(ns ptron.server.util
  (:require [cheshire
             [core :as json]
             [generate :refer [add-encoder encode-map]]]
            [clj-time
             [core :refer [now]]
             [format :refer [formatters unparse]]]))

(add-encoder org.joda.time.DateTime
             (fn [x jg]
               (encode-map {"#inst" (unparse (formatters :date-time)
                                             x)}
                           jg)))

(json/encode (now))
    ;;=> "{\"#inst\":\"2013-05-07T04:32:49.376Z\"}"
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

Specs are written in CoffeeScript under `spec/coffeescripts`.

Start the test server with

    bundle exec rake jasmine
    
and then open up `localhost:8888` in your browser to run specs.
If you are editing specs, make sure to run

    bundle exec guard
    
so that the specs will automatically compile from CoffeeScript to JavaScript. 
