import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects [setState] calls inside the [build] method.
///
/// **Performance issue:** Calling [setState] inside [build] creates an infinite
/// loop - setState triggers rebuild, which calls build again, which calls
/// setState again. This crashes the app or causes severe jank.
///
/// **Recommendation:** Move setState to event handlers (onPressed, onTap, etc.)
/// or lifecycle methods. Never call setState synchronously during build.
class AvoidSetStateInBuild extends DartLintRule {
  AvoidSetStateInBuild() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_set_state_in_build',
    problemMessage:
        'setState() inside build() causes infinite loop. Move it to an event handler.',
    correctionMessage: 'Move setState to onPressed, onTap, or other callbacks.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'setState') return;

      final buildMethod = node.thisOrAncestorOfType<MethodDeclaration>();
      if (buildMethod == null) return;
      if (buildMethod.name.lexeme != 'build') return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
