// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/widget_utils.dart';

/// Detects usage of the [Opacity] widget which is expensive for performance.
///
/// **Performance issue:** The [Opacity] widget triggers [saveLayer()], a costly
/// operation. Each saveLayer causes a render target switch on the GPU, which
/// is disruptive to rendering throughput.
///
/// **Recommendation:**
/// - For fade-in images: use [FadeInImage]
/// - For animations: use [AnimatedOpacity]
/// - For semi-transparent colors: use [Color] with alpha directly
class AvoidOpacityWidget extends DartLintRule {
  AvoidOpacityWidget() : super(code: _code);

  static const _code = LintCode(
    name: 'xlints_avoid_opacity_widget',
    problemMessage:
        'Opacity widget triggers expensive saveLayer(). Consider FadeInImage, AnimatedOpacity, or Color with alpha.',
    correctionMessage:
        'Replace with AnimatedOpacity (for animation) or FadeInImage (for image)',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = WidgetUtils.getTypeName(node);
      if (typeName == WidgetUtils.opacityWidget) {
        reporter.atNode(node, code);
      }
    });
  }
}
