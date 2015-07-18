uuid    = require \uuid .v4
through = require \through
duplexer = require \duplexer2
es  = require \event-stream
{ values, all, id } = require \prelude-ls
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

  input : s-in
  output : s-out
