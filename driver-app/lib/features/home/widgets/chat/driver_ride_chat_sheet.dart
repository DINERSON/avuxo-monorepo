import 'package:flutter/material.dart';

class DriverRideChatSheet extends StatefulWidget {
  const DriverRideChatSheet({
    super.key,
    required this.messages,
    required this.onSend,
  });

  final List<Map<String, dynamic>> messages;
  final void Function(String text) onSend;

  @override
  State<DriverRideChatSheet> createState() => _DriverRideChatSheetState();
}

class _DriverRideChatSheetState extends State<DriverRideChatSheet> {
  static const Color avuxoGreen = Color(0xFF24F877);

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(covariant DriverRideChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool _isDriver(Map<String, dynamic> msg) {
    final sender = '${msg['sender'] ?? msg['from'] ?? msg['role'] ?? ''}';
    return sender == 'driver';
  }

  String _message(Map<String, dynamic> msg) {
    return '${msg['message'] ?? msg['text'] ?? ''}';
  }

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();
    widget.onSend(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!mounted) return;
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.40,
      maxChildSize: 0.95,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1117),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Chat da Corrida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: widget.messages.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma mensagem.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.messages.length,
                        itemBuilder: (_, index) {
                          final msg = widget.messages[index];
                          final mine = _isDriver(msg);

                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.72,
                              ),
                              decoration: BoxDecoration(
                                color: mine ? avuxoGreen : Colors.white10,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                _message(msg),
                                style: TextStyle(
                                  color: mine ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Digite sua mensagem...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: avuxoGreen,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}