// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects creating controllers/nodes inside `build()`.
///
/// **Performance issue:** Recreating controllers on every rebuild causes extra
/// allocations and may reset state unexpectedly.
///
/// **Recommendation:** Initialize in `initState()` and dispose in `dispose()`.
class AvoidControllerInBuild extends DartLintRule {
  AvoidControllerInBuild() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_controller_in_build',
    problemMessage:
        'Creating controller/node inside build() is inefficient. Move it to initState() and dispose it.',
    correctionMessage:
        'Create controller/node as a State field, initialize in initState(), and dispose in dispose().',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (!WidgetUtils.controllerTypes.contains(typeName)) return;

      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method == null || method.name.lexeme != 'build') return;

      reporter.atNode(node, code);
    });
  }
}
