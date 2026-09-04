import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/vendor.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/secure_screen.dart';
import '../../core/ui/state_views.dart';
import '../view_models/vendor_wallet_viewmodel.dart';

class VendorWalletScreen extends StatefulWidget {
  const VendorWalletScreen({super.key, required this.viewModel});

  final VendorWalletViewModel viewModel;

  @override
  State<VendorWalletScreen> createState() => _VendorWalletScreenState();
}

class _VendorWalletScreenState extends State<VendorWalletScreen> {
  VendorWalletViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.topup.addListener(_onTopup);
    vm.withdraw.addListener(_onWithdraw);
  }

  @override
  void dispose() {
    vm.topup.removeListener(_onTopup);
    vm.withdraw.removeListener(_onWithdraw);
    super.dispose();
  }

  Future<void> _onTopup() async {
    if (vm.topup.completed) {
      final url = vm.lastTopupUrl;
      vm.topup.clearResult();
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      if (mounted) showAppSnack(context, 'Recharge initiee', success: true);
    } else if (vm.topup.error) {
      _err(vm.topup.result);
      vm.topup.clearResult();
    }
  }

  void _onWithdraw() {
    if (vm.withdraw.completed) {
      vm.withdraw.clearResult();
      showAppSnack(context, 'Demande de retrait envoyee', success: true);
    } else if (vm.withdraw.error) {
      _err(vm.withdraw.result);
      vm.withdraw.clearResult();
    }
  }

  void _err(Result? r) {
    if (r is Error) showAppSnack(context, describeError(r.error));
  }

  Future<void> _withdrawFlow(int available) async {
    final a = await _askAmount('Demander un retrait');
    if (a == null) return;
    if (a > available) {
      if (mounted) showAppSnack(context, 'Solde insuffisant.');
      return;
    }
    vm.withdraw.execute(a);
  }

  Future<int?> _askAmount(String title) {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Montant (FCFA)', suffixText: 'FCFA'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SecureScreen(
      child: ListenableBuilder(
        listenable: Listenable.merge([vm, vm.load]),
        builder: (context, _) {
          final w = vm.wallet;
          if (vm.load.running && w == null) return const LoadingIndicator();
          if (w == null) {
            final e = vm.load.result;
            return ErrorIndicator(
              message: e is Error ? describeError(e.error) : 'Erreur.',
              onRetry: () => vm.load.execute(),
            );
          }
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => vm.load.execute(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(wallet: w),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final a = await _askAmount('Recharger le portefeuille');
                        if (a != null) vm.topup.execute(a);
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Recharger'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _withdrawFlow(w.availableBalance),
                      icon: const Icon(Icons.account_balance_wallet_outlined,
                          size: 20),
                      label: const Text('Retirer'),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                const Text('Historique',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (w.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Aucun mouvement pour le moment.',
                        style: TextStyle(color: AppColors.inkSoft)),
                  )
                else
                  for (final t in w.transactions) _TxTile(tx: t),
              ],
            ),
          );
        },
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
          color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Row(children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              color: (credit ? AppColors.mint : AppColors.danger)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
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
      ]),
    );
  }
}
