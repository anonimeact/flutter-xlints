// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects creating RegExp repeatedly in loops or build.
class AvoidRecreatingRegExp extends DartLintRule {
  AvoidRecreatingRegExp() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_recreating_regexp',
    problemMessage:
        'Avoid creating RegExp repeatedly in loops/build. Reuse a cached/static final instance.',
    correctionMessage:
        'Create RegExp once (for example as static final or a field) and reuse it.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type != 'RegExp') return;

      final inLoop = node.thisOrAncestorOfType<ForStatement>() != null ||
          node.thisOrAncestorOfType<ForEachParts>() != null ||
          node.thisOrAncestorOfType<WhileStatement>() != null ||
          node.thisOrAncestorOfType<DoStatement>() != null;

      final inBuild =
          node.thisOrAncestorOfType<MethodDeclaration>()?.name.lexeme ==
              'build';

      if (inLoop || inBuild) {
        reporter.atNode(node, code);
      }
    });
  }
}
