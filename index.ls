uuid    = require \uuid .v4
through = require \through2
duplex  = require \duplexer2
{ values, every, id } = require \prelude-ls

module.exports = construct = (opts) ->

  in-stream   = through!
  out-stream  = through!

  got-result-for = {}
  have-all-results = -> got-result-for |> values |> every id
  input-is-over  = false

  output-plan = (expected) ->
    # returns id
    id = uuid!
    got-result-for[id] := false
    out-stream.push JSON.stringify { id, expected }
    return id

  output-result = (id, ok, actual) ->
    got-result-for[id] := true
    out-stream.push JSON.stringify { id, ok, actual }

  in-stream.on \data (obj) ->
    id = output-plan obj.expected
    obj.test (failure-message, success-message) ->
      got-result-for[id] := true
      if failure-message
      then output-result id, false, failure-message
      else output-result id, true,  success-message
      if input-is-over and have-all-results!
        out-stream.push null # end output
  in-stream.on \end ->
    if have-all-results!
      out-stream.push null # end output

    else # let a test callback handle it
      input-is-over := true

  duplex in-stream, out-stream
