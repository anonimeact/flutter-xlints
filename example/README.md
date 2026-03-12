# Xlints Example

This Flutter example app intentionally contains code patterns that trigger xlints performance rules.

## Purpose

This app demonstrates widgets and logic that cause poor performance. Each screen shows a specific anti-pattern. Use it as a reference for what **not** to do.

## Violations Included

- Widget without const:
  - Rule: `xlints_prefer_const_constructors`
  - Pattern: `SizedBox`, `Padding`, `Icon` without `const`
- ListView with children:
  - Rule: `xlints_avoid_listview_with_children`
  - Pattern: `ListView(children: [...])`
- Long list without builder:
  - Rule: `xlints_prefer_listview_builder`
  - Pattern: non-builder list for large item counts
- Opacity widget:
  - Rule: `xlints_avoid_opacity_widget`
  - Pattern: `Opacity(opacity: 0.5, ...)`
- Padding wrapping margin:
  - Rule: `xlints_avoid_padding_wrapping_margin_widget`
  - Pattern: `Padding(child: Container(margin: ...))`
- Widget operator ==:
  - Rule: `xlints_avoid_widget_operator_equals`
  - Pattern: `StatelessWidget`/`StatefulWidget` overriding `operator ==`
- `shrinkWrap: true`:
  - Rule: `xlints_avoid_shrink_wrap_true`
  - Pattern: `ListView(shrinkWrap: true, ...)`
- Intrinsic widget:
  - Rule: `xlints_avoid_intrinsic_widgets`
  - Pattern: `IntrinsicHeight` / `IntrinsicWidth`
- Controller in build:
  - Rule: `xlints_avoid_controller_in_build`
  - Pattern: `ScrollController()` created inside `build()`
- setState in build:
  - Rule: `xlints_avoid_set_state_in_build`
  - Pattern: `setState()` called inside `build()`
- String concat in loop:
  - Rule: `xlints_prefer_string_buffer`
  - Pattern: `result = result + 'x'` in a loop

## Run Lint

From the example directory:

```bash
dart run custom_lint
```

Alternative:

```bash
flutter pub run custom_lint
```

**Note:** This example uses `include: package:xlints/analysis_options.yaml` in `analysis_options.yaml`, same as a normal consumer app.

## Run the App

```bash
flutter run
```
