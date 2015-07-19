taps = require \./index.ls
test = require \tape
require! \highland
require! \async

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
