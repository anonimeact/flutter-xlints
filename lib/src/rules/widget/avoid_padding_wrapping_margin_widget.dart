import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects [Padding] wrapping a widget that already has a [margin] parameter.
///
/// **Performance issue:** Redundant layout - the child already creates space
/// via margin. Wrapping with [Padding] adds an extra layout pass and widget
/// tree depth without benefit.
///
/// **Recommendation:** Move padding into the child's margin, or remove the
/// outer [Padding] if spacing is already sufficient.
class AvoidPaddingWrappingMarginWidget extends DartLintRule {
  AvoidPaddingWrappingMarginWidget() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_padding_wrapping_margin_widget',
    problemMessage:
        'Child widget already has margin. Avoid wrapping with Padding - use margin on the child instead.',
    correctionMessage:
        'Remove outer Padding or merge padding into the child\'s margin',
  );

  @override
  List<Fix> getFixes() => [_RemoveOuterPaddingFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (typeName != 'Padding') return;

      Expression? childExpr;
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'child') {
          childExpr = arg.expression;
          break;
        }
      }
      if (childExpr == null) return;

      Expression? inner = childExpr;
      if (inner is ParenthesizedExpression) inner = inner.expression;
      final child = inner;
      if (child is! InstanceCreationExpression) return;

      for (final arg in child.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'margin') {
          reporter.reportErrorForNode(code, node);
          return;
        }
      }
    });
  }
}

class _RemoveOuterPaddingFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;
      final typeName = WidgetUtils.getTypeName(node);
      if (typeName != 'Padding') return;

      Expression? childExpr;
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'child') {
          childExpr = arg.expression;
          break;
        }
      }
      if (childExpr == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove outer Padding',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          SourceRange(node.offset, node.length),
          childExpr!.toSource(),
        );
      });
    });
  }
}
