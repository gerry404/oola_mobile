import 'package:flutter/material.dart';

import '../../../domain/models/app_notification.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/notifications_viewmodel.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.viewModel});

  final NotificationsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => viewModel.markAllRead.execute(),
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.load]),
        builder: (context, _) {
          if (viewModel.load.running && viewModel.items.isEmpty) {
            return const LoadingIndicator();
          }
          if (viewModel.items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Aucune notification',
              subtitle: 'Vous serez prevenu ici des mises a jour.',
            );
          }
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => viewModel.load.execute(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _Tile(notif: viewModel.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.notif});
  final AppNotification notif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead
            ? Theme.of(context).colorScheme.surface
            : AppColors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: notif.isRead
                ? AppColors.grey1
                : AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.notifications,
              color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (notif.body != null) ...[
                const SizedBox(height: 2),
                Text(notif.body!,
                    style: const TextStyle(
                        color: AppColors.inkSoft, fontSize: 13)),
              ],
              if (notif.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(formatDateTimeFr(notif.createdAt!),
                    style: const TextStyle(
                        color: AppColors.grey3, fontSize: 11)),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}
