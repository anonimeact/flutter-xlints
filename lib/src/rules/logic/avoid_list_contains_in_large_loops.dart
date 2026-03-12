// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects `list.contains(...)` inside loops.
///
/// This can become O(n²) for large data sets.
class AvoidListContainsInLargeLoops extends DartLintRule {
  AvoidListContainsInLargeLoops() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_list_contains_in_large_loops',
    problemMessage:
        'Avoid list.contains(...) inside loops. Prefer Set lookups for better complexity.',
    correctionMessage:
        'Convert lookup list to Set once and use set.contains(...) inside the loop.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'contains') return;
      final target = node.realTarget;
      if (target == null) return;

      final targetType = target.staticType;
      if (targetType == null || !targetType.isDartCoreList) return;

      final inLoop = node.thisOrAncestorOfType<ForStatement>() != null ||
          node.thisOrAncestorOfType<ForEachParts>() != null ||
          node.thisOrAncestorOfType<WhileStatement>() != null ||
          node.thisOrAncestorOfType<DoStatement>() != null;

      if (!inLoop) return;

      reporter.atNode(node, code);
    });
  }
}
