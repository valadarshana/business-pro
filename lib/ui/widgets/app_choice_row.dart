import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppChoiceRow<T> extends StatelessWidget {
  const AppChoiceRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        option == selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: option == selected
                            ? AppColors.primary
                            : AppColors.muted,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          labelBuilder(option),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
