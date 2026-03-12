import 'package:analyzer/dart/ast/ast.dart';

/// Utility class for extracting and checking widget type information from AST nodes.
///
/// Used by lint rules to identify Flutter widget types in [InstanceCreationExpression]
/// nodes without requiring full Flutter SDK resolution.
class WidgetUtils {
  /// Extracts the type name from an [InstanceCreationExpression] node.
  ///
  /// Returns the simple type name (e.g., 'ListView', 'Opacity', 'SizedBox')
  /// from the constructor's type. Returns null if the type cannot be extracted.
  static String? getTypeName(InstanceCreationExpression node) {
    final type = node.constructorName.type;
    return type.name2.lexeme;
  }

  /// Checks whether the given type name matches any of the specified types.
  ///
  /// Returns true if [name] is non-null and present in [types].
  static bool isWidgetType(String? name, List<String> types) {
    if (name == null) return false;
    return types.contains(name);
  }

  /// List widget types that should use `.builder()` for lazy loading.
  ///
  /// Using [ListView] or [GridView] with a `children` list builds all items
  /// at once. Prefer `.builder()` for better performance.
  static const lazyListWidgets = ['ListView', 'GridView'];

  /// The [Opacity] widget type - triggers expensive saveLayer() calls.
  static const opacityWidget = 'Opacity';

  /// Scrollable widgets that support `shrinkWrap`.
  static const shrinkWrapWidgets = [
    'ListView',
    'GridView',
    'ReorderableListView',
  ];

  /// Intrinsic widgets that can be expensive in layout.
  static const intrinsicWidgets = ['IntrinsicHeight', 'IntrinsicWidth'];

  /// Controller/node types that should not be recreated in `build()`.
  static const controllerTypes = [
    'ScrollController',
    'PageController',
    'TextEditingController',
    'AnimationController',
    'TabController',
    'FocusNode',
  ];

  /// Widget types that commonly support const constructors.
  ///
  /// These widgets typically have no dynamic state and can be marked const
  /// to avoid unnecessary rebuilds.
  static const constCapableWidgets = [
    'SizedBox',
    'Padding',
    'Text',
    'Icon',
    'Divider',
    'Spacer',
    'ColoredBox',
  ];
}
