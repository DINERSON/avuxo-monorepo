import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rides/data/ride_repository.dart';

final rideHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(rideRepositoryProvider).history();
});

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(
        title: const Text('Histórico de Corridas'),
        centerTitle: true,
      ),
      body: history.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma corrida encontrada.',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final ride = items[index];

              final rideId =
                  '${ride['rideId'] ?? ride['id'] ?? '-'}';

              final status =
                  '${ride['status'] ?? 'desconhecido'}';

              final distance =
                  '${ride['distance_km'] ?? ride['distance'] ?? 0}';

              final fare =
                  '${ride['fare'] ?? ride['price'] ?? 0}';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1117),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corrida #$rideId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $status',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distância: $distance km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ $fare',
                      style: const TextStyle(
                        color: avuxoGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (e, _) => Center(
          child: Text(
            'Erro: $e',
            style: const TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: avuxoGreen,
          ),
        ),
      ),
    );
  }
}