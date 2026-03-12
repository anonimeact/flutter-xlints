// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects temporary list accumulation patterns better expressed with
/// collection-if/spread literals.
class PreferCollectionIfSpreadOverTempLists extends DartLintRule {
  PreferCollectionIfSpreadOverTempLists() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_prefer_collection_if_spread_over_temp_lists',
    problemMessage:
        'Prefer collection-if/spread instead of incrementally building temporary lists.',
    correctionMessage:
        'Use a list literal with if/spread entries to reduce intermediate list operations.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclarationStatement((statement) {
      final list = statement.variables;
      if (list.variables.length != 1) return;

      final declaration = list.variables.first;
      final name = declaration.name.lexeme;
      final initializer = declaration.initializer;
      if (initializer is! ListLiteral || initializer.elements.isNotEmpty) {
        return;
      }

      final block = statement.parent;
      if (block is! Block) return;

      final index = block.statements.indexOf(statement);
      if (index < 0 || index == block.statements.length - 1) return;

      var patternCount = 0;
      for (final s in block.statements.skip(index + 1)) {
        if (s is IfStatement) {
          final thenStmt = s.thenStatement;
          if (_isListAddPattern(thenStmt, name)) {
            patternCount++;
          }
          final elseStmt = s.elseStatement;
          if (elseStmt != null && _isListAddPattern(elseStmt, name)) {
            patternCount++;
          }
        } else if (_isListAddPattern(s, name)) {
          patternCount++;
        }
      }

      if (patternCount >= 2) {
        reporter.atNode(declaration, code);
      }
    });
  }

  bool _isListAddPattern(Statement stmt, String listName) {
    if (stmt is Block) {
      return stmt.statements.any((s) => _isListAddPattern(s, listName));
    }

    if (stmt is! ExpressionStatement) return false;
    final expr = stmt.expression;
    if (expr is! MethodInvocation) return false;

    final target = expr.realTarget;
    if (target is! SimpleIdentifier || target.name != listName) return false;

    return expr.methodName.name == 'add' || expr.methodName.name == 'addAll';
  }
}
