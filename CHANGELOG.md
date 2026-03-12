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
