// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects `jsonDecode` calls inside `build()`.
///
/// Parsing JSON in build can cause repeated CPU work on every rebuild.
class AvoidJsonDecodeInBuild extends DartLintRule {
  AvoidJsonDecodeInBuild() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_json_decode_in_build',
    problemMessage:
        'Avoid calling jsonDecode inside build(). Parse data before build.',
    correctionMessage:
        'Move jsonDecode to initState, a data layer, or a cached value.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'jsonDecode') return;

      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method == null || method.name.lexeme != 'build') return;

      reporter.atNode(node, code);
    });
  }
}
