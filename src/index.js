require('dotenv').config();
const fs = require('fs');
const path = require('path');

const whatsapp = require('./whatsapp');
const { EmailWatcher } = require('./emailWatcher');
const { handleNewEmail } = require('./automation');

function loadContacts() {
  const customPath = path.join(__dirname, '..', 'contacts.json');
  const examplePath = path.join(__dirname, '..', 'contacts.example.json');
  const contactsPath = fs.existsSync(customPath) ? customPath : examplePath;
  return JSON.parse(fs.readFileSync(contactsPath, 'utf8'));
}

async function main() {
  console.log('Iniciando automacao do WhatsApp (modo nativo)...');

  const contacts = loadContacts();

  const watcher = new EmailWatcher({
    host: process.env.IMAP_HOST,
    port: Number(process.env.IMAP_PORT || 993),
    user: process.env.IMAP_USER,
    password: process.env.IMAP_PASSWORD,
    tls: process.env.IMAP_TLS !== 'false',
    mailbox: process.env.IMAP_MAILBOX || 'INBOX',
    pollIntervalMs: Number(process.env.EMAIL_POLL_INTERVAL_MS || 30000),
  });

  watcher.on('email', (email) => {
    console.log(`Novo e-mail de ${email.from}: ${email.subject}`);
    handleNewEmail(email, whatsapp, contacts).catch((err) =>
      console.error('Erro ao processar e-mail:', err)
    );
  });

  watcher.on('error', (err) => console.error('Erro no watcher de e-mail:', err));

  await watcher.start();
  console.log('Monitorando caixa de e-mail. Aguardando novas mensagens...');
}

main().catch((err) => {
  console.error('Falha ao iniciar automacao:', err);
  process.exit(1);
});
