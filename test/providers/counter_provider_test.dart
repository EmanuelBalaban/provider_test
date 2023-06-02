import 'package:test/test.dart';

import 'package:provider_test/provider_test.dart';
import '../../example/providers/counter_provider.dart';

void main() {
  group(CounterProvider, () {
    testProvider<CounterProvider>(
      'Given the counter provider is initialized '
      'Then it starts with 0 as the initial counter value.',
      build: CounterProvider.new,
      verify: (provider) => expect(provider.value, isZero),
    );

    testProvider<CounterProvider>(
      'Given the counter provider starts with value 0 '
      'When calling increment() '
      'Then it increments the value to 1 '
      'And it notifies the listeners.',
      build: CounterProvider.new,
      act: (provider) => provider.increment(),
      expect: {
        (provider) => provider.value: [1],
      },
      verify: (provider) => expect(provider.value, equals(1)),
    );

    testProvider<CounterProvider>(
      'Given the counter provider starts with value 1 '
      'When calling decrement() '
      'Then it decrements the value to 0 '
      'And it notifies the listeners.',
      build: CounterProvider.new,
      seed: (provider) => provider.value = 1,
      act: (provider) => provider.decrement(),
      expect: {
        (provider) => provider.value: [isZero],
      },
      verify: (provider) => expect(provider.value, isZero),
    );
  });
}
