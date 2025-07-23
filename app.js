const express = require('express');
const app = express();
const port = 3000;

app.get('/status', (req, res) => {
  res.status(200).json({ message: 'Aplicação rodando perfeitamente!' });
});

app.listen(port, () => {
  console.log(`Aplicação de exemplo rodando na porta ${port}`);
});