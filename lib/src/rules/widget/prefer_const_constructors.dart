import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects widgets that could use a const constructor but do not.
///
/// **Performance issue:** Widgets without const are rebuilt every frame when
/// their parent rebuilds. Const constructors allow Flutter to short-circuit
/// most of the rebuild work by reusing the same widget instance.
///
/// **Recommendation:** Add the `const` keyword before the widget constructor
/// when the widget has no dynamic dependencies.
class PreferConstConstructors extends DartLintRule {
  PreferConstConstructors() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_prefer_const_constructors',
    problemMessage:
        'This widget should use a const constructor for better performance.',
    correctionMessage: 'Add the const keyword before the constructor.',
  );

  @override
  List<Fix> getFixes() => [_AddConstFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.isConst) return;

      final typeName = WidgetUtils.getTypeName(node);
      if (typeName == null) return;

      if (WidgetUtils.constCapableWidgets.contains(typeName)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class _AddConstFix extends DartFix {
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
      if (node.isConst) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add const',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(node.offset, 'const ');
      });
    });
  }
}
