// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects repeated DateTime.now() calls inside loops.
class AvoidRepeatedDateTimeNowInLoop extends DartLintRule {
  AvoidRepeatedDateTimeNowInLoop() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_repeated_datetime_now_in_loop',
    problemMessage:
        'Avoid calling DateTime.now() repeatedly inside loops. Read it once before the loop.',
    correctionMessage:
        'Store DateTime.now() in a local final variable outside the loop.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    void reportIfInsideLoop(AstNode node) {
      final inLoop = node.thisOrAncestorOfType<ForStatement>() != null ||
          node.thisOrAncestorOfType<ForEachParts>() != null ||
          node.thisOrAncestorOfType<WhileStatement>() != null ||
          node.thisOrAncestorOfType<DoStatement>() != null;

      if (inLoop) {
        reporter.atNode(node, code);
      }
    }

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'now') return;
      if (!node.toSource().contains('DateTime.now(')) return;
      reportIfInsideLoop(node);
    });

    context.registry.addFunctionExpressionInvocation((node) {
      if (!node.toSource().contains('DateTime.now(')) return;
      reportIfInsideLoop(node);
    });

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name2.lexeme;
      final ctorName = node.constructorName.name?.name;
      if (typeName != 'DateTime' || ctorName != 'now') return;
      reportIfInsideLoop(node);
    });
  }
}
