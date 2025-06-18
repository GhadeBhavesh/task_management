import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/task/task_provider.dart';
import '../../domain/model/task.dart';
import '../../application/auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Custom Header with Purple Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row with Menu and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.apps,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.filter_list,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // GestureDetector(
                            //   onTap:
                            //       () =>
                            //           ref.read(authProvider.notifier).signOut(),
                            //   child: Container(
                            //     padding: const EdgeInsets.all(8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.white.withOpacity(0.15),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: const Icon(
                            //       Icons.more_horiz,
                            //       color: Colors.white,
                            //       size: 20,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Search Bar
                    const SizedBox(height: 25),
                    // Date and Title
                    Text(
                      _getCurrentDateString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'My tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tasks List
          Expanded(
            child:
                tasks.isEmpty
                    ? const Center(
                      child: Text(
                        'No tasks yet. Add one!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                      children: _buildGroupedTasks(tasks, ref, context),
                    ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  List<Widget> _buildGroupedTasks(
    List<Task> tasks,
    WidgetRef ref,
    BuildContext context,
  ) {
    final Map<String, List<Task>> groupedTasks = {};

    for (final task in tasks) {
      final dateKey = _getDateKey(task.dueDate);
      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    final List<Widget> widgets = [];

    groupedTasks.forEach((dateKey, taskList) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 10),
          child: Text(
            dateKey,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
      );

      for (final task in taskList) {
        widgets.add(_buildTaskCard(task, ref, context));
      }

      widgets.add(const SizedBox(height: 15));
    });

    return widgets;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isAfter(today) &&
        taskDate.isBefore(today.add(const Duration(days: 7)))) {
      return 'This week';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildTaskCard(Task task, WidgetRef ref, BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          // color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Delete Task'),
                    content: const Text(
                      'Are you sure you want to delete this task?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap:
                  () => ref
                      .read(taskProvider.notifier)
                      .toggleTaskCompletion(task),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        task.isCompleted
                            ? _getPriorityColor(task.priority)
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                  color:
                      task.isCompleted
                          ? _getPriorityColor(task.priority)
                          : Colors.transparent,
                ),
                child:
                    task.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
              ),
            ),
            const SizedBox(width: 16),
            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          task.isCompleted
                              ? Colors.grey.shade400
                              : const Color(0xFF2D3748),
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            task.isCompleted
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Priority Badges
            Row(children: _buildPriorityTags(task.priority)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPriorityTags(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return [
          _buildPriorityTag('HIGH', const Color(0xFFFF6B6B)),
          const SizedBox(width: 6),
          _buildPriorityTag('HARD', const Color(0xFFFF6B6B)),
        ];
      case TaskPriority.medium:
        return [
          _buildPriorityTag('MED', const Color(0xFFFFB347)),
          const SizedBox(width: 6),
          _buildPriorityTag('TASK', const Color(0xFFFFB347)),
        ];
      case TaskPriority.low:
        return [_buildPriorityTag('LOW', const Color(0xFF51CF66))];
    }
  }

  Widget _buildPriorityTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFFF6B6B);
      case TaskPriority.medium:
        return const Color(0xFFFFB347);
      case TaskPriority.low:
        return const Color(0xFF51CF66);
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.low;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Add New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      TaskPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p.toString().split('.').last.toUpperCase(),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedPriority = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      selectedDate = date;
                    }
                  },
                  child: const Text('Select Due Date'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    ref
                        .read(taskProvider.notifier)
                        .addTask(
                          titleController.text,
                          descriptionController.text,
                          selectedDate,
                          selectedPriority,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context, WidgetRef ref) async {
    TaskPriority? selectedPriority;
    bool? selectedStatus;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Filter Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Priorities'),
                    ),
                    ...TaskPriority.values.map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.toString().split('.').last.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (value) => selectedPriority = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<bool>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: true, child: Text('Completed')),
                    DropdownMenuItem(value: false, child: Text('Pending')),
                  ],
                  onChanged: (value) => selectedStatus = value,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle:
                      selectedDate != null
                          ? Text(
                            '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}',
                          )
                          : const Text('Select Date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      selectedDate = date;
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(taskProvider.notifier).clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear Filters'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(taskProvider.notifier)
                      .setFilters(
                        priority: selectedPriority,
                        status: selectedStatus,
                        date: selectedDate,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }
}
