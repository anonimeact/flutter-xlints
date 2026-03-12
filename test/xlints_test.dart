import 'dart:io' as io;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:xlints/xlints.dart';

import 'package:xlints/src/rules/logic/avoid_heavy_sync_work_in_build.dart';
import 'package:xlints/src/rules/logic/avoid_json_decode_in_build.dart';
import 'package:xlints/src/rules/logic/avoid_list_contains_in_large_loops.dart';
import 'package:xlints/src/rules/logic/avoid_recreating_regexp.dart';
import 'package:xlints/src/rules/logic/avoid_repeated_datetime_now_in_loop.dart';
import 'package:xlints/src/rules/logic/prefer_collection_if_spread_over_temp_lists.dart';
import 'package:xlints/src/rules/logic/prefer_final_locals.dart';
import 'package:xlints/src/rules/logic/prefer_string_buffer.dart';
import 'package:xlints/src/rules/widget/avoid_listview_with_children.dart';
import 'package:xlints/src/rules/widget/avoid_controller_in_build.dart';
import 'package:xlints/src/rules/widget/avoid_intrinsic_widgets.dart';
import 'package:xlints/src/rules/widget/avoid_opacity_widget.dart';
import 'package:xlints/src/rules/widget/avoid_padding_wrapping_margin_widget.dart';
import 'package:xlints/src/rules/widget/avoid_shrink_wrap_true.dart';
import 'package:xlints/src/rules/widget/avoid_set_state_in_build.dart';
import 'package:xlints/src/rules/widget/avoid_widget_operator_equals.dart';
import 'package:xlints/src/rules/widget/prefer_const_constructors.dart';
import 'package:xlints/src/rules/widget/prefer_listview_builder.dart';

