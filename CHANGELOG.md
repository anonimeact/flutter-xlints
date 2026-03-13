## 1.0.5

- Refined `xlints_prefer_const_constructors` for `Text` so it no longer suggests `const` when the main text argument is not a simple string literal (e.g. interpolated values like `"+$value"`), reducing false positives.

## 1.0.4

- Fixed Platform support by excluding `example/` from publish via `.pubignore`, so pana only analyzes the main package and no analyzer plugin runs on the nested example.
- README: added "Using xlints with flutter_lints" with before/after `analysis_options.yaml` examples.
- README: clarified that the example lives in the GitHub repo and is not published to pub.dev.

## 1.0.3

- Fixed pana/pub.dev analyzer plugin failures during static analysis and downgrade checks.
- Removed `lib/analysis_options.yaml` to avoid analyzer scanning conflicts in package subdirectories.
- Standardized configuration usage to `package:xlints/analysis_options_xlints.yaml`.
- Updated `README.md` and `example/README.md` to match the new configuration path.
- Updated `example/analysis_options.yaml` to use `analysis_options_xlints.yaml`.
- Removed unused `lints` dev dependency.
- Formatted source files to satisfy static analysis formatting checks.

## 1.0.2

- Added new logic/performance rules:
  - `xlints_avoid_json_decode_in_build`
  - `xlints_avoid_heavy_sync_work_in_build`
  - `xlints_prefer_final_locals`
  - `xlints_avoid_recreating_regexp`
  - `xlints_avoid_list_contains_in_large_loops`
  - `xlints_avoid_repeated_datetime_now_in_loop`
  - `xlints_prefer_collection_if_spread_over_temp_lists`
- Improved existing widget rules to reduce false positives and improve detection quality.
- Updated custom_lint diagnostics API usage for better analyzer/plugin compatibility.
- Added full platform support metadata in `pubspec.yaml`.
- Improved package-level analysis setup to avoid plugin self-analysis issues during publish checks.
- Expanded and aligned `example/` app to demonstrate lint violations more clearly.
- Reworked `README.md` and `example/README.md` in English with detailed installation and usage guidance.

## 1.0.1

- Compliting documentation.

## 1.0.0

- Initial version.
