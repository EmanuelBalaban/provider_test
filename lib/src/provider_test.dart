import 'dart:async';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// Creates a new `provider`-specific test case with the given [description].
/// [testProvider] will handle asserting that the `provider` changes its states
/// to the [expect]ed states (in order) while [act] is executed.
/// [testProvider] also ensures that no additional states are updated after
/// [act] is executed by removing the [listener] added to the provider.
///
/// [setUp] is optional and should be used to set up any dependencies prior to
/// initializing the `provider` under test.
/// [setUp] should be used to set up state necessary for a particular test case.
/// For common set up code, prefer to use `setUp` from `package:test/test.dart`.
///
/// [build] should construct and return the `provider` under test.
///
/// [seed] is an optional `Function` that initializes the `provider` internals
/// after it was set up but before [act] is called.
/// It is invoked with the `provider` returned by [build].
///
/// [act] is an optional callback which will be invoked with the `provider`
/// under test and should be used to interact with the `provider`.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `provider` under test such as `debounceTime`.
///
/// [expect] is an optional `Map` used to match the changes in the states of the
/// `provider`. The key is the selector of the property to listen to. The value
/// is the list of states or matchers to verify against the updates in the given
/// property. Please be aware that updates are detected only if
/// `notifyListeners` has been called.
///
/// [verify] is an optional callback which is invoked after the [expect] and
/// before [tearDown] and can be used for additional verification/assertions.
/// [verify] is called with the `provider` returned by [build].
///
/// [tearDown] is optional and can be used to
/// execute any code after the test has run.
/// [tearDown] should be used to clean up after a particular test case.
/// For common tear down code, prefer to use `tearDown` from
/// `package:test/test.dart`.
///
/// [tags] is optional and if it is passed, it declares user-defined tags
/// that are applied to the test. These tags can be used to select or
/// skip the test on the command line, or to do bulk test configuration.
///
/// ```dart
/// testProvider(
///   'CounterProvider updates state to [1] when increment() is called.',
///   build: () => CounterProvider(),
///   act: (provider) => provider.increment(),
///   expect: {
///     (provider) => provider.count: [1],
///   },
/// );
/// ```
///
/// [testProvider] can optionally be used with a seeded state.
///
/// ```dart
/// testProvider(
///   'CounterProvider updates state to [1] when increment() is called.',
///   build: () => CounterProvider(),
///   seed: (provider) => provider.count = 1;
///   act: (provider) => provider.increment(),
///   expect: {
///     (provider) => provider.count: [2],
///   },
/// );
/// ```
///
/// [testProvider] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// testProvider(
///   'CounterProvider updates state to [1] when increment() is called.',
///   build: () => CounterProvider(),
///   seed: (provider) => provider.count = 1;
///   act: (provider) => provider.increment(),
///   wait: const Duration(milliseconds: 300),
///   expect: {
///     (provider) => provider.count: [2],
///   },
/// );
/// ```
///
/// [testProvider] can also be used to [verify] internal provider functionality.
///
/// ```dart
/// testProvider(
///   'CounterProvider updates state to [1] when increment() is called.',
///   build: () => CounterProvider(),
///   seed: (provider) => provider.count = 1;
///   act: (provider) => provider.increment(),
///   expect: {
///     (provider) => provider.count: [2],
///   },
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   },
/// );
/// ```
///
/// **Note:** when using [testProvider] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// testProvider(
///   'CounterProvider updates state to [StateB] when function() is called.',
///   build: () => CounterProvider(),
///   act: (provider) => provider.function(),
///   expect: {
///     (provider) => provider.count: [isA<StateB>()],
///   },
/// );
/// ```
///
/// If [tags] is passed, it declares user-defined tags that are applied to the
/// test. These tags can be used to select or skip the test on the command line,
/// or to do bulk test configuration. All tags should be declared in the
/// [package configuration file][configuring tags]. The parameter can be an
/// [Iterable] of tag names, or a [String] representing a single tag.
///
/// [configuring tags]: https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md#configuring-tags
@isTest
void testProvider<P extends ChangeNotifier>(
  String description, {
  FutureOr<void> Function()? setUp,
  required P Function() build,
  FutureOr<void> Function(P provider)? seed,
  FutureOr<void> Function(P provider)? act,
  Duration? wait,
  Map<Object Function(P provider), List<Object>>? expect,
  FutureOr<void> Function(P provider)? verify,
  FutureOr<void> Function()? tearDown,
  // ignore: avoid-dynamic
  dynamic tags,
}) {
  test.test(
    description,
    // ignore: deprecated_member_use_from_same_package
    () => _testProvider(
      setUp: setUp,
      build: build,
      seed: seed,
      act: act,
      wait: wait,
      expect: expect,
      verify: verify,
      tearDown: tearDown,
    ),
    tags: tags,
  );
}

/// [_testProvider] is meant to be used internally inside this file only.
/// Use [testProvider] instead.
@Deprecated('Use [testProvider] instead')
Future<void> _testProvider<P extends ChangeNotifier>({
  FutureOr<void> Function()? setUp,
  required P Function() build,
  FutureOr<void> Function(P provider)? seed,
  FutureOr<void> Function(P provider)? act,
  Duration? wait,
  Map<Object Function(P provider), List<Object>>? expect,
  FutureOr<void> Function(P provider)? verify,
  FutureOr<void> Function()? tearDown,
}) async {
  await setUp?.call();
  final provider = build();
  await seed?.call(provider);

  test.TestFailure? testFailure;

  final checked = List<Object>.empty(growable: true);
  void listen() {
    if (expect == null || testFailure != null) return;

    for (var index = 0; index < expect.entries.length; index++) {
      final entry = expect.entries.elementAt(index);
      final selector = entry.key;

      final expected = entry.value.firstOrNull;

      final checkedState = checked[index];
      final state = selector(provider);

      if (state == checkedState) continue;
      try {
        test.expect(state, test.wrapMatcher(expected));
      } on test.TestFailure catch (exception) {
        testFailure = exception;
        rethrow;
      }

      // Update checked states
      checked[index] = state;
      // ignore: avoid-ignoring-return-values
      entry.value.removeAt(0);
    }
  }

  if (expect != null) {
    // Cache initial states of the provider
    // (so that we are able to detect changes)
    for (final selector in expect.keys) {
      checked.add(selector.call(provider));
    }
    provider.addListener(listen);
  }

  await act?.call(provider);

  if (wait != null) await Future<void>.delayed(wait);
  await Future<void>.delayed(Duration.zero);

  provider.removeListener(listen);

  // ignore: avoid-non-null-assertion
  if (testFailure != null) throw testFailure!;

  await verify?.call(provider);
  await tearDown?.call();
}
