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

O pipeline de Integração e Entrega Contínua (CI/CD) foi implementado utilizando **GitHub Actions**. O objetivo é automatizar todo o processo, desde o envio do código até a implantação da aplicação no ambiente de staging.

O fluxo de trabalho está definido no arquivo `.github/workflows/deploy-staging.yml` e é executado da seguinte forma:

1.  **Gatilho (Trigger):** O pipeline é acionado automaticamente a cada `push` de código na branch `main` do repositório.

2.  **Inicialização do Ambiente:** O GitHub Actions provisiona uma máquina virtual temporária (runner) com `ubuntu-latest` para executar as etapas da automação.

3.  **Checkout do Código:** O código-fonte do projeto é baixado do repositório para a máquina virtual do runner.

4.  **Login no Docker Hub:** O pipeline se autentica de forma segura no Docker Hub, utilizando um `username` e um `token` de acesso armazenados como GitHub Secrets (`DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`).

5.  **Build e Push da Imagem:** A imagem Docker da aplicação é construída a partir do `Dockerfile`. Após o build, essa imagem é marcada com a tag `latest` e enviada (`push`) para o repositório no Docker Hub.

6.  **Deploy no Servidor EC2:** O passo final conecta-se via SSH ao servidor de staging na AWS, utilizando as credenciais armazenadas nos GitHub Secrets (`AWS_HOST`, `AWS_USERNAME`, `AWS_SSH_KEY`). No servidor, ele executa um script que realiza as seguintes ações:
    * Baixa a imagem mais recente do Docker Hub (`docker pull`).
    * Para o contêiner da versão antiga, caso esteja em execução (`docker stop`).
    * Remove o contêiner antigo (`docker rm`).
    * Inicia um novo contêiner com a imagem atualizada, mapeando a porta 80 (HTTP) do servidor para a porta 3000 da aplicação (`docker run`).

Este fluxo garante que qualquer atualização no código da branch `main` seja refletida no ambiente de staging em poucos minutos, sem qualquer intervenção manual.

---

## ⚠️ 3. Registro de Erros e Decisões Tomadas

*(Documentaremos os desafios que superamos aqui)*

---

## ⏪ 4. Processo de Rollback

*(Definiremos uma estratégia de rollback aqui)*

---

## 🛡️ 5. Checklist de Segurança Aplicado

*(Listaremos as medidas de segurança implementadas)*