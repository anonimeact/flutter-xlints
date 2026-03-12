// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects ListView/GridView with a children list - builds all items at once.
///
/// **Performance issue:** Using `ListView(children: [item1, item2, ...])`
/// builds ALL items at startup, including those not visible on screen. This
/// causes jank, high memory usage, and slow startup.
///
/// **Recommendation:** Use [ListView.builder] which only builds visible items.
class AvoidListViewWithChildren extends DartLintRule {
  AvoidListViewWithChildren() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_listview_with_children',
    problemMessage:
        'ListView/GridView with children list builds all items at once. Use .builder() for lazy loading.',
    correctionMessage:
        'Replace with ListView.builder(itemCount: length, itemBuilder: (c, i) => items[i])',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (typeName == null) return;
      if (!WidgetUtils.lazyListWidgets.contains(typeName)) return;

      final constructorName = node.constructorName.name;
      if (constructorName?.name == 'builder') return;

      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression &&
            arg.name.label.name == 'children' &&
            arg.expression is ListLiteral) {
          reporter.atNode(node, code);
          return;
        }
      }
    });
  }
}
