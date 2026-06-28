const store = require('./store');

async function handleNewEmail(email, whatsapp, contacts) {
  const phoneNumber = contacts[email.from];

  if (!phoneNumber) {
    console.log(`E-mail de ${email.from} recebido, mas nao ha contato de WhatsApp cadastrado. Ignorando.`);
    return;
  }

  if (store.wasNotified(email.from)) {
    console.log(`${email.from} ja foi chamado no WhatsApp anteriormente. Nada a fazer.`);
    return;
  }

  const exists = await whatsapp.isRegisteredOnWhatsApp(phoneNumber);
  if (!exists) {
    console.log(`Numero ${phoneNumber} (${email.from}) nao esta registrado no WhatsApp.`);
    return;
  }

  await whatsapp.sendMessage(
    phoneNumber,
    `Ola! Recebemos seu e-mail "${email.subject}". Em breve daremos retorno por aqui no WhatsApp.`
  );
  store.markNotified(email.from, phoneNumber);
  console.log(`${email.from} chamado no WhatsApp (${phoneNumber}) com sucesso.`);
}

module.exports = { handleNewEmail };
