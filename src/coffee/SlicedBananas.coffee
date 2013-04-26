goog.provide "com.keminglabs.SlicedBananas"
goog.require "goog.structs.Map"
goog.require "goog.object"

# Lil' print function that's helpful to have during development; it'll be removed by Closure compiler if it's not used in anything exported.
p = (x) ->
  console.log x
  x

get_tag = (literal_prefix, x) ->
  if (x instanceof Object)
    ks = Object.keys(x)
    if ks.length == 1 and ks[0][0] == literal_prefix
      #return the tag
      Object.keys(x)[0].substring 1


LiteralPrefix = "#"

DefaultReader = (tag, x) ->
  throw new Error "Tag '#{tag}' not recognized"

TagTable =
  "inst": (x) -> new Date(Date.parse x)

ConstructorTable = new goog.structs.Map(
  Date, (d) -> ["inst", d.toISOString()]
)

sb = null #need CoffeeScript to define the var up here rather than within goog.scope.
goog.scope ->
  sb = com.keminglabs.SlicedBananas

  sb.deserialize = (x, opts) ->
    opts or= {}

    tag = get_tag (opts["literal_prefix"] or LiteralPrefix), x
    if tag
      tag_reader = (opts["tag_table"] or TagTable)[tag]
      val = x[Object.keys(x)[0]]
      if tag_reader
        tag_reader val
      else
        (opts["default_reader"] or DefaultReader) tag, val
    else if goog.isArray(x)
      x.map (v) -> sb.deserialize v, opts
    else if goog.isObject(x)
      goog.object.map x, (v, k) -> sb.deserialize v, opts
    else
      x
    
  sb.serialize = (x, opts) ->
    opts or= {}

    klass = if x? then x["constructor"] else null
    serializer = (opts["constructor_table"] or ConstructorTable)?.get(klass)
    if serializer
      [tag, val] = serializer(x)
      res = {}
      res[(opts["literal_prefix"] or LiteralPrefix) + tag] = val
      res
    else if goog.isArray(x)
      x.map (v) -> sb.serialize v, opts
    else if goog.isObject(x)
      goog.object.map x, (v, k) -> sb.serialize v, opts
    else
      x
  

  # The function provided to goog.scope shouldn't return anything, but CoffeeScript will always return the last expression of a fn.
  # This return statement will be matched by a regex in the Rakefile and eliminated before it's passed to the Closure compiler.
  return "eliminate-this-line"