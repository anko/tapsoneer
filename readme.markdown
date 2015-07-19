# tapson

A simple Node.js/io.js interface to the tapson test protocol.

Tests are planned, then run asynchronously with whatever dependencies you like.

Exports a readable tapson protocol stream.

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

### `var tests = tapson([options])`

Creates a new tapson test set, ready and waiting for tests.

By default, the emitted stream outputs Node Buffers.  If you want a stream of
objects instead, pass an options object with `{ objectMode : true }`.

### `var test = tests.plan([description], testFunction)`

Plans a new test with an optional description and a function that runs it.
Returns a function that you can call to immediately run the test.

The `test` will be passed a callback function as its only argument, which it
should call once it is finished.  As is the usual Node.js practice, if there's
a failure, pass an `Error` object or `String` error message as the first
parameter.  If it succeeded, pass `null` as the first parameter and an optional
String describing the success as the second.

### `test([callback])`

Runs the given test immediately.  Its results will be on the output stream as
soon as the test completes.

You can optionally pass it a `callback` argument, to be notified when the test
finishes.  This is handy if some of your tests depend on other tests, and means
you can use [async.js][1] to do stuff like—

```js

var databaseConnection = null;

var testSetupDatabase = tests.plan("database sets up", function(cb) {
    // Do whatever you need to set up the database, and call `cb`.
});
var testQuery = tests.plan("query some values", function(cb) {
    // Use the `databaseConnection` to do stuff and call `cb`.
});

tests.done();

async.series([ testSetupDatabase, testQuery ]);
```

—to ensure they run sequentially.  If you have a tangly mess of dependencies,
[`async.auto`][2] is your friend.

If you want to run a test immediately after you plan it because it has no
dependencies on anything, that's fine too.  It'll run in parallel with other
tests:

```js
tests.plan("this runs right away", function(cb) { cb(null, "no problemo") })();
```

### `tests.out`

This is a [stream][3] containing tapson.  All test plans and test results are
emitted from it as they happen.  The stream finishes when all the tests finish.

If you want it on `stdout`, just do `tests.out.pipe(process.stdout)`.

[1]: https://github.com/caolan/async
[2]: https://github.com/caolan/async#auto
[3]: http://nodejs.org/api/stream.html
