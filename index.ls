require! <[ uuid highland ]>

module.exports = construct = (options={}) ->

  { object-mode } = options

  # This is the output stream
  s-out = highland!

  total-planned  = 0
  total-finished = 0
  input-done     = false

  # This is called by the user when they won't be planning any more tests.
  done = ->
    # If we're done with all the tests, end the output stream now.
    if total-planned is total-finished
      s-out.write highland.nil # end output

    # Otherwise just remember that it's safe to quit once all the planned tests
    # are complete.  (It's the test result callbacks' responsibility to quit
    # once all the tests are complete.)
    else input-done := true

  # This is called by the user when they want to plan a test.  It returns a
  # function they can call to run that test immediately.
  plan = (string-or-func, test-func) ->

    # Handle that funky first argument
    var expected
    if typeof string-or-func is \string
      expected := string-or-func
    else
      test-func := string-or-func

    # Check sanity
    if typeof test-func isnt \function
      throw Error "Test function wasn't a function"
    if typeof expected isnt \string
      throw Error "Test expectation-description wasn't a string"

    ++total-planned

    id = uuid!

    write-data = (obj) ->
      s-out.write do
        if object-mode then obj
        else (JSON.stringify obj) + "\n"

    # Write the test plan
    write-data { id, expected }

    # Give the user back a function that they can call to run the test
    # immediately.  It optionally takes a callback function, in case they want
    # to do some custom test sequencing.
    return (...other-args, maybe-callback) !->

      test-func-callback = (err, result, additional-data) ->
        ++total-finished
        if err
        then write-data { id, ok : no  actual : (err.message || err) }
        else write-data { id, ok : yes actual : result }
        if input-done and (total-planned == total-finished)
          s-out.write highland.nil

        if maybe-callback
          maybe-callback.apply do
            null
            [ err ] ++ Array::slice.call arguments, 2

      # Asynchronously call the test function and write its result
      test-func-args = other-args
        ..push test-func-callback
      test-func.apply null test-func-args

  out  : s-out
  plan : plan
  done : done
