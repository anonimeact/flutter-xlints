// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects override of [operator ==] on Widget subclasses.
///
/// **Performance issue:** Overriding [operator ==] on [Widget] causes O(N²)
/// behavior. Flutter compares widgets to decide whether to rebuild; overriding
/// [operator ==] removes compiler optimizations and degrades performance.
///
/// **Recommendation:** Do not override [operator ==] on Widget. Use const
/// constructors or widget caching for rebuild optimization instead.
class AvoidWidgetOperatorEquals extends DartLintRule {
  AvoidWidgetOperatorEquals() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_widget_operator_equals',
    problemMessage:
        'Overriding operator == on Widget hurts performance (O(N²)). Avoid this override.',
    correctionMessage:
        'Remove operator == override. Use const constructor for rebuild optimization.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (node.operatorKeyword == null) return;
      if (node.name.lexeme != '==') return;

      final parent = node.thisOrAncestorOfType<ClassDeclaration>();
      if (parent == null) return;

      final extendsClause = parent.extendsClause;
      if (extendsClause == null) return;

      final superName = extendsClause.superclass.name2.lexeme;
      if (superName == 'Widget' ||
          superName == 'StatelessWidget' ||
          superName == 'StatefulWidget') {
        reporter.atNode(node, code);
      }
    });
  }
}