io.File _writeToTemporaryFile(String content) {
  final tempDir = io.Directory.systemTemp.createTempSync();
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final file = io.File(p.join(tempDir.path, 'file.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  return file;
}

Future<ResolvedUnitResult> _resolveFile(io.File file) async {
  final result = await resolveFile2(path: file.path);
  return result as ResolvedUnitResult;
}

void main() {
  group('Plugin', () {
    test('plugin can be created', () {
      final plugin = createPlugin();
      expect(plugin, isNotNull);
    });

    test('plugin returns lint rules', () async {
      final plugin = createPlugin();
      final packageConfig = await parsePackageConfig(io.Directory.current);
      final configs = CustomLintConfigs.parse(null, packageConfig);
      final rules = plugin.getLintRules(configs);
      expect(rules.length, greaterThanOrEqualTo(18));
    });
  });

  group('PreferConstConstructors', () {
    test('reports widget without const when type matches', () async {
      final rule = PreferConstConstructors();
      // Use class defined in same file - analyzer can resolve it
      final file = _writeToTemporaryFile('''
class SizedBox {
  final double? width;
  const SizedBox({this.width});
}

void build() {
  return SizedBox(width: 10);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_prefer_const_constructors');
    });

    test('does not report when const is used', () async {
      final rule = PreferConstConstructors();
      final file = _writeToTemporaryFile('''
class SizedBox {
  final double? width;
  const SizedBox({this.width});
}

void build() {
  return const SizedBox(width: 10);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });

    test('does not report when constructor argument is non-const', () async {
      final rule = PreferConstConstructors();
      final file = _writeToTemporaryFile('''
class Text {
  final String data;
  const Text(this.data);
}

String getLabel() => 'dynamic';

void build() {
  Text(getLabel());
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidOpacityWidget', () {
    test('reports Opacity widget', () async {
      final rule = AvoidOpacityWidget();
      final file = _writeToTemporaryFile('''
class Opacity {
  final double opacity;
  final dynamic child;
  Opacity({required this.opacity, required this.child});
}

void build() {
  return Opacity(opacity: 0.5, child: null);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_opacity_widget');
    });
  });

  group('AvoidListViewWithChildren', () {
    test('reports ListView with children', () async {
      final rule = AvoidListViewWithChildren();
      final file = _writeToTemporaryFile('''
class ListView {
  final List<dynamic> children;
  ListView({required this.children});
}

class Text {
  final String data;
  Text(this.data);
}

void build() {
  return ListView(children: [Text('a'), Text('b')]);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_listview_with_children',
      );
    });

    test('PreferListViewBuilder reports generated children list', () async {
      final rule = PreferListViewBuilder();
      final file = _writeToTemporaryFile('''
class ListView {
  final List<dynamic> children;
  ListView({required this.children});
}

void build() {
  return ListView(children: List.generate(50, (i) => i));
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_prefer_listview_builder');
    });

    test('does not report ListView.builder', () async {
      final rule = AvoidListViewWithChildren();
      final file = _writeToTemporaryFile('''
class ListView {
  ListView.builder({required int itemCount, required dynamic itemBuilder});
  final List<dynamic> children;
  ListView({required this.children});
}

void build() {
  return ListView.builder(itemCount: 10, itemBuilder: (i, c) => null);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidSetStateInBuild', () {
    test('reports setState in build method', () async {
      final rule = AvoidSetStateInBuild();
      final file = _writeToTemporaryFile('''
class State {
  void setState(void Function() fn) {}
}

class MyWidget extends State {
  Widget build(BuildContext context) {
    setState(() {});
    return SizedBox();
  }
}

class Widget {}
class SizedBox {}
class BuildContext {}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_set_state_in_build');
    });

    test('does not report setState outside build', () async {
      final rule = AvoidSetStateInBuild();
      final file = _writeToTemporaryFile('''
class State {
  void setState(void Function() fn) {}
}

class MyWidget extends State {
  void onPressed() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class Widget {}
class SizedBox {}
class BuildContext {}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidShrinkWrapTrue', () {
    test('reports ListView with shrinkWrap true', () async {
      final rule = AvoidShrinkWrapTrue();
      final file = _writeToTemporaryFile('''
class ListView {
  final bool shrinkWrap;
  ListView({required this.shrinkWrap});
}

void build() {
  ListView(shrinkWrap: true);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_shrink_wrap_true');
    });

    test('does not report when shrinkWrap false', () async {
      final rule = AvoidShrinkWrapTrue();
      final file = _writeToTemporaryFile('''
class ListView {
  final bool shrinkWrap;
  ListView({required this.shrinkWrap});
}

void build() {
  ListView(shrinkWrap: false);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidIntrinsicWidgets', () {
    test('reports IntrinsicHeight', () async {
      final rule = AvoidIntrinsicWidgets();
      final file = _writeToTemporaryFile('''
class IntrinsicHeight {
  final dynamic child;
  IntrinsicHeight({required this.child});
}

void build() {
  IntrinsicHeight(child: null);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_intrinsic_widgets');
    });
  });

  group('AvoidControllerInBuild', () {
    test('reports controller creation inside build', () async {
      final rule = AvoidControllerInBuild();
      final file = _writeToTemporaryFile('''
class ScrollController {
  ScrollController();
}

class BuildContext {}
class Widget {}
class State {
  Widget build(BuildContext context) {
    final c = ScrollController();
    return Widget();
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_controller_in_build');
    });

    test('does not report controller creation outside build', () async {
      final rule = AvoidControllerInBuild();
      final file = _writeToTemporaryFile('''
class ScrollController {
  ScrollController();
}

class MyState {
  final c = ScrollController();

  void initState() {
    final c2 = ScrollController();
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidPaddingWrappingMarginWidget', () {
    test('reports Padding wrapping widget with margin', () async {
      final rule = AvoidPaddingWrappingMarginWidget();
      final file = _writeToTemporaryFile('''
class EdgeInsets {
  static EdgeInsets all(double v) => EdgeInsets();
}

class Padding {
  final dynamic padding;
  final dynamic child;
  Padding({required this.padding, required this.child});
}

class Container {
  final dynamic margin;
  final dynamic child;
  Container({this.margin, this.child});
}

void build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Container(margin: EdgeInsets.all(4), child: null),
  );
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_padding_wrapping_margin_widget',
      );
    });

    test('does not report Padding wrapping widget without margin', () async {
      final rule = AvoidPaddingWrappingMarginWidget();
      final file = _writeToTemporaryFile('''
class EdgeInsets {
  static EdgeInsets all(double v) => EdgeInsets();
}

class Padding {
  final dynamic padding;
  final dynamic child;
  Padding({required this.padding, required this.child});
}

class Container {
  final dynamic child;
  Container({this.child});
}

void build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Container(child: null),
  );
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidWidgetOperatorEquals', () {
    test('reports operator == in Widget subclass', () async {
      final rule = AvoidWidgetOperatorEquals();
      final file = _writeToTemporaryFile('''
class StatelessWidget {}

class MyWidget extends StatelessWidget {
  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_widget_operator_equals',
      );
    });
  });

  group('AvoidJsonDecodeInBuild', () {
    test('reports jsonDecode call inside build', () async {
      final rule = AvoidJsonDecodeInBuild();
      final file = _writeToTemporaryFile('''
dynamic jsonDecode(String source) => {};

class BuildContext {}
class Widget {}

class MyWidget {
  Widget build(BuildContext context) {
    final data = jsonDecode('{}');
    return Widget();
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_json_decode_in_build');
    });
  });

  group('AvoidHeavySyncWorkInBuild', () {
    test('reports expensive collection operation in build', () async {
      final rule = AvoidHeavySyncWorkInBuild();
      final file = _writeToTemporaryFile('''
class BuildContext {}
class Widget {}

class ListX {
  void sort() {}
}

class MyWidget {
  Widget build(BuildContext context) {
    final values = ListX();
    values.sort();
    return Widget();
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_heavy_sync_work_in_build',
      );
    });
  });

  group('PreferFinalLocals', () {
    test('reports var local that is never reassigned', () async {
      final rule = PreferFinalLocals();
      final file = _writeToTemporaryFile('''
void main() {
  var name = 'xlints';
  print(name);
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_prefer_final_locals');
    });

    test('does not report var that is reassigned', () async {
      final rule = PreferFinalLocals();
      final file = _writeToTemporaryFile('''
void main() {
  var count = 0;
  count = count + 1;
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidRecreatingRegExp', () {
    test('reports RegExp creation inside loop', () async {
      final rule = AvoidRecreatingRegExp();
      final file = _writeToTemporaryFile('''
void main() {
  for (var i = 0; i < 10; i++) {
    final r = RegExp('a+');
    print(r);
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_avoid_recreating_regexp');
    });
  });

  group('AvoidListContainsInLargeLoops', () {
    test('reports contains call inside loop', () async {
      final rule = AvoidListContainsInLargeLoops();
      final file = _writeToTemporaryFile('''
void main() {
  final list = <int>[1, 2, 3];
  for (var i = 0; i < 10; i++) {
    list.contains(i);
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_list_contains_in_large_loops',
      );
    });

    test('does not report set.contains inside loop', () async {
      final rule = AvoidListContainsInLargeLoops();
      final file = _writeToTemporaryFile('''
void main() {
  final set = <int>{1, 2, 3};
  for (var i = 0; i < 10; i++) {
    set.contains(i);
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });

  group('AvoidRepeatedDateTimeNowInLoop', () {
    test('reports DateTime.now in loop', () async {
      final rule = AvoidRepeatedDateTimeNowInLoop();
      final file = _writeToTemporaryFile('''
class DateTime {
  static DateTime now() => DateTime();
}

void main() {
  for (var i = 0; i < 3; i++) {
    final t = DateTime.now();
    print(t);
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_avoid_repeated_datetime_now_in_loop',
      );
    });
  });

  group('PreferCollectionIfSpreadOverTempLists', () {
    test('reports temp list accumulation pattern', () async {
      final rule = PreferCollectionIfSpreadOverTempLists();
      final file = _writeToTemporaryFile('''
void main() {
  final values = [1, 2, 3];
  final out = <int>[];
  if (values.isNotEmpty) {
    out.add(0);
  }
  if (values.length > 1) {
    out.addAll(values);
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(
        errors.first.errorCode.name,
        'xlints_prefer_collection_if_spread_over_temp_lists',
      );
    });
  });

  group('PreferStringBuffer', () {
    test('reports string concatenation in for loop', () async {
      final rule = PreferStringBuffer();
      final file = _writeToTemporaryFile('''
void main() {
  var s = '';
  for (var i = 0; i < 10; i++) {
    s = s + 'x';
  }
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'xlints_prefer_string_buffer');
    });

    test('does not report string concatenation outside loop', () async {
      final rule = PreferStringBuffer();
      final file = _writeToTemporaryFile('''
void main() {
  final s = 'a' + 'b';
}
''');
      final result = await _resolveFile(file);
      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });
}
