// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects usage of IntrinsicHeight/IntrinsicWidth.
///
/// **Performance issue:** Intrinsic measurement can trigger extra layout work
/// and is expensive when used frequently in list items or deep trees.
///
/// **Recommendation:** Prefer explicit constraints with `SizedBox`, `Expanded`,
/// `Flexible`, or a custom layout.
class AvoidIntrinsicWidgets extends DartLintRule {
  AvoidIntrinsicWidgets() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_intrinsic_widgets',
    problemMessage:
        'IntrinsicHeight/IntrinsicWidth are expensive. Prefer explicit constraints.',
    correctionMessage:
        'Replace with SizedBox/Expanded/Flexible or custom layout constraints.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (WidgetUtils.intrinsicWidgets.contains(typeName)) {
        reporter.atNode(node, code);
      }
    });
  }
}
