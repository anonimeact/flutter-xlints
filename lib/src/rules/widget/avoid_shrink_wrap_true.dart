import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects `shrinkWrap: true` on scrollable lists/grids.
///
/// **Performance issue:** `shrinkWrap: true` forces additional layout passes
/// because the scrollable must compute the full extent of its children.
///
/// **Recommendation:** Prefer bounded parents (`Expanded`, fixed height) and
/// keep `shrinkWrap` as `false` when possible.
class AvoidShrinkWrapTrue extends DartLintRule {
  AvoidShrinkWrapTrue() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_shrink_wrap_true',
    problemMessage:
        'Using shrinkWrap: true is expensive for large lists. Prefer bounded layout and shrinkWrap: false.',
    correctionMessage:
        'Remove shrinkWrap: true or wrap the list with Expanded/SizedBox constraints.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (!WidgetUtils.shrinkWrapWidgets.contains(typeName)) return;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        if (arg.name.label.name != 'shrinkWrap') continue;
        if (arg.expression is BooleanLiteral &&
            (arg.expression as BooleanLiteral).value) {
          reporter.reportErrorForNode(code, arg);
          return;
        }
      }
    });
  }
}
