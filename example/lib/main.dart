// ignore_for_file: avoid_print
//
// This example intentionally contains bad patterns that trigger xlints rules.
// Run `dart run custom_lint` or `flutter pub run custom_lint` to see the reports.
//

import 'package:flutter/material.dart';

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
    // xlints_avoid_listview_with_children / xlints_prefer_listview_builder
    return ListView(
      children: [
        _buildTile(
          context,
          'Widget without const',
          _WidgetWithoutConstScreen(),
        ),
        _buildTile(
          context,
          'ListView with children',
          _ListViewWithChildrenScreen(),
        ),
        _buildTile(context, 'Opacity widget', _OpacityWidgetScreen()),
        _buildTile(
          context,
          'Padding wrapping margin',
          _PaddingWrappingMarginScreen(),
        ),
        _buildTile(
          context,
          'Widget operator ==',
          _WidgetOperatorEqualsScreen(),
        ),
        _buildTile(context, 'shrinkWrap true', _ShrinkWrapScreen()),
        _buildTile(context, 'Intrinsic widget', _IntrinsicWidgetScreen()),
        _buildTile(context, 'Controller in build', _ControllerInBuildScreen()),
        _buildTile(context, 'setState in build', _SetStateInBuildScreen()),
        _buildTile(context, 'String concat in loop', _StringConcatScreen()),
      ],
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

/// xlints_avoid_listview_with_children / xlints_prefer_listview_builder
class _ListViewWithChildrenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView with children')),
      body: ListView(
        children: List.generate(100, (i) => ListTile(title: Text('Item $i'))),
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
