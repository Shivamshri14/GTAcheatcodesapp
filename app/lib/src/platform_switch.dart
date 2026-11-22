import 'package:material_ui/material_ui.dart';

import 'models.dart';

class PlatformSwitch extends StatelessWidget {
  const PlatformSwitch({super.key, required this.value, required this.onChanged});
  final Platform value;
  final ValueChanged<Platform> onChanged;
  @override
  Widget build(BuildContext context) => SegmentedButton<Platform>(
        showSelectedIcon: false,
        segments: [
          for (final p in Platform.values) ButtonSegment(value: p, label: Text(p.label)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      );
}
