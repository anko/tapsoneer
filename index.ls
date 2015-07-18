uuid = require \uuid .v4
_ = require \highland

module.exports = construct = (opts) ->

  s-out = _!

  s-in = _!tap ->
    id = uuid!
    { expected, test } = it

    s-out.write { id, expected }

    test.call null (err, result) ->
      if err
        s-out.write { id, -ok, actual : (err.message || err) }
      else
        s-out.write { id, +ok, actual : result }

  s-in.resume!

  proc-func = (err, x, push, next) !->
    if err then s-in.write err
    else s-in.write x
    next!

  stream = _.pipeline do
    (in-stream) ->
      in-stream.consume proc-func .resume!

      s-out
