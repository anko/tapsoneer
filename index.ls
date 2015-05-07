uuid    = require \uuid .v4
through = require \through
duplexer = require \duplexer2
es  = require \event-stream
{ values, all, id } = require \prelude-ls

module.exports = construct = (opts) ->

  got-result-for = {}
  have-all-results = -> got-result-for |> values |> all id
  input-is-over  = false

  in-stream  = through!
  out-stream = through!

  output-plan = (expected) ->
    # returns id
    id = uuid!
    got-result-for[id] := false
    out-stream.push { id, expected }
    return id

  output-result = (id, ok, actual) ->
    got-result-for[id] := true
    out-stream.push { id, ok, actual }


  in-stream
    .on \data (obj) ->
      console.log "plan" obj
      id = output-plan obj.expected
      console.log "calling" obj
      obj.test (failure-message, success-message) ->
        console.log("Got" id);
        got-result-for[id] := true
        if failure-message
        then output-result id, false, failure-message
        else output-result id, true,  success-message

        if input-is-over and have-all-results!
          console.log "have all"
          out-stream.push null

    .on \end ->

      if have-all-results!
        console.log "end so bye"
        out-stream.push null
      else # let a test callback handle it
        input-is-over := true

  duplexer in-stream, out-stream
