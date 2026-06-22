import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {
  static const Color avuxoGreen =
      Color(0xFF24F877);

  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirm =
        await showDialog<bool>(
              context: context,
              builder: (_) {
                return AlertDialog(
                  backgroundColor:
                      const Color(0xFF141C25),
                  title: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  content: const Text(
                    'Deseja realmente sair?',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      child: const Text(
                        'Cancelar',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          color:
                              Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

    if (!confirm) return;

    try {
      setState(() {
        _loggingOut = true;
      });

      await ref
          .read(authRepositoryProvider)
          .logout();

      ref
          .read(
            authTokenProvider.notifier,
          )
          .state = null;

      if (!mounted) return;

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.redAccent,
            content: Text(
              'Erro ao sair da conta.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
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
        title: const Text(
          'Perfil',
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
            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF141C25),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: Colors.white
                      .withAlpha(10),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                        avuxoGreen,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 34,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Motorista',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Conta ativa',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            color:
                                avuxoGreen,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              decoration: BoxDecoration(
                color:
                    const Color(0xFF141C25),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: Colors.white
                      .withAlpha(10),
                ),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Encerrar sessão',
                  style: TextStyle(
                    color:
                        Colors.white54,
                  ),
                ),
                trailing: _loggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              avuxoGreen,
                        ),
                      )
                    : null,
                onTap: _loggingOut
                    ? null
                    : _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}