import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/security/secure_screen.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../../security/biometric_gate.dart';
import '../application/vendor_providers.dart';
import '../domain/vendor_models.dart';

/// Portefeuille vendeur : solde, recharge, retraits, historique.
/// Ecran protege contre la capture (§3.2).
class VendorWalletTab extends ConsumerWidget {
  const VendorWalletTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorWalletProvider);

    return SecureScreen(
      child: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(vendorWalletProvider),
        data: (w) => RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async => ref.invalidate(vendorWalletProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCard(wallet: w),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _topup(context, ref),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Recharger'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _withdraw(context, ref, w.availableBalance),
                      icon: const Icon(Icons.account_balance_wallet_outlined,
                          size: 20),
                      label: const Text('Retirer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Historique',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (w.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Aucun mouvement pour le moment.',
                      style: TextStyle(color: AppColors.inkSoft)),
                )
              else
                ...w.transactions.map((t) => _TxTile(tx: t)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _topup(BuildContext context, WidgetRef ref) async {
    final amount = await _askAmount(context, 'Recharger le portefeuille');
    if (amount == null) return;
    try {
      final url = await ref.read(vendorRepositoryProvider).topup(amount);
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      ref.invalidate(vendorWalletProvider);
      if (context.mounted) {
        showToast(context, 'Recharge initiee', success: true);
      }
    } on ApiException catch (e) {
      if (context.mounted) showToast(context, e.message);
    }
  }

  Future<void> _withdraw(
      BuildContext context, WidgetRef ref, int available) async {
    // Operation sensible : verification biometrique.
    final ok = await ref
        .read(biometricGateProvider)
        .require(context, reason: 'Confirmez le retrait');
    if (!ok) return;
    if (!context.mounted) return;

    final amount = await _askAmount(context, 'Demander un retrait');
    if (amount == null) return;
    if (amount > available) {
      if (context.mounted) showToast(context, 'Solde insuffisant.');
      return;
    }
    try {
      await ref
          .read(vendorRepositoryProvider)
          .requestWithdrawal(amount, 'mobile_money');
      ref.invalidate(vendorWalletProvider);
      if (context.mounted) {
        showToast(context, 'Demande de retrait envoyee', success: true);
      }
    } on ApiException catch (e) {
      if (context.mounted) showToast(context, e.message);
    }
  }

  Future<int?> _askAmount(BuildContext context, String title) {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Montant (FCFA)',
            suffixText: 'FCFA',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final n = int.tryParse(controller.text.trim());
              Navigator.pop(context, n);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});
  final VendorWallet wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde disponible',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatCFA(wallet.availableBalance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
          if (wallet.pendingBalance > 0) ...[
            const SizedBox(height: 6),
            Text('En attente : ${formatCFA(wallet.pendingBalance)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final credit = tx.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: (credit ? AppColors.mint : AppColors.danger)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(credit ? Icons.south_west : Icons.north_east,
                size: 18, color: credit ? AppColors.mint : AppColors.danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description ?? (credit ? 'Credit' : 'Debit'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (tx.createdAt != null)
                  Text(formatDateFr(tx.createdAt!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft)),
              ],
            ),
          ),
          Text('${credit ? '+' : '-'}${formatCFA(tx.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: credit ? AppColors.mint : AppColors.danger)),
        ],
      ),
    );
  }
}
