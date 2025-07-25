const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');

const app = express();

// --- Rota da Aplicação ---
app.get('/status', (req, res) => {
  res.status(200).json({ message: 'Aplicação rodando perfeitamente em HTTPS!' });
});

// --- Configuração do Certificado SSL ---
// Os caminhos abaixo são como estarão DENTRO do contêiner Docker
const sslOptions = {
  key: fs.readFileSync('/etc/letsencrypt/live/saulo-devops-lacrei.duckdns.org/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/saulo-devops-lacrei.duckdns.org/fullchain.pem')
};

// --- Criação dos Servidores ---
// Servidor HTTPS na porta 8443
const httpsServer = https.createServer(sslOptions, app);
httpsServer.listen(8443, () => {
  console.log('Servidor HTTPS rodando na porta 8443');
});

// Servidor HTTP na porta 3000 para redirecionar para HTTPS
const httpServer = http.createServer((req, res) => {
  res.writeHead(301, { "Location": "https://" + req.headers['host'] + req.url });
  res.end();
});
httpServer.listen(3000, () => {
  console.log('Servidor HTTP (redirecionamento) rodando na porta 3000');
});