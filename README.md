# API-whatssapp

Automacao que monitora uma caixa de e-mail e, ao chegar uma mensagem de um
contato conhecido, verifica se ele ja foi "chamado" (notificado) no WhatsApp.
Se ainda nao foi, envia uma mensagem de WhatsApp para o numero associado a
esse e-mail e registra a notificacao para nao enviar duplicado.

## Decisoes assumidas

Como o pedido original ("iniciar automacao do WhatsApp, entrou e-mail,
verificar se foi chamado no WhatsApp") nao especificou stack ou semantica
exata, foram adotadas as seguintes escolhas (ajustaveis conforme
necessidade):

- **WhatsApp**: [Baileys](https://github.com/WhiskeySockets/Baileys) — conecta
  via WhatsApp Web, sem custo e sem aprovacao da Meta. Para producao com
  numero oficial, considerar migrar para a Cloud API da Meta ou Twilio.
- **Deteccao de e-mail**: polling IMAP (`IMAP_POLL_INTERVAL_MS`), simples de
  configurar com qualquer provedor (Gmail, Outlook, etc.) sem depender de
  webhook externo.
- **"Verificar se foi chamado no WhatsApp"**: interpretado como "este
  remetente de e-mail ja recebeu uma notificacao via WhatsApp antes?". O
  estado fica em `data/notified.json`.
- **Mapeamento e-mail -> telefone**: arquivo `contacts.json` (nao versionado,
  veja `contacts.example.json`), pois nao ha como inferir o numero de
  WhatsApp de um remetente apenas pelo e-mail.

## Setup

1. `npm install`
2. Copie `.env.example` para `.env` e preencha as credenciais IMAP (para
   Gmail, use uma "senha de app").
3. Copie `contacts.example.json` para `contacts.json` e mapeie
   `email -> numero de telefone com DDI` (ex.: `5511999999999`).
4. `npm start`
5. Escaneie o QR code exibido no terminal com o WhatsApp (Aparelhos
   conectados > Conectar dispositivo).

A partir daí, novos e-mails nao lidos na caixa monitorada sao verificados; se
o remetente estiver em `contacts.json` e ainda nao tiver sido notificado, uma
mensagem de WhatsApp e enviada automaticamente.

## Estrutura

- `src/whatsapp.js` — conexao Baileys, envio de mensagem e verificacao de
  numero registrado no WhatsApp.
- `src/emailWatcher.js` — polling IMAP, emite evento `email` para cada
  mensagem nao lida.
- `src/store.js` — persistencia simples em JSON de quem ja foi notificado.
- `src/automation.js` — orquestra a regra: e-mail conhecido + ainda nao
  notificado + numero existe no WhatsApp => envia mensagem.
- `src/index.js` — ponto de entrada, conecta as pecas acima.
