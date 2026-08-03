const os = require('os');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

function toDigits(phoneNumber) {
  return phoneNumber.replace(/\D/g, '');
}

function buildUri(phoneNumber, text) {
  const digits = toDigits(phoneNumber);
  const encoded = encodeURIComponent(text);
  return `whatsapp://send?phone=${digits}&text=${encoded}`;
}

async function sendMessageWindows(uri) {
  const ps1 = path.join(os.tmpdir(), `wa_${Date.now()}.ps1`);
  const script = [
    `Start-Process '${uri}'`,
    `Start-Sleep -Seconds 5`,
    `$ws = New-Object -ComObject WScript.Shell`,
    `if ($ws.AppActivate('WhatsApp')) {`,
    `  Start-Sleep -Milliseconds 800`,
    `  $ws.SendKeys('{ENTER}')`,
    `}`,
  ].join('\r\n');

  fs.writeFileSync(ps1, script, 'utf8');
  try {
    await execAsync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${ps1}"`);
  } finally {
    fs.unlinkSync(ps1);
  }
}

async function sendMessageMac(uri) {
  await execAsync(`open '${uri}'`);
  await new Promise((r) => setTimeout(r, 5000));
  await execAsync(`osascript -e 'tell application "System Events" to key code 36'`);
}

async function sendMessageLinux(uri) {
  await execAsync(`xdg-open '${uri}'`);
  await new Promise((r) => setTimeout(r, 5000));
  await execAsync(`xdotool key Return`);
}

async function sendMessage(phoneNumber, text) {
  const uri = buildUri(phoneNumber, text);
  const platform = process.platform;

  console.log(`Abrindo WhatsApp nativo para ${toDigits(phoneNumber)}...`);

  if (platform === 'win32') {
    await sendMessageWindows(uri);
  } else if (platform === 'darwin') {
    await sendMessageMac(uri);
  } else {
    await sendMessageLinux(uri);
  }

  console.log(`Mensagem enviada via WhatsApp nativo para ${toDigits(phoneNumber)}.`);
}

module.exports = { sendMessage };
