// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects ListView/GridView with children that should use the builder pattern.
///
/// **Performance issue:** `ListView(children: [...])` builds all children at
/// once. For long lists, this causes high build cost and memory usage.
///
/// **Recommendation:** Use [ListView.builder] or [GridView.builder] for lazy
/// loading - only visible items are built.
class PreferListViewBuilder extends DartLintRule {
  PreferListViewBuilder() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_prefer_listview_builder',
    problemMessage:
        'For long lists, use ListView.builder/GridView.builder for better performance.',
    correctionMessage:
        'Replace with ListView.builder(itemCount: n, itemBuilder: (context, i) => ...)',
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
            arg.expression is! ListLiteral) {
          reporter.atNode(node, code);
          return;
        }
      }
    });
  }
}
