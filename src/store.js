const fs = require('fs');
const path = require('path');

const STORE_PATH = path.join(__dirname, '..', 'data', 'notified.json');

function load() {
  if (!fs.existsSync(STORE_PATH)) return {};
  return JSON.parse(fs.readFileSync(STORE_PATH, 'utf8'));
}

function save(data) {
  fs.mkdirSync(path.dirname(STORE_PATH), { recursive: true });
  fs.writeFileSync(STORE_PATH, JSON.stringify(data, null, 2));
}

function wasNotified(email) {
  const data = load();
  return Boolean(data[email]);
}

function markNotified(email, phoneNumber) {
  const data = load();
  data[email] = { phoneNumber, notifiedAt: new Date().toISOString() };
  save(data);
}

module.exports = { wasNotified, markNotified };
