# tapson

A simple Node.js/io.js interface to the tapson test protocol.

Tests are planned, then run asynchronously with whatever dependencies you like.

Exports a readable stream that outputs objects corresponding to the appropriate
tapson protocol stream.

## Tutorial

```js
// Instantiate
var taps = require("tapson")();

// Create 2 tests that finish in 0 - 1 seconds
var test1 = taps.plan("this runs first", function(cb) {
    setTimeout(function() { cb(null, "first ok") }, Math.random() * 1000);
});
var test2 = taps.plan("this runs second", function(cb) {
    setTimeout(function() { cb(null, "second ok") }, Math.random() * 1000);
});
// Tell tapson we're done with planning tests
taps.done();

// Run the tests in parallel
test1();
test2();

// Read the output data stream
taps.out.on("data", function(d) { console.log(d); });
```

With the above, tapson runs both tests in parallel.  You can expect output that
looks like—

```json
{"id":"5a10fa17-1783-4b72-afa5-5cab41209dae","expected":"this runs first"}
{"id":"68cb2ae4-f769-4f86-82d9-a15fdab4180a","expected":"this runs second"}
{"id":"4f4ac792-f37f-4dc3-a97d-5004e05ca669","ok":true,"actual":"second ok"}
{"id":"4b157358-603f-49c3-aec5-a0498ff89447","ok":true,"actual":"first ok"}
```

## Exported things

### `var tests = tapson()`

Creates a new tapson test set, ready and waiting for tests.

### `var test = tests.plan([description], testFunction)`

Plans a new test with an optional description and a function that runs it.
Returns a function that you can call to immediately run the test.

The `test` will be passed a callback function as its only argument, which it
should call once it is finished.  As is the usual Node.js practice, if there's
a failure, pass an `Error` object or `String` error message as the first
parameter.  If it succeeded, pass `null` as the first parameter and an optional
String describing the success as the second.

If you want to run the test immediately after you plan it, it's totally OK to
just immediately call the return value:

```js
tests.plan("this works", function(cb) { cb() })();
```

### `tests.out`

This is a Node tapson stream.  Each test plan and test result is logged.
Finishes when all the tests finish.
