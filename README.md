# xlints

`xlints` is a Flutter lint package focused on widget and logic performance.

## Available Rules

<details>
<summary><code>xlints_prefer_const_constructors</code></summary>

Detects widgets that can be `const` but are not marked `const`.

BAD:
```dart
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Icon(Icons.star),
  );
}
```

GOOD:
```dart
Widget build(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(8),
    child: Icon(Icons.star),
  );
}
```
</details>

<details>
<summary><code>xlints_prefer_listview_builder</code></summary>

Detects long lists that should use `.builder`.

BAD:
```dart
ListView(
  children: List.generate(1000, (i) => Text('Item $i')),
)
```

GOOD:
```dart
ListView.builder(
  itemCount: 1000,
  itemBuilder: (_, i) => Text('Item $i'),
)
```
</details>

<details>
<summary><code>xlints_avoid_listview_with_children</code></summary>

Detects `ListView/GridView(children: ...)` usage that builds all items eagerly.

BAD:
```dart
GridView(
  children: List.generate(200, (i) => Card(child: Text('$i'))),
)
```

GOOD:
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  itemCount: 200,
  itemBuilder: (_, i) => Card(child: Text('$i')),
)
```
</details>

<details>
<summary><code>xlints_avoid_opacity_widget</code></summary>

Detects `Opacity` usage in cases where a cheaper alternative is preferred.

BAD:
```dart
Opacity(
  opacity: 0.5,
  child: Image.network(url),
)
```

GOOD:
```dart
AnimatedOpacity(
  opacity: 0.5,
  duration: const Duration(milliseconds: 200),
  child: Image.network(url),
)
```
</details>

<details>
<summary><code>xlints_avoid_padding_wrapping_margin_widget</code></summary>

Detects `Padding` wrapping a child that already uses `margin`.

BAD:
```dart
Padding(
  padding: const EdgeInsets.all(16),
  child: Container(
    margin: const EdgeInsets.all(8),
    child: const Text('Hello'),
  ),
)
```

GOOD:
```dart
Container(
  margin: const EdgeInsets.all(24),
  child: const Text('Hello'),
)
```
</details>

<details>
<summary><code>xlints_avoid_shrink_wrap_true</code></summary>

Detects `shrinkWrap: true` on list/grid widgets, which can increase layout cost.

BAD:
```dart
ListView(
  shrinkWrap: true,
  children: items.map((e) => Text(e)).toList(),
)
```

GOOD:
```dart
Expanded(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => Text(items[i]),
  ),
)
```
</details>

<details>
<summary><code>xlints_avoid_intrinsic_widgets</code></summary>

Detects expensive `IntrinsicHeight/IntrinsicWidth` usage.

BAD:
```dart
IntrinsicHeight(
  child: Row(children: children),
)
```

GOOD:
```dart
SizedBox(
  height: 72,
  child: Row(children: children),
)
```
</details>

<details>
<summary><code>xlints_avoid_controller_in_build</code></summary>

Detects controller/node creation inside `build()`.

BAD:
```dart
@override
Widget build(BuildContext context) {
  final controller = ScrollController();
  return ListView(controller: controller);
}
```

BAD:
```dart
@override
Widget build(BuildContext context) {
  final focusNode = FocusNode();
  return TextField(focusNode: focusNode);
}
```

GOOD:
```dart
class _MyState extends State<MyWidget> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: controller);
  }
}
```
</details>

<details>
<summary><code>xlints_avoid_widget_operator_equals</code></summary>

Detects `operator ==` override on `Widget` subclasses.

BAD:
```dart
class MyCard extends StatelessWidget {
  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;

  @override
  Widget build(BuildContext context) => const SizedBox();
}
```

GOOD:
```dart
class MyCard extends StatelessWidget {
  const MyCard({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}
```
</details>

<details>
<summary><code>xlints_avoid_set_state_in_build</code></summary>

Detects `setState()` calls inside `build()`.

BAD:
```dart
@override
Widget build(BuildContext context) {
  setState(() => counter++);
  return Text('$counter');
}
```

GOOD:
```dart
void _increment() {
  setState(() => counter++);
}
```
</details>

<details>
<summary><code>xlints_prefer_string_buffer</code></summary>

Detects string concatenation with `+` inside loops.

BAD:
```dart
var result = '';
for (var i = 0; i < 1000; i++) {
  result = result + values[i];
}
```

GOOD:
```dart
final buffer = StringBuffer();
for (var i = 0; i < 1000; i++) {
  buffer.write(values[i]);
}
final result = buffer.toString();
```
</details>

## Prerequisites

- Flutter SDK available in your environment.
- Dart SDK compatible with this package (`sdk: ^3.10.4`).

## Installation

### Option A: from pub.dev

Add this to `dev_dependencies`:

```yaml
dev_dependencies:
  xlints: ^1.0.0
```

Run:

```bash
flutter pub get
```

### Option B: from a local path (for local development)

```yaml
dev_dependencies:
  xlints:
    path: ../path-to-xlints
```

Run:

```bash
flutter pub get
```

## Configure `analysis_options.yaml`

Choose one option.

### Option 1 (recommended): full config

Use this if you do not already have a lint baseline:

```yaml
include: package:xlints/analysis_options.yaml
```

This enables:

- `package:lints/recommended.yaml`
- plugin `custom_lint`

### Option 2: plugin-only

Use this if your project already includes another lint config (for example `flutter_lints`):

```yaml
include: package:xlints/analysis_options_xlints.yaml
```

Notes:

- You do not need to add `custom_lint` manually to `pubspec.yaml`.
- You do not need to add `analyzer.plugins` manually if you include one of the files above.

## Run Lints

Run from your Flutter app root:

```bash
dart run custom_lint
```

Alternative:

```bash
flutter pub run custom_lint
```

To auto-apply available fixes:

```bash
dart run custom_lint --fix
```

## IDE Integration

- Make sure `analysis_options.yaml` is configured correctly.
- Reopen the project if warnings do not appear.
- Use lightbulb Quick Fix for rules that provide fixes.

## Rules With Quick Fix (Current)

- `xlints_prefer_const_constructors`: adds the `const` keyword.
- `xlints_avoid_padding_wrapping_margin_widget`: removes the outer `Padding`.

## Rule Configuration

Disable specific rules:

```yaml
include: package:xlints/analysis_options.yaml

custom_lint:
  rules:
    - xlints_prefer_const_constructors: false
    - xlints_avoid_opacity_widget: false
```

## Example Usage

An example project is available in `example/`.

Run:

```bash
cd example
dart run custom_lint
```

The example intentionally contains bad patterns to trigger all `xlints` rules.

## Troubleshooting

### `include_file_not_found` for `package:xlints/analysis_options.yaml`

Common causes:

- `flutter pub get` has not been run.
- `xlints` is not present in your dependency graph.
- Incorrect local path dependency.

Checklist:

1. Ensure `pubspec.yaml` includes `xlints` in `dev_dependencies`.
2. Run `flutter pub get` again.
3. Ensure the include line is exactly:
   `include: package:xlints/analysis_options.yaml`
4. Run `dart run custom_lint` again.

### Rules do not appear in IDE, but appear in CLI

1. Reload the IDE window or restart the analysis server.
2. Make sure the opened project root contains `analysis_options.yaml`.

## Internal Dependencies

- `analyzer: ^6.0.0`
- `custom_lint: ^0.6.0`
- `custom_lint_builder: ^0.6.0`
