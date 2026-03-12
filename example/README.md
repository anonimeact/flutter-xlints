# Xlints Example

Example Flutter app that intentionally contains code patterns that trigger xlints performance rules.

## Purpose

This app demonstrates widgets and logic that cause poor performance. Each screen shows a specific anti-pattern. Use it as a reference for what **not** to do.

## Violations Included

| Screen | Rule | Bad Pattern |
| ------ | ---- | ----------- |
| Widget without const | `xlints_prefer_const_constructors` | SizedBox, Padding, Icon without const |
| ListView with children | `xlints_avoid_listview_with_children` | ListView(children: [...]) |
| Opacity widget | `xlints_avoid_opacity_widget` | Opacity(opacity: 0.5, ...) |
| Padding wrapping margin | `xlints_avoid_padding_wrapping_margin_widget` | Padding(child: Container(margin: ...)) |
| Widget operator == | `xlints_avoid_widget_operator_equals` | StatelessWidget with operator == override |
| shrinkWrap true | `xlints_avoid_shrink_wrap_true` | ListView(shrinkWrap: true, ...) |
| Intrinsic widget | `xlints_avoid_intrinsic_widgets` | IntrinsicHeight/IntrinsicWidth |
| Controller in build | `xlints_avoid_controller_in_build` | ScrollController() dibuat di build() |
| setState in build | `xlints_avoid_set_state_in_build` | setState() called inside build() |
| String concat in loop | `xlints_prefer_string_buffer` | result = result + 'x' in for loop |

## Run Lint

From the example directory:

```bash
dart run custom_lint
```

**Note:** The example is nested inside the xlints package, so it needs `analyzer.plugins: [custom_lint]` explicitly. Normal projects only need `include: package:xlints/analysis_options.yaml`.

## Run the App

```bash
flutter run
```
