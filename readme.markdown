# tapson

A simple Node.js/io.js interface to the tapson test protocol.

Tests are run immediately as they're received and their outputs emitted
immediately as they finish.

Exports a duplex stream, which takes test specifications as objects with
`expected`-text and an async `test` function, and outputs objects exactly
corresponding to the appropriate tapson protocol stream.

## Tutorial

```js
// Instantiate.
var taps = require("tapson")();

// Push test objects.
[ 0, 1, 2, 3, 4 ].forEach(function(n) {
    taps.write({
        expected : "Test number " + n, // A description of the test
        test : function(callback) {

            // Test logic goes here.

            // For illustration, just succeed 0 - 1 seconds later.
            setTimeout(function() {
                callback(null, "Success " + n);
            }, Math.random() * 1000);
        }
    });
});

// End input stream.
taps.end();

// Tests are run immediately as you write them to the stream.
// A tapson test plan object is emitted for each.
// Once the result comes back, that's emitted also.

// At this point you can just pipe the output data wherever you want it.

// The output data stream ends when all tests have finished.

taps.on("data", function(d) { console.log(d); });
```

With the above, you can expect output like—

```json
{"id":"5a10fa17-1783-4b72-afa5-5cab41209dae","expected":"Test number 0"}
{"id":"68cb2ae4-f769-4f86-82d9-a15fdab4180a","expected":"Test number 1"}
{"id":"4b157358-603f-49c3-aec5-a0498ff89447","expected":"Test number 2"}
{"id":"65d345fd-1295-4aad-be70-1ac4333d7f43","expected":"Test number 3"}
{"id":"4f4ac792-f37f-4dc3-a97d-5004e05ca669","expected":"Test number 4"}
{"id":"4b157358-603f-49c3-aec5-a0498ff89447","ok":true,"actual":"Success 2"}
{"id":"4f4ac792-f37f-4dc3-a97d-5004e05ca669","ok":true,"actual":"Success 4"}
{"id":"68cb2ae4-f769-4f86-82d9-a15fdab4180a","ok":true,"actual":"Success 1"}
{"id":"5a10fa17-1783-4b72-afa5-5cab41209dae","ok":true,"actual":"Success 0"}
{"id":"65d345fd-1295-4aad-be70-1ac4333d7f43","ok":true,"actual":"Success 3"}
```

## methods

### `tapson()`

Creates a new duplex tapson stream.

### `tapson-stream.write(obj)`

Expects `obj` to have an `expected` String value that tells a human what the
test should do, and a `test` Function value that tells it how to carry out the
test.

The `test` will be passed a callback function as its only argument, which it
should call once it is finished.  If the test failed, pass an `Error` object or
`String` error message as the first parameter.  If it succeeded, pass `null` as
the first parameter and an optional String describing the success as the
second.
