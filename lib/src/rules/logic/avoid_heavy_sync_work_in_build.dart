// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects common expensive synchronous collection operations in `build()`.
class AvoidHeavySyncWorkInBuild extends DartLintRule {
  AvoidHeavySyncWorkInBuild() : super(code: _code);

  static const _heavyMethods = {'sort', 'toList', 'fold', 'reduce'};

  static const _code = LintCode(
    name: 'xlints_avoid_heavy_sync_work_in_build',
    problemMessage:
        'Avoid heavy synchronous work inside build(). Precompute or cache results.',
    correctionMessage:
        'Move sorting/transformation work outside build (initState, memoization, or state layer).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!_heavyMethods.contains(node.methodName.name)) return;

      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method == null || method.name.lexeme != 'build') return;
      if (_hasHeavyAncestor(node)) return;

      reporter.atNode(node, code);
    });
  }

  bool _hasHeavyAncestor(MethodInvocation node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is MethodInvocation &&
          _heavyMethods.contains(current.methodName.name)) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }
}
