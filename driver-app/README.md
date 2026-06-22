# Driver App (Flutter)

Aplicativo de motorista com arquitetura limpa (camadas por feature) + Riverpod.

## Features implementadas

- Cadastro de motorista com documentos e dados do carro (`POST /drivers/register`)
- Tela de pendência de aprovação
- Login com OTP (Firebase Auth)
- Home com toggle Online/Offline (`PATCH /drivers/:id/online-status`)
- Escuta de solicitações por FCM quando online
- Card de corrida recebida com aceitar/recusar
- Aceite (`PATCH /rides/:id/accept`) e rejeição (`PATCH /rides/:id/reject`)
- Fluxo da corrida com mapa: indo ao embarque -> em viagem -> concluída (`PATCH /rides/:id/status`)
- Compartilhamento contínuo de localização no Firebase Realtime Database
- Histórico de corridas (`GET /rides/history`)
- Perfil/configurações

## Observações para rodar

1. Instale Flutter SDK no ambiente.
2. Rode `flutter pub get`.
3. Configure Firebase (`google-services.json` / `GoogleService-Info.plist`) e inicialização no app.
4. Defina `--dart-define=API_BASE_URL=http://SEU_BACKEND`.
5. Rode com `flutter run`.
