import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/task/task_provider.dart';
import '../../domain/model/task.dart';

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
              color: Color.fromARGB(255, 136, 140, 244),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onTap: () => _showFilterDialog(context, ref),
                            child: const Icon(
                              Icons.filter_list,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Date and Title
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 36,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getCurrentDateString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'My tasks',
                              style: TextStyle(
                                color: Color(0xFF2D3748),
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                      children: _buildGroupedTasks(tasks, ref, context),
                    ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(top: 30),
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, ref),
          elevation: 0, // Remove elevation since we have custom shadow
          backgroundColor: const Color.fromARGB(255, 136, 140, 244),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFF8F9FA),
        height: 80,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left tab
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.format_list_bulleted,
                      color: Color.fromARGB(255, 136, 140, 244),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            // Right tab
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey.shade600,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    // Sort tasks by due date
    final sortedTasks = List<Task>.from(tasks)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final Map<String, List<Task>> groupedTasks = {};

    for (final task in sortedTasks) {
      final dateKey = _getDateKey(task.dueDate);
      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    // Sort the date keys
    final sortedKeys =
        groupedTasks.keys.toList()..sort((a, b) {
          if (a == 'Today') return -1;
          if (b == 'Today') return 1;
          if (a == 'Tomorrow') return -1;
          if (b == 'Tomorrow') return 1;
          if (a == 'This week') return -1;
          if (b == 'This week') return 1;
          return a.compareTo(b);
        });

    final List<Widget> widgets = [];

    for (final dateKey in sortedKeys) {
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

      for (final task in groupedTasks[dateKey]!) {
        widgets.add(_buildTaskCard(task, ref, context));
      }

      widgets.add(const SizedBox(height: 15));
    }

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

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
  }

  Widget _buildTaskCard(Task task, WidgetRef ref, BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
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
      child: GestureDetector(
        onTap: () => _showAddTaskDialog(context, ref, task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                              ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Task Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),

                        // const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  // Priority Badges
                  Row(children: _buildPriorityTags(task.priority)),
                ],
              ),
              // SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        task.isCompleted
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref, [
    Task? existingTask,
  ]) async {
    final titleController = TextEditingController(
      text: existingTask?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingTask?.description ?? '',
    );
    TaskPriority selectedPriority = existingTask?.priority ?? TaskPriority.low;
    DateTime selectedDate = existingTask?.dueDate ?? DateTime.now();

    // Create a state notifier for the selected date
    ValueNotifier<DateTime> dateNotifier = ValueNotifier(selectedDate);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(existingTask != null ? 'Edit Task' : 'Add New Task'),
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
                ValueListenableBuilder<DateTime>(
                  valueListenable: dateNotifier,
                  builder: (context, date, child) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (newDate != null) {
                                dateNotifier.value = newDate;
                                selectedDate = newDate;
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
                    if (existingTask != null) {
                      // Update existing task
                      final updatedTask = Task(
                        id: existingTask.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDate,
                        priority: selectedPriority,
                        isCompleted: existingTask.isCompleted,
                        userId: existingTask.userId,
                      );
                      ref.read(taskProvider.notifier).updateTask(updatedTask);
                    } else {
                      // Add new task
                      ref
                          .read(taskProvider.notifier)
                          .addTask(
                            titleController.text,
                            descriptionController.text,
                            selectedDate,
                            selectedPriority,
                          );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(existingTask != null ? 'Update' : 'Add'),
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
