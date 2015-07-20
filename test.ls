taps = require \./index.ls
test = require \tape
require! \highland
require! \async
require! \concat-stream

# Decided to use tape for the tests because testing a
# test framework with itself would be madness! :)

test "plan 2, run sequentially" (t) ->

  tests = taps { +object-mode }

  test1 = tests.plan "runs first" (cb) ->
    set-timeout do
      -> cb null "first here"
      200
  test2 = tests.plan "runs second" (cb) ->
    set-timeout do
      -> cb null "second here"
      100
  tests.done!

  # The first test should finish before the second one despite the timeouts
  # being set with the first actually slower.  This is just to prove that users
  # can themselves decide how tests should synchronise with other tests.
  <- async.series [ test1, test2 ]

  highland tests.out .to-array ->
    it
      ..length `t.equals` 4
      ..for-each (d, i) -> t.ok d.id, "output object #i has id"
      ..0
        ..ok `t.is` undefined
        ..expected `t.is` "runs first"
      ..1
        ..ok `t.is` undefined
        ..expected `t.is` "runs second"
      ..2
        ..ok `t.is` true
        ..actual `t.is` "first here"
      ..3
        ..ok `t.is` true
        ..actual `t.is` "second here"

  t.end!

test "plan 2, pass data" (t) ->

  tests = taps { +object-mode }

  test1 = tests.plan "runs first" (cb) ->
    set-timeout do
      -> cb null "first here" "ADDITIONAL DATA!"
      200
  test2 = tests.plan "runs second" (data, cb) ->
    set-timeout do
      -> cb null "second here with #data"
      100
  tests.done!

  <- async.waterfall [
    * (cb) -> test1 cb
    * (res, cb) -> test2 res, cb
  ]

  highland tests.out .to-array ->
    it
      ..length `t.equals` 4
      ..for-each (d, i) -> t.ok d.id, "output object #i has id"
      ..0
        ..ok `t.is` undefined
        ..expected `t.is` "runs first"
      ..1
        ..ok `t.is` undefined
        ..expected `t.is` "runs second"
      ..2
        ..ok `t.is` true
        ..actual `t.is` "first here"
      ..3
        ..ok `t.is` true
        ..actual `t.is` "second here with ADDITIONAL DATA!"

  t.end!

test "plan 1, fail 1" (t) ->
  tests = taps { +object-mode }

  t1 = tests.plan "succeeds" (cb) ->
    set-timeout do
      -> cb null "ok"
      200
  t2 = tests.plan "fails" (cb) ->
    set-timeout do
      -> cb (new Error "fail")
      100
  tests.done!

  async.series [ t1, t2 ]

  highland tests.out .to-array ->
    it
      ..length `t.equals` 4
      ..for-each (d, i) -> t.ok d.id, "output object #i has id"
      ..0
        ..ok `t.is` undefined
        ..expected `t.is` "succeeds"
      ..1
        ..ok `t.is` undefined
        ..expected `t.is` "fails"
      ..2
        ..ok `t.is` true
        ..actual `t.is` "ok"
      ..3
        ..ok `t.is` false
        ..actual `t.is` "fail"

  t.end!

test "plan 1, fail 1, with stream in buffer mode" (t) ->
  tests = taps!

  t1 = tests.plan "succeeds" (cb) ->
    set-timeout do
      -> cb null "ok"
      200
  t2 = tests.plan "fails" (cb) ->
    set-timeout do
      -> cb (new Error "fail")
      100
  tests.done!

  async.series [ t1, t2 ]

  tests.out .pipe concat-stream ->
    # Made id properties empty; we know they're there
    it .= replace /"id":"[^"]*"/g, '"id":""'
    t.equals it, '''
    {"id":"","expected":"succeeds"}
    {"id":"","expected":"fails"}
    {"id":"","ok":true,"actual":"ok"}
    {"id":"","ok":false,"actual":"fail"}\n'''

    t.end!
