const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');

// Lê o nome do domínio da variável de ambiente
const DOMAIN = process.env.DOMAIN_NAME;
const app = express();

app.get('/status', (req, res) => {
  res.status(200).json({ message: `Aplicação rodando perfeitamente em HTTPS no domínio: ${DOMAIN}` });
});

// Verifica se a variável de ambiente do domínio foi definida
if (!DOMAIN) {
  console.error("ERRO: A variável de ambiente DOMAIN_NAME não está definida.");
  process.exit(1); // Encerra a aplicação se o domínio não for fornecido
}

const sslOptions = {
  key: fs.readFileSync(`/etc/letsencrypt/live/${DOMAIN}/privkey.pem`),
  cert: fs.readFileSync(`/etc/letsencrypt/live/${DOMAIN}/fullchain.pem`)
};

const httpsServer = https.createServer(sslOptions, app);
httpsServer.listen(8443, () => {
  console.log(`Servidor HTTPS rodando na porta 8443 para o domínio ${DOMAIN}`);
});

const httpServer = http.createServer((req, res) => {
  res.writeHead(301, { "Location": "https://" + req.headers['host'] + req.url });
  res.end();
});
httpServer.listen(3000, () => {
  console.log('Servidor HTTP (redirecionamento) rodando na porta 3000');
});