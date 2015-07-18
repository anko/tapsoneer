uuid = require \uuid .v4
_ = require \highland

module.exports = construct = (opts) ->

  s-out = _!

  s-in = _!map ->
    id : uuid!
    data : it

  result-stream = s-in
    .fork!
    .tap ({ id, data : expected : expected }) ->
      s-out.write { id, expected }
    .map ({ id, data : test : test }) ->
      return (cb) ->
        test.call null, (err, value) ->
          if err
            return cb null , { id, -ok, actual : (err.message || err) }
          else
            return cb null, { id, +ok, actual : value }
    .nfcall []
    .parallel ( opts?parallelism || 10 )
    .tap -> s-out.write it

  result-stream.resume!

  proc-func = (err, x, push, next) !->
    if err
      s-in.write err
    else
      s-in.write x
    next!

  stream = _.pipeline do
    (in-stream) ->
      in-stream.consume proc-func .resume!

      s-out
