import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects string concatenation using `+` inside loops.
///
/// **Performance issue:** Using the `+` operator to concatenate strings in a
/// loop creates a new [String] object on each iteration - O(n²) complexity.
///
/// **Recommendation:** Use [StringBuffer] which collects strings and
/// concatenates once when [StringBuffer.toString] is called.
class PreferStringBuffer extends DartLintRule {
  PreferStringBuffer() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_prefer_string_buffer',
    problemMessage:
        'String concatenation with + in loop is inefficient. Use StringBuffer.',
    correctionMessage:
        'Use StringBuffer: final buffer = StringBuffer(); buffer.write(s); ... buffer.toString()',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBinaryExpression((node) {
      if (node.operator.type != TokenType.PLUS) return;

      final forStatement = node.thisOrAncestorOfType<ForStatement>();
      final forElement = node.thisOrAncestorOfType<ForElement>();
      final whileStatement = node.thisOrAncestorOfType<WhileStatement>();

      if (forStatement == null &&
          forElement == null &&
          whileStatement == null) {
        return;
      }

      final left = node.leftOperand;
      final right = node.rightOperand;

      final hasStringLiteral = left is StringLiteral || right is StringLiteral;
      if (hasStringLiteral) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
