#Tests for the Public API only


beforeEach ->
  @addMatchers
    #Dates have by-reference semantics. Ugh, JavaScript!
    toEqualDate: (d) -> @actual.valueOf() == d.valueOf()

describe "deserialization", ->
  it "works at the toplevel", ->
    res = JTL.deserialize {"#inst": "2013-04-05T00:00:00.000Z"}
    expect(res).toEqualDate new Date(Date.UTC(2013, 3, 5))

  it "works on arrays", ->
    res = JTL.deserialize [{"#inst": "2013-04-05T00:00:00.000Z"}, {"#inst": "2013-04-05T00:00:00.000Z"}]
    expect(res[0]).toEqualDate new Date(Date.UTC(2013, 3, 5))
    expect(res[1]).toEqualDate new Date(Date.UTC(2013, 3, 5))

  it "works with non-default prefixes and tags", ->
    res = JTL.deserialize {"!datestring": "2013-04-05T00:00:00.000Z"},
      literal_prefix: "!"
      tag_table:
        datestring: (s) -> Date.parse s
    expect(res).toEqualDate new Date(Date.UTC(2013, 3, 5))

  it "throws an exception for an unknown tag", ->
    expect(-> JTL.deserialize({"#huh?": 11}))
    .toThrow(new Error "Tag 'huh?' not recognized")

  it "accepts a default reader", ->
    res = JTL.deserialize {"#huh?": 11},
      default_reader: (x) -> 42
    expect(res).toEqual 42

  it "can handle nested tags", ->
    class Order
    res = JTL.deserialize {"#order": {"id": 123, "placed_on": {"#inst": "2013-04-05T00:00:00.000Z"}}},
      tag_table:
        order: (x) ->
          o = new Order()
          o.id = x.id
          o.placed_on = x.placed_on
          o

    expect(res.constructor).toEqual Order
    expect(res.placed_on).toEqualDate new Date(Date.UTC(2013, 3, 5))

describe "serialization", ->
  it "works at the toplevel", ->
    res = JTL.serialize new Date(Date.UTC(2013, 3, 5))
    expect(res).toEqual {"#inst": "2013-04-05T00:00:00.000Z"}

  it "works on arrays", ->
    res = JTL.serialize [new Date(Date.UTC(2013, 3, 5))]
    expect(res).toEqual [{"#inst": "2013-04-05T00:00:00.000Z"}]

  it "works on objects", ->
    x =
      thing: "A"
      someDates: [new Date(Date.UTC(2013, 3, 5)), new Date(Date.UTC(2013, 3, 5))]
    res = JTL.serialize x
    expect(res).toEqual
      thing: "A"
      someDates: [{"#inst": "2013-04-05T00:00:00.000Z"}, {"#inst": "2013-04-05T00:00:00.000Z"}]
        

