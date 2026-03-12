# xlints

Lint package untuk Flutter yang fokus pada isu performa widget dan logic.

## Rule yang tersedia

### Custom lint rules

<details>
<summary><code>xlints_prefer_const_constructors</code></summary>

Deteksi widget yang bisa `const` tapi belum `const`.

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

Deteksi list panjang yang sebaiknya pakai `.builder`.

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

Deteksi penggunaan `ListView/GridView(children: ...)` yang membangun semua item sekaligus.

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

Deteksi penggunaan `Opacity` untuk kasus yang bisa dihindari.

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

Deteksi `Padding` yang membungkus child yang sudah punya `margin`.

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

Deteksi `shrinkWrap: true` pada list/grid yang dapat menambah biaya layout.

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

Deteksi `IntrinsicHeight/IntrinsicWidth` yang mahal di layout.

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

Deteksi pembuatan controller/node di dalam `build()`.

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

Deteksi override `operator ==` di turunan `Widget`.

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

Deteksi `setState()` di method `build()`.

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

Deteksi string concatenation dengan `+` di dalam loop.

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

## Prasyarat

- Flutter SDK aktif di environment.
- Dart SDK sesuai constraint package (`sdk: ^3.10.4`).

## Instalasi

### Opsi A: dari pub.dev

Tambahkan ke `dev_dependencies`:

```yaml
dev_dependencies:
  xlints: ^1.0.0
```

Jalankan:

```bash
flutter pub get
```

### Opsi B: dari local path (untuk development package ini)

```yaml
dev_dependencies:
  xlints:
    path: ../path-ke-xlints
```

Jalankan:

```bash
flutter pub get
```

## Setup `analysis_options.yaml`

Pilih salah satu.

### Opsi 1 (direkomendasikan): full config

Gunakan jika kamu belum punya baseline lint sendiri:

```yaml
include: package:xlints/analysis_options.yaml
```

Isi ini akan mengaktifkan:

- `package:lints/recommended.yaml`
- plugin `custom_lint`

### Opsi 2: plugin-only

Gunakan jika project kamu sudah punya include lint lain (misalnya `flutter_lints`):

```yaml
include: package:xlints/analysis_options_xlints.yaml
```

Catatan:

- Tidak perlu menambah `custom_lint` manual di `pubspec.yaml`.
- Tidak perlu menambah `analyzer.plugins` manual jika sudah include salah satu file di atas.

## Cara menjalankan lint

Jalankan dari root project aplikasi Flutter:

```bash
dart run custom_lint
```

Alternatif:

```bash
flutter pub run custom_lint
```

Untuk auto-apply fix yang tersedia:

```bash
dart run custom_lint --fix
```

## Integrasi IDE

- Pastikan file `analysis_options.yaml` sudah benar.
- Buka project ulang di IDE jika warning belum muncul.
- Quick Fix bisa dipakai dari lightbulb action (untuk rule yang punya fix).

## Rule yang punya Quick Fix saat ini

- `xlints_prefer_const_constructors`: menambahkan keyword `const`.
- `xlints_avoid_padding_wrapping_margin_widget`: menghapus `Padding` terluar.

## Konfigurasi rule

Nonaktifkan rule tertentu:

```yaml
include: package:xlints/analysis_options.yaml

custom_lint:
  rules:
    - xlints_prefer_const_constructors: false
    - xlints_avoid_opacity_widget: false
```

## Contoh penggunaan

Project contoh ada di folder `example/`.

Jalankan:

```bash
cd example
dart run custom_lint
```

Contoh tersebut sengaja berisi pola "bad practice" agar semua rule `xlints` bisa terpicu.

## Troubleshooting

### `include_file_not_found` untuk `package:xlints/analysis_options.yaml`

Penyebab umum:

- `flutter pub get` belum dijalankan.
- Package `xlints` belum masuk ke dependency graph project.
- Salah path untuk dependency lokal.

Langkah cek:

1. Pastikan `pubspec.yaml` sudah memuat `xlints` di `dev_dependencies`.
2. Jalankan ulang `flutter pub get`.
3. Pastikan include persis:
   `include: package:xlints/analysis_options.yaml`
4. Jalankan lagi `dart run custom_lint`.

### Rule tidak muncul di IDE, tapi muncul di CLI

1. Reload window / restart analysis server IDE.
2. Pastikan project dibuka dari folder root yang memuat `analysis_options.yaml`.

## Dependensi internal package

- `analyzer: ^6.0.0`
- `custom_lint: ^0.6.0`
- `custom_lint_builder: ^0.6.0`
