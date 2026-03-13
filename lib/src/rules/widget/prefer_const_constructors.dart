// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
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
      if (_shouldReport(node)) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _shouldReport(InstanceCreationExpression node) {
    if (node.isConst) return false;

    final typeName = WidgetUtils.getTypeName(node);
    if (typeName == null) return false;

    // Be conservative for Text: if the main text argument is not a simple
    // string literal (e.g. it uses interpolation like "+$value"), treat it
    // as non-const so we don't suggest const incorrectly.
    if (typeName == 'Text') {
      final positionalArgs = node.argumentList.arguments
          .where((arg) => arg is! NamedExpression)
          .toList();

      if (positionalArgs.isNotEmpty) {
        final first = positionalArgs.first;
        final expr = first is NamedExpression ? first.expression : first;
        if (expr is! SimpleStringLiteral) {
          return false;
        }
      }
    }

    if (!WidgetUtils.constCapableWidgets.contains(typeName)) return false;

    final constructor = node.constructorName.element;
    if (constructor == null || !constructor.isConst) return false;

    for (final arg in node.argumentList.arguments) {
      final expression = arg is NamedExpression ? arg.expression : arg;
      if (!_isConstLikeExpression(expression)) return false;
    }

    return true;
  }

  bool _isConstLikeExpression(Expression expression) {
    if (expression is ParenthesizedExpression) {
      return _isConstLikeExpression(expression.expression);
    }

    if (expression is Literal) return true;
    if (expression is InstanceCreationExpression) return expression.isConst;

    if (expression is SimpleIdentifier) {
      final element = expression.element;
      if (element is VariableElement) return element.isConst;
      if (element is PropertyAccessorElement) return element.variable.isConst;
      return false;
    }

    if (expression is PrefixedIdentifier) {
      final element = expression.identifier.element;
      if (element is VariableElement) return element.isConst;
      if (element is PropertyAccessorElement) return element.variable.isConst;
      return false;
    }

    if (expression is PropertyAccess) {
      final element = expression.propertyName.element;
      if (element is PropertyAccessorElement) return element.variable.isConst;
      return false;
    }

    return false;
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
    final rule = PreferConstConstructors();
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;
      if (!rule._shouldReport(node)) return;

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
