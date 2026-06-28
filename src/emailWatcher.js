const imaps = require('imap-simple');
const { simpleParser } = require('mailparser');
const { EventEmitter } = require('events');

class EmailWatcher extends EventEmitter {
  constructor(config) {
    super();
    this.config = config;
    this.seenUids = new Set();
    this.timer = null;
  }

  async start() {
    await this.poll();
    this.timer = setInterval(() => {
      this.poll().catch((err) => this.emit('error', err));
    }, this.config.pollIntervalMs);
  }

  stop() {
    if (this.timer) clearInterval(this.timer);
  }

  async poll() {
    const connection = await imaps.connect({
      imap: {
        host: this.config.host,
        port: this.config.port,
        user: this.config.user,
        password: this.config.password,
        tls: this.config.tls,
        authTimeout: 10000,
      },
    });

    try {
      await connection.openBox(this.config.mailbox);
      const results = await connection.search(['UNSEEN'], {
        bodies: [''],
        markSeen: true,
      });

      for (const item of results) {
        const uid = item.attributes.uid;
        if (this.seenUids.has(uid)) continue;
        this.seenUids.add(uid);

        const rawBody = item.parts.find((part) => part.which === '')?.body;
        if (!rawBody) continue;

        const parsed = await simpleParser(rawBody);
        this.emit('email', {
          from: parsed.from?.value?.[0]?.address || '',
          subject: parsed.subject || '',
          text: parsed.text || '',
        });
      }
    } finally {
      connection.end();
    }
  }
}

module.exports = { EmailWatcher };
