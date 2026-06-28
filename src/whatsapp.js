const path = require('path');
const pino = require('pino');
const qrcode = require('qrcode-terminal');
const {
  default: makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
} = require('@whiskeysockets/baileys');

const AUTH_DIR = path.join(__dirname, '..', 'data', 'auth');

let sock = null;

async function connect() {
  const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);

  sock = makeWASocket({
    auth: state,
    logger: pino({ level: 'silent' }),
  });

  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      console.log('Escaneie o QR code abaixo no WhatsApp (Aparelhos conectados):');
      qrcode.generate(qr, { small: true });
    }

    if (connection === 'open') {
      console.log('WhatsApp conectado.');
    }

    if (connection === 'close') {
      const shouldReconnect =
        lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
      console.log('Conexao com WhatsApp encerrada.', shouldReconnect ? 'Reconectando...' : 'Sessao deslogada.');
      if (shouldReconnect) {
        connect();
      }
    }
  });

  return sock;
}

function toJid(phoneNumber) {
  const digits = phoneNumber.replace(/\D/g, '');
  return `${digits}@s.whatsapp.net`;
}

async function isRegisteredOnWhatsApp(phoneNumber) {
  const jid = toJid(phoneNumber);
  const [result] = await sock.onWhatsApp(jid);
  return Boolean(result?.exists);
}

async function sendMessage(phoneNumber, text) {
  const jid = toJid(phoneNumber);
  await sock.sendMessage(jid, { text });
}

module.exports = { connect, isRegisteredOnWhatsApp, sendMessage };
