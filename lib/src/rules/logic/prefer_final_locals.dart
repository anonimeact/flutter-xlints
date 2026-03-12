// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects local `var` declarations that are never reassigned.
class PreferFinalLocals extends DartLintRule {
  PreferFinalLocals() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_prefer_final_locals',
    problemMessage:
        'Local variable is never reassigned. Prefer final for better clarity and optimizer-friendly intent.',
    correctionMessage: 'Replace var with final.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclarationStatement((statement) {
      final list = statement.variables;
      if (list.isFinal || list.isConst) return;
      if (list.keyword?.lexeme != 'var') return;

      for (final variable in list.variables) {
        if (variable.initializer == null) continue;

        final methodBody = variable.thisOrAncestorOfType<FunctionBody>();
        if (methodBody == null) continue;

        if (_isReassigned(methodBody, variable.name.lexeme)) continue;
        reporter.atNode(variable, code);
      }
    });
  }

  bool _isReassigned(FunctionBody body, String variableName) {
    var reassigned = false;

    body.visitChildren(
      _WriteVisitor(
        variableName: variableName,
        onWrite: () => reassigned = true,
      ),
    );

    return reassigned;
  }
}

class _WriteVisitor extends RecursiveAstVisitor<void> {
  _WriteVisitor({required this.variableName, required this.onWrite});

  final String variableName;
  final void Function() onWrite;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final left = node.leftHandSide;
    if (left is SimpleIdentifier && left.name == variableName) {
      onWrite();
      return;
    }
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    final operand = node.operand;
    if (operand is SimpleIdentifier &&
        operand.name == variableName &&
        (node.operator.type == TokenType.PLUS_PLUS ||
            node.operator.type == TokenType.MINUS_MINUS)) {
      onWrite();
      return;
    }
    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    final operand = node.operand;
    if (operand is SimpleIdentifier &&
        operand.name == variableName &&
        (node.operator.type == TokenType.PLUS_PLUS ||
            node.operator.type == TokenType.MINUS_MINUS)) {
      onWrite();
      return;
    }
    super.visitPrefixExpression(node);
  }
}
