import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:triple/src/models/memento_mixin.dart';
import 'package:triple/src/selectors.dart';
import 'package:triple/triple.dart';

void main() {
  late TestImplements<int, MyException> store;

  setUp(() {
    store = TestImplements(0);
  });

  test('check implementation. setState', () {
    store.setState(1);
    expect(store.propagated, Triple<int, MyException>(state: 1));
  });

  test('check implementation. setLoading', () {
    store.setLoading(true);
    expect(
        store.propagated,
        Triple<int, MyException>(
            state: 0, loading: true, event: TripleEvent.loading));
  });

  test('check implementation. setError', () {
    store.setError(const MyException('error'));
    expect(
        store.propagated,
        Triple<int, MyException>(
            state: 0,
            error: const MyException('error'),
            event: TripleEvent.error));
  });

  test('check implementation. disctinct setState', () {
    store.setError(const MyException('error'));
    final triple = store.propagated;
    store.setState(0);
    expect(store.propagated.hashCode, triple.hashCode);
  });

  test('check implementation. disctinct setState with memento', () {
    store.setError(const MyException('error'));
    store.setState(0);
    store.setState(1);
    store.setState(2);
    store.undo();
    expect(store.state, 1);
  });
}

class TestImplements<State extends Object, Error extends Object>
    extends Store<State, Error>
    with MementoMixin
    implements Selectors<Stream<State>, Stream<Error>, Stream<bool>> {
  TestImplements(State initialState) : super(initialState);

  late Triple<State, Error> propagated = triple;

  @override
  Future destroy() async {}

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool loading)? onLoading,
    void Function(Error error)? onError,
  }) {
    return () async {};
  }

  @protected
  @override
  void propagate() {
    super.propagate();
    propagated = triple;
  }

  @override
  Stream<Error> get selectError => throw UnimplementedError();

  @override
  Stream<bool> get selectLoading => throw UnimplementedError();

  @override
  Stream<State> get selectState => throw UnimplementedError();
}

class MyException implements Exception {
  final String message;

  const MyException(this.message);
}
