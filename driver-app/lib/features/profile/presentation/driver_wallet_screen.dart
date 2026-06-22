import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() =>
      _DriverWalletScreenState();
}

class _DriverWalletScreenState
    extends State<DriverWalletScreen> {
  static const Color avuxoGreen =
      Color(0xFF24F877);

  static const double feePerRide = 0.50;
  static const double blockLimit = 20.00;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'https://avuxo-backend-production.up.railway.app',
      connectTimeout:
          const Duration(seconds: 12),
      receiveTimeout:
          const Duration(seconds: 12),
      validateStatus: (status) =>
          status != null && status < 500,
    ),
  );

  bool loading = true;
  bool _loadingWallet = false;

  String? error;

  String driverId = '';

  double balance = 0;
  double totalFees = 0;

  List<Map<String, dynamic>>
      transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  @override
  void dispose() {
    dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadWallet() async {
    if (_loadingWallet) return;

    _loadingWallet = true;

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final phone =
          await LocalStorage().getPhone();

      if (!mounted) return;

      if (phone == null ||
          phone.trim().isEmpty) {
        setState(() {
          error =
              'Telefone do motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final normalizedPhone =
          phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final profileResponse =
          await dio.get(
        '/drivers/status/$normalizedPhone',
      );

      if (!mounted) return;

      final profileData =
          profileResponse.data;

      if (profileData is! Map ||
          profileData['found'] != true ||
          profileData['driver'] is! Map) {
        setState(() {
          error =
              'Motorista não encontrado.';
          loading = false;
        });
        return;
      }
      final driverData =
          Map<String, dynamic>.from(
        profileData['driver'],
      );

      final id =
          '${driverData['id'] ?? ''}'.trim();

      if (id.isEmpty) {
        setState(() {
          error =
              'ID do motorista não veio do backend.';
          loading = false;
        });
        return;
      }

      final response = await dio.get(
        '/driver/wallet/$id',
      );

      if (!mounted) return;

      final data = response.data;

      if (data is! Map ||
          data['success'] != true ||
          data['wallet'] is! Map) {
        setState(() {
          error =
              'Não foi possível carregar a carteira.';
          loading = false;
        });
        return;
      }

      final wallet =
          Map<String, dynamic>.from(
        data['wallet'],
      );

      final rawTransactions =
          wallet['transactions'];

      final parsedTransactions =
          rawTransactions is List
              ? rawTransactions
                  .whereType<Map>()
                  .map(
                    (item) =>
                        Map<String, dynamic>.from(
                      item,
                    ),
                  )
                  .toList(growable: false)
              : <Map<String, dynamic>>[];

      setState(() {
        driverId = id;
        balance = _toDouble(
          wallet['balance'],
        );
        totalFees = _toDouble(
          wallet['totalFees'],
        );
        transactions =
            parsedTransactions;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error =
            'Erro de conexão com o backend.';
        loading = false;
      });
    } finally {
      _loadingWallet = false;
    }
  }

  double _toDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    final parsed = double.tryParse(
      '$value'.replaceAll(',', '.'),
    );

    if (parsed == null ||
        !parsed.isFinite) {
      return fallback;
    }

    return parsed;
  }

  String _money(double value) {
    final sign = value < 0 ? '-' : '';
    final absValue = value.abs();

    return '${sign}R\$ ${absValue.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _date(dynamic value) {
    final raw = '${value ?? ''}'.trim();

    if (raw.isEmpty) {
      return 'Data não informada';
    }

    final parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return raw;
    }

    final local = parsed.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} às '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _safeText(
    dynamic value, {
    String fallback = 'Não informado',
  }) {
    final text = '${value ?? ''}'.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  int get totalRidesCharged {
    return transactions
        .where(
          (item) =>
              '${item['type']}' == 'ride_fee',
        )
        .length;
  }

  double get debt {
    return balance < 0 ? balance.abs() : 0;
  }

  double get remainingUntilBlock {
    final remaining = blockLimit - debt;

    return remaining < 0 ? 0 : remaining;
  }

  bool get closeToBlock {
    return debt >= 15 && debt < blockLimit;
  }

  bool get shouldBlock {
    return debt >= blockLimit;
  }
  void _showPaymentInfo() {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141C25),
          title: const Text(
            'Pagamento AVUXO',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const SelectableText(
            'financeiro@avuxo.com.br',
            style: TextStyle(
              color: Color(0xFF24F877),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: avuxoGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Carteira AVUXO',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading || _loadingWallet
                ? null
                : _loadWallet,
            icon: const Icon(
              Icons.refresh,
              color: avuxoGreen,
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: avuxoGreen,
          strokeWidth: 2.8,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        color: avuxoGreen,
        backgroundColor: const Color(0xFF141C25),
        onRefresh: _loadWallet,
        child: RepaintBoundary(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _mainBalanceCard(),
                const SizedBox(height: 16),
                if (shouldBlock)
                  _alertCard(
                    title: 'Limite atingido',
                    message:
                        'Seu saldo devedor chegou ao limite de ${_money(blockLimit)}. Regularize para evitar bloqueio.',
                    color: Colors.redAccent,
                  ),
                if (closeToBlock)
                  _alertCard(
                    title: 'Atenção',
                    message:
                        'Faltam ${_money(remainingUntilBlock)} para atingir o limite de bloqueio.',
                    color: Colors.orangeAccent,
                  ),
                _card(
                  Icons.route_rounded,
                  'Corridas cobradas',
                  '$totalRidesCharged',
                ),
                _card(
                  Icons.price_check_rounded,
                  'Taxa por corrida',
                  _money(feePerRide),
                ),
                _card(
                  Icons.receipt_long_rounded,
                  'Total em taxas',
                  _money(totalFees),
                ),
                _card(
                  Icons.warning_amber_rounded,
                  'Limite de bloqueio',
                  _money(blockLimit),
                ),
                const SizedBox(height: 18),
                _paymentButton(),
                const SizedBox(height: 24),
                _transactionsTitle(),
                const SizedBox(height: 12),
                _transactionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _mainBalanceCard() {
    final hasDebt = debt > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hasDebt
            ? const Color(0xFF141C25)
            : avuxoGreen,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasDebt
              ? Colors.redAccent.withAlpha(90)
              : avuxoGreen,
        ),
        boxShadow: [
          BoxShadow(
            color: hasDebt
                ? Colors.redAccent.withAlpha(45)
                : avuxoGreen.withAlpha(45),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            hasDebt
                ? 'SALDO DEVEDOR'
                : 'SALDO DA CARTEIRA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasDebt
                  ? Colors.white70
                  : Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasDebt ? _money(debt) : _money(balance),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasDebt
                  ? Colors.redAccent
                  : Colors.black,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasDebt
                ? 'Taxas acumuladas por corrida finalizada'
                : 'Nenhuma dívida em aberto',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasDebt
                  ? Colors.white60
                  : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard({
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(90),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _safeText(title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _safeText(message),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _showPaymentInfo,
        icon: const Icon(
          Icons.pix_rounded,
          color: Colors.black,
        ),
        label: const Text(
          'PAGAR TAXAS VIA PIX',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: avuxoGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _transactionsTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Extrato',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$totalRidesCharged cobranças',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _transactionsList() {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141C25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withAlpha(10),
          ),
        ),
        child: const Text(
          'Nenhuma cobrança registrada ainda.',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      children: transactions
          .map(_transactionTile)
          .toList(growable: false),
    );
  }

  Widget _transactionTile(
    Map<String, dynamic> item,
  ) {
    final amount = _toDouble(item['amount']);

    final title = _safeText(
      item['title'],
      fallback: 'Taxa AVUXO por corrida',
    );

    final date = _date(
      item['createdAt'],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withAlpha(10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.remove_circle_rounded,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141C25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withAlpha(10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: avuxoGreen,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _safeText(title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _safeText(value),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}