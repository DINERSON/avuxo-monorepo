import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  static const Color avuxoGreen =
      Color(0xFF24F877);

  Future<void> _openUrl(
    BuildContext context,
    String url,
  ) async {
    try {
      final safeUrl = url.trim();

      if (safeUrl.isEmpty) {
        throw Exception();
      }

      final uri = Uri.parse(
        safeUrl,
      );

      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              backgroundColor:
                  Colors.redAccent,
              content: Text(
                'Não foi possível abrir o link.',
              ),
            ),
          );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.redAccent,
            content: Text(
              'Link inválido.',
            ),
          ),
        );
    }
  }

  void _soon(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          backgroundColor:
              Color(0xFF141C25),
          content: Text(
            'Essa opção será liberada na próxima etapa.',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      );
  }

  String _safeText(
    String value,
    String fallback,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Ajuda',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body: RepaintBoundary(
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            _item(
              context,
              Icons.support_agent_rounded,
              'Falar com suporte',
              'Atendimento AVUXO pelo WhatsApp',
              () => _openUrl(
                context,
                'https://wa.me/5569999999999?text=Olá,%20preciso%20de%20ajuda%20no%20AVUXO%20Motorista',
              ),
            ),

            _item(
              context,
              Icons.help_outline_rounded,
              'Perguntas frequentes',
              'Dúvidas sobre corridas, pagamentos e conta',
              () => _soon(context),
            ),

            _item(
              context,
              Icons.local_taxi_rounded,
              'Problemas com corrida',
              'Passageiro, rota, cancelamento ou pagamento',
              () => _soon(context),
            ),

            _item(
              context,
              Icons.payments_rounded,
              'Pagamentos e carteira',
              'Saque, taxa AVUXO e extrato',
              () => _soon(context),
            ),            _item(
              context,
              Icons.description_rounded,
              'Termos de uso',
              'Regras para motoristas AVUXO',
              () => _openUrl(
                context,
                'https://avuxo.com/termos',
              ),
            ),

            _item(
              context,
              Icons.privacy_tip_rounded,
              'Política de privacidade',
              'Como seus dados são protegidos',
              () => _openUrl(
                context,
                'https://avuxo.com/privacidade',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final safeTitle = _safeText(
      title,
      'Ajuda',
    );

    final safeSubtitle = _safeText(
      subtitle,
      'Opção de suporte AVUXO.',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141C25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha(10),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: avuxoGreen,
              size: 28,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    safeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    safeSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}