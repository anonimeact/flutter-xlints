import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/logic/prefer_string_buffer.dart';
import 'src/rules/widget/avoid_listview_with_children.dart';
import 'src/rules/widget/avoid_controller_in_build.dart';
import 'src/rules/widget/avoid_intrinsic_widgets.dart';
import 'src/rules/widget/avoid_opacity_widget.dart';
import 'src/rules/widget/avoid_padding_wrapping_margin_widget.dart';
import 'src/rules/widget/avoid_shrink_wrap_true.dart';
import 'src/rules/widget/avoid_set_state_in_build.dart';
import 'src/rules/widget/avoid_widget_operator_equals.dart';
import 'src/rules/widget/prefer_const_constructors.dart';
import 'src/rules/widget/prefer_listview_builder.dart';

/// Entry point for the xlints plugin - Flutter Performance Linter.
///
/// This function is required by the custom_lint framework. It returns the
/// plugin instance that provides all performance-related lint rules.
PluginBase createPlugin() => _XlintsPlugin();

/// Internal plugin implementation that registers all xlints performance rules.
class _XlintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // Widget performance rules
    PreferConstConstructors(),
    PreferListViewBuilder(),
    AvoidListViewWithChildren(),
    AvoidOpacityWidget(),
    AvoidPaddingWrappingMarginWidget(),
    AvoidShrinkWrapTrue(),
    AvoidIntrinsicWidgets(),
    AvoidControllerInBuild(),
    AvoidWidgetOperatorEquals(),
    AvoidSetStateInBuild(),
    // Logic performance rules
    PreferStringBuffer(),
  ];
}
