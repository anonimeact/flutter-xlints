// ignore_for_file: avoid_print
//
// This example intentionally contains bad patterns that trigger xlints rules.
// Run `dart run custom_lint` or `flutter pub run custom_lint` to see the reports.
//

import 'dart:convert';

import 'package:flutter/material.dart';

/// IMPORTANT:
/// To show lint violations from this `example/` app, remove or comment out
/// `exclude: example/**` in the package root `analysis_options.yaml`.
/// If `example/**` is excluded, custom_lint will not report violations here.
void main() => runApp(const XlintsExampleApp());

class XlintsExampleApp extends StatelessWidget {
  const XlintsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xlints Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Xlints Bad Examples')),
        body: const BadExamplesList(),
      ),
    );
  }
}

/// List of screens that demonstrate xlints violations.
class BadExamplesList extends StatelessWidget {
  const BadExamplesList({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      ('Widget without const', _WidgetWithoutConstScreen()),
      ('ListView with children', _ListViewWithChildrenScreen()),
      ('Opacity widget', _OpacityWidgetScreen()),
      ('Padding wrapping margin', _PaddingWrappingMarginScreen()),
      ('Widget operator ==', _WidgetOperatorEqualsScreen()),
      ('shrinkWrap true', _ShrinkWrapScreen()),
      ('Intrinsic widget', _IntrinsicWidgetScreen()),
      ('Controller in build', _ControllerInBuildScreen()),
      ('setState in build', _SetStateInBuildScreen()),
      ('String concat in loop', _StringConcatScreen()),
      ('jsonDecode in build', _JsonDecodeInBuildScreen()),
      ('Heavy sync work in build', _HeavySyncWorkInBuildScreen()),
      ('Prefer final locals', _PreferFinalLocalsScreen()),
      ('RegExp in loop', _RegExpInLoopScreen()),
      ('list.contains in loop', _ListContainsInLoopScreen()),
      ('DateTime.now in loop', _DateTimeNowInLoopScreen()),
      ('Temp list accumulation', _TempListAccumulationScreen()),
    ];

    return ListView.builder(
      itemCount: screens.length,
      itemBuilder: (_, i) {
        final (title, screen) = screens[i];
        return _buildTile(context, title, screen);
      },
    );
  }

  Widget _buildTile(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }
}

/// xlints_prefer_const_constructors
class _WidgetWithoutConstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget without const')),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(padding: EdgeInsets.all(8), child: Text('No const')),
          Icon(Icons.star),
        ],
      ),
    );
  }
}

/// xlints_avoid_listview_with_children
class _ListViewWithChildrenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView with children')),
      body: ListView(
        children: [
          ...List.generate(100, (i) => ListTile(title: Text('Item $i'))),
        ],
      ),
    );
  }
}

/// xlints_avoid_opacity_widget
class _OpacityWidgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opacity widget')),
      body: Opacity(
        opacity: 0.5,
        child: Container(
          color: Colors.blue,
          child: const Text('Use AnimatedOpacity or Color.withOpacity'),
        ),
      ),
    );
  }
}

/// xlints_avoid_padding_wrapping_margin_widget
class _PaddingWrappingMarginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Padding wrapping margin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(16),
          color: Colors.grey,
          child: const Text(
            'Container already has margin - remove outer Padding',
          ),
        ),
      ),
    );
  }
}

/// xlints_avoid_widget_operator_equals
class _WidgetOperatorEqualsScreen extends StatelessWidget {
  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget operator ==')),
      body: const Center(child: Text('Don\'t override == on Widget')),
    );
  }
}

/// xlints_avoid_shrink_wrap_true
class _ShrinkWrapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('shrinkWrap true')),
      body: ListView(
        shrinkWrap: true,
        children: List.generate(30, (i) => ListTile(title: Text('Row $i'))),
      ),
    );
  }
}

/// xlints_avoid_intrinsic_widgets
class _IntrinsicWidgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intrinsic widget')),
      body: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 80, color: Colors.red),
            Expanded(
              child: Container(
                color: Colors.green,
                child: const Text('IntrinsicHeight is expensive'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// xlints_avoid_controller_in_build
class _ControllerInBuildScreen extends StatefulWidget {
  @override
  State<_ControllerInBuildScreen> createState() =>
      _ControllerInBuildScreenState();
}

class _ControllerInBuildScreenState extends State<_ControllerInBuildScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return Scaffold(
      appBar: AppBar(title: const Text('Controller in build')),
      body: ListView.builder(
        controller: controller,
        itemCount: 20,
        itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
      ),
    );
  }
}

/// xlints_avoid_set_state_in_build
class _SetStateInBuildScreen extends StatefulWidget {
  @override
  State<_SetStateInBuildScreen> createState() => _SetStateInBuildScreenState();
}

class _SetStateInBuildScreenState extends State<_SetStateInBuildScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    setState(() => _counter++);
    return Scaffold(
      appBar: AppBar(title: const Text('setState in build')),
      body: Center(child: Text('Counter: $_counter')),
    );
  }
}

/// xlints_avoid_json_decode_in_build
class _JsonDecodeInBuildScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data =
        jsonDecode('{"title":"decoded in build"}') as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('jsonDecode in build')),
      body: Center(child: Text(data['title'] as String)),
    );
  }
}

/// xlints_avoid_heavy_sync_work_in_build
class _HeavySyncWorkInBuildScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final values = List.generate(1000, (i) => 1000 - i);
    values.sort();
    final topTen = values.where((e) => e.isEven).toList().take(10).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Heavy sync work in build')),
      body: ListView(children: topTen.map((e) => Text('Value $e')).toList()),
    );
  }
}

/// xlints_prefer_final_locals
class _PreferFinalLocalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var title = 'Prefer final locals';
    return Scaffold(
      appBar: AppBar(title: const Text('Prefer final locals')),
      body: Center(child: Text(title)),
    );
  }
}

/// xlints_avoid_recreating_regexp
class _RegExpInLoopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var totalMatches = 0;
    final values = List.generate(20, (i) => 'item-$i');
    for (final value in values) {
      final regex = RegExp(r'\d+');
      if (regex.hasMatch(value)) {
        totalMatches++;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('RegExp in loop')),
      body: Center(child: Text('Matches: $totalMatches')),
    );
  }
}

/// xlints_avoid_list_contains_in_large_loops
class _ListContainsInLoopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lookup = List.generate(300, (i) => i);
    var count = 0;
    for (var i = 0; i < 300; i++) {
      if (lookup.contains(i)) {
        count++;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('list.contains in loop')),
      body: Center(child: Text('Found: $count')),
    );
  }
}

/// xlints_avoid_repeated_datetime_now_in_loop
class _DateTimeNowInLoopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stamps = <DateTime>[];
    for (var i = 0; i < 5; i++) {
      stamps.add(DateTime.now());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('DateTime.now in loop')),
      body: Center(child: Text('Collected: ${stamps.length}')),
    );
  }
}

/// xlints_prefer_collection_if_spread_over_temp_lists
class _TempListAccumulationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final showHeader = true;
    final values = [1, 2, 3];
    final widgets = <Widget>[];
    if (showHeader) {
      widgets.add(const Text('Header'));
    }
    if (values.isNotEmpty) {
      widgets.addAll(values.map((e) => Text('Item $e')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Temp list accumulation')),
      body: Column(children: widgets),
    );
  }
}

/// xlints_prefer_string_buffer
class _StringConcatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var result = '';
    for (var i = 0; i < 100; i++) {
      result = result + 'x';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('String concat in loop')),
      body: Center(child: Text(result)),
    );
  }
}
