# Desafio Técnico – DevOps na Lacrei Saúde

Repositório contendo a solução para o desafio técnico de DevOps da Lacrei Saúde. Este projeto implementa um pipeline de CI/CD para o deploy automatizado de uma aplicação Node.js em um ambiente de staging na AWS.

## 🚀 Tecnologias Utilizadas

- **Aplicação:** Node.js com Express.js
- **Containerização:** Docker
- **Cloud:** AWS (EC2)
- **CI/CD:** GitHub Actions
- **Controle de Versão:** Git & GitHub

---

## ⚙️ 1. Setup do Ambiente de Staging

O ambiente de staging foi configurado na AWS utilizando o serviço EC2. O objetivo é ter um servidor dedicado para testes que simule o ambiente de produção.

As especificações da instância são:

- **Provedor Cloud:** AWS
- **Região:** `us-east-1` (Norte da Virgínia)
- **Serviço:** EC2 (Elastic Compute Cloud)
- **Nome da Instância:** `lacrei-staging-server`
- **AMI (Sistema Operacional):** Ubuntu Server 22.04 LTS
- **Tipo de Instância:** `t2.micro` (Qualificada para o nível gratuito)
- **Chave de Acesso:** `lacrei-devops-key.pem` foi gerada para garantir acesso administrativo seguro via SSH.
- **Security Group (Firewall):** Foi criado um grupo de segurança (`lacrei-webserver-sg`) com regras de entrada (`inbound rules`) para permitir tráfego nas seguintes portas:
  - **Porta 22 (SSH):** Para acesso administrativo remoto.
  - **Porta 80 (HTTP):** Para acesso web à aplicação.
  - **Porta 443 (HTTPS):** Reservada para a futura implementação de certificado SSL/TLS.

---

## 🔄 2. Fluxo de CI/CD

*(Descreveremos o pipeline aqui depois)*

---

## ⚠️ 3. Registro de Erros e Decisões Tomadas

*(Documentaremos os desafios que superamos aqui)*

---

## ⏪ 4. Processo de Rollback

*(Definiremos uma estratégia de rollback aqui)*

---

## 🛡️ 5. Checklist de Segurança Aplicado

*(Listaremos as medidas de segurança implementadas)*