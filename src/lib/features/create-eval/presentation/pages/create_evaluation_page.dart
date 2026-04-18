import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state_management/create_evaluation_controller.dart';

class CreateEvaluationPage extends StatelessWidget {
  const CreateEvaluationPage({super.key});

  static const _bg = Color(0xFF15100E);
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CreateEvaluationController>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(courseName: c.course.name),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Evaluation Name'),
                    const SizedBox(height: 8),
                    _NameField(controller: c.nameController),
                    const SizedBox(height: 24),
                    const _SectionLabel('Select target group'),
                    const SizedBox(height: 8),
                    _GroupDropdown(ctrl: c),
                    const SizedBox(height: 24),
                    const _SectionLabel('Time window'),
                    const SizedBox(height: 8),
                    _TimeWindowRow(ctrl: c),
                    const SizedBox(height: 24),
                    const _SectionLabel('Visibility'),
                    const SizedBox(height: 12),
                    _VisibilitySelector(ctrl: c),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _CreateButton(ctrl: c),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String courseName;
  const _Header({required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF231816),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Evaluation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                courseName,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'e.g. Sprint 3 peer review',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF231816),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _GroupDropdown extends StatelessWidget {
  final CreateEvaluationController ctrl;
  const _GroupDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF231816),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.selectedGroup.value,
            hint: const Text(
              '',
              style: TextStyle(color: Color(0xFF5A5A5A)),
            ),
            isExpanded: true,
            dropdownColor: const Color(0xFF231816),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            items: ctrl.groupCategoryNames
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: ctrl.selectGroup,
          ),
        ),
      ),
    );
  }
}

class _TimeWindowRow extends StatelessWidget {
  final CreateEvaluationController ctrl;
  const _TimeWindowRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dt = ctrl.deadline.value;
      return Row(
        children: [
          _TimeButton(
            label: _formatDate(dt),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dt,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) =>
                    Theme(data: ThemeData.dark(), child: child!),
              );
              if (picked != null) {
                ctrl.setDeadline(DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  dt.hour,
                  dt.minute,
                ));
              }
            },
          ),
          const SizedBox(width: 12),
          _TimeButton(
            label: _formatTime(dt),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(dt),
                builder: (ctx, child) =>
                    Theme(data: ThemeData.dark(), child: child!),
              );
              if (picked != null) {
                final candidate = DateTime(
                  dt.year,
                  dt.month,
                  dt.day,
                  picked.hour,
                  picked.minute,
                );
                if (candidate.isBefore(DateTime.now())) {
                  Get.snackbar(
                    'Invalid time',
                    'The deadline cannot be in the past.',
                    backgroundColor: const Color(0xFF3A2016),
                    colorText: const Color(0xFFFF8C60),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  );
                } else {
                  ctrl.setDeadline(candidate);
                }
              }
            },
          ),
        ],
      );
    });
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDate(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF231816),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class _VisibilitySelector extends StatelessWidget {
  final CreateEvaluationController ctrl;
  const _VisibilitySelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _VisibilityCard(
              icon: Icons.public,
              label: 'Public',
              subtitle: 'Visible to group',
              selected: ctrl.visibility.value == 'public',
              onTap: () => ctrl.selectVisibility('public'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _VisibilityCard(
              icon: Icons.lock_outline,
              label: 'Private',
              subtitle: 'Only visible for me',
              selected: ctrl.visibility.value == 'private',
              onTap: () => ctrl.selectVisibility('private'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3A2016) : const Color(0xFF231816),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: const Color(0xFFFF8C60), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFFF8C60) : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFFF8C60) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final CreateEvaluationController ctrl;
  const _CreateButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: ctrl.isCreating.value ? null : ctrl.onCreateTapped,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A2016),
              foregroundColor: const Color(0xFFFF8C60),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF231816),
            ),
            child: ctrl.isCreating.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF8C60),
                    ),
                  )
                : const Text(
                    '+ Create evaluation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
