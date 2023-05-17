# provider_test

A testing library which makes it easy to test providers. Built after [bloc_test](https://pub.dev/packages/bloc_test) package.

## Unit Test with **testProvider**

**testProvider** creates a new `provider`-specific test case with the given `description`. 

`testProvider` will handle asserting that the `provider` changes its states to the `expect`ed states (in order) while `act` is executed.  `testProvider` also ensures that no additional states are updated after `act` is executed by removing the `listener` added to the provider.

`setUp` is optional and should be used to set up any dependencies prior to initializing the `provider` under test. `setUp` should be used to set up state necessary for a particular test case. For common set up code, prefer to use `setUp` from `package:test/test.dart`.

`build` should construct and return the `provider` under test.

`seed` is an optional `Function` that initializes the `provider` internals after it was set up but before `act` is called. It is invoked with the `provider` returned by `build`.

`act` is an optional callback which will be invoked with the `provider` under test and should be used to interact with the `provider`.

`wait` is an optional `Duration` which can be used to wait for async operations within the `provider` under test such as `debounceTime`.

`expect` is an optional `Map` used to match the changes in the states of the `provider`. The key is the selector of the property to listen to. The value is the list of states or matchers to verify against the updates in the given property. Please be aware that updates are detected only if `notifyListeners` has been called.

`verify` is an optional callback which is invoked after the `expect` and before `tearDown` and can be used for additional verification/assertions. `verify` is called with the `provider` returned by `build`.

`tearDown` is optional and can be used to execute any code after the test has run. `tearDown` should be used to clean up after a particular test case. For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.

`tags` is optional and if it is passed, it declares user-defined tags that are applied to the test. These tags can be used to select or skip the test on the command line, or to do bulk test configuration.

```dart
testProvider(
  'CounterProvider updates state to [1] when increment() is called.',
  build: () => CounterProvider(),
  act: (provider) => provider.increment(),
  expect: {
    (provider) => provider.count: [1],
  },
);

```

`testProvider` can optionally be used with a seeded state.

```dart
testProvider(
  'CounterProvider updates state to [1] when increment() is called.',
  build: () => CounterProvider(),
  seed: (provider) => provider.count = 1;
  act: (provider) => provider.increment(),
  expect: {
    (provider) => provider.count: [2],
  },
);
```

`testProvider` can also be used to wait for async operations by optionally providing a `Duration` to `wait`.

```dart
testProvider(
  'CounterProvider updates state to [1] when increment() is called.',
  build: () => CounterProvider(),
  seed: (provider) => provider.count = 1;
  act: (provider) => provider.increment(),
  wait: const Duration(milliseconds: 300),
  expect: {
    (provider) => provider.count: [2],
  },
);
```

`testProvider` can also be used to `verify` internal provider functionality.

```dart
testProvider(
  'CounterProvider updates state to [1] when increment() is called.',
  build: () => CounterProvider(),
  seed: (provider) => provider.count = 1;
  act: (provider) => provider.increment(),
  expect: {
    (provider) => provider.count: [2],
  },
  verify: (_) {
    verify(() => repository.someMethod(any())).called(1);
  },
);
```

**Note:** when using `testProvider` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
testProvider(
  'CounterProvider updates state to [StateB] when function() is called.',
  build: () => CounterProvider(),
  act: (provider) => provider.function(),
  expect: {
    (provider) => provider.count: [isA<StateB>()],
  },
);
```

If `tags` is passed, it declares user-defined tags that are applied to the test. These tags can be used to select or skip the test on the command line, or to do bulk test configuration. All tags should be declared in the package configuration file. The parameter can be an `Iterable` of tag names, or a `String` representing a single tag. 

For more information about `configuring tags`, please refer to the [official documention](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md#configuring-tags).

## Compatibility

- Dart 2: >= 2.19
- Flutter 3: >= 3.7.0

## Maintainers

- [Emanuel Balaban](https://github.com/EmanuelBalaban)