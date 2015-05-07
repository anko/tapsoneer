uuid    = require \uuid .v4
through = require \through2
duplex  = require \duplex
{ values, every, id } = require \prelude-ls

module.exports = construct = (opts) ->

  got-result-for = {}
  have-all-results = -> got-result-for |> values |> every id
  input-is-over  = false

  d = duplex!

  output-plan = (expected) ->
    # returns id
    id = uuid!
    got-result-for[id] := false
    d.send-data JSON.stringify { id, expected }
    return id

  output-result = (id, ok, actual) ->
    got-result-for[id] := true
    d.send-data JSON.stringify { id, ok, actual }

  d
    .on \_data (obj) ->
      id = output-plan obj.expected
      obj.test (failure-message, success-message) ->
        got-result-for[id] := true
        if failure-message
        then output-result id, false, failure-message
        else output-result id, true,  success-message

        if input-is-over and have-all-results! then d.send-end!

    .on \_end ->

      if have-all-results! then d.send-end!
      else # let a test callback handle it
        input-is-over := true

  return d
