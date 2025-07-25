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

Durante a configuração do ambiente e do pipeline, diversos desafios foram encontrados. A documentação a seguir detalha os principais problemas e as soluções aplicadas.

#### 1. Política de Execução do PowerShell
- **Problema:** Ao tentar verificar a versão do NPM com `npm -v`, o PowerShell bloqueou a execução do script, retornando um erro de política de segurança.
- **Solução:** A política de execução do PowerShell foi alterada para `RemoteSigned` através do comando `Set-ExecutionPolicy RemoteSigned`, executado em um terminal com privilégios de administrador. Esta decisão permitiu a execução de scripts locais necessários para o desenvolvimento, mantendo a segurança contra scripts não assinados da internet.

#### 2. `node_modules` no Controle de Versão
- **Problema:** Na primeira tentativa de versionamento, a pasta `node_modules` (contendo milhares de dependências) foi acidentalmente adicionada à área de preparação do Git.
- **Solução:** Foi criado um arquivo `.gitignore` na raiz do projeto para instruir o Git a ignorar a pasta `/node_modules`. Para corrigir a área de preparação, foi necessário usar o comando `git rm -rf --cached .` para limpar o cache do Git e depois um novo `git add .` para adicionar apenas os arquivos relevantes.

#### 3. Permissões da Chave SSH no Windows
- **Problema:** O cliente SSH se recusou a usar o arquivo `.pem` para conectar à instância EC2, retornando um erro de "permissões muito abertas" (`UNPROTECTED PRIVATE KEY FILE!`). Após uma tentativa de correção, o erro mudou para `Permission denied`.
- **Solução:** Foi necessário um ajuste fino nas permissões de segurança do arquivo `.pem` no Windows. Utilizando a interface de propriedades do arquivo, a herança de permissões foi desabilitada, e todas as entidades de segurança foram removidas, exceto o usuário atual, que recebeu permissão de "Controle total". Isso garantiu que apenas o proprietário do arquivo pudesse lê-lo, satisfazendo a exigência do SSH.

#### 4. Erro `Cannot GET /` Após o Deploy
- **Problema:** Após o primeiro deploy bem-sucedido, acessar o IP do servidor no navegador resultava na mensagem `Cannot GET /`.
- **Solução:** O diagnóstico revelou que não era um erro de deploy, mas sim de acesso à rota incorreta. A aplicação foi desenvolvida para responder apenas no endpoint `/status`. A solução foi acessar a URL completa (`http://<IP_DO_SERVIDOR>/status`), que validou o sucesso da implantação.

---

## ⏪ 4. Processo de Rollback

A estratégia de rollback adotada para este projeto utiliza a funcionalidade nativa do GitHub Actions para re-executar um workflow bem-sucedido anterior.

#### Passos para o Rollback Manual:

1.  **Identificar o Deploy Estável:** Navegue até a aba **`Actions`** do repositório no GitHub. Na lista de execuções de workflow, identifique a última execução que foi concluída com sucesso (com um check verde ✅) e que corresponde à versão estável que se deseja restaurar.

2.  **Re-executar o Workflow:** Clique nesta execução para ver seus detalhes. No canto superior direito da tela de detalhes, clique no botão **`Re-run all jobs`**.

3.  **Confirmação:** O GitHub Actions iniciará uma nova execução do pipeline, mas utilizando exatamente o mesmo código-fonte (o mesmo commit) daquela versão anterior estável.

4.  **Resultado:** Ao final da execução, o pipeline terá reconstruído a imagem Docker da versão antiga, a enviado para o Docker Hub com a tag `latest` e a implantado no servidor EC2. Isso efetivamente substitui a versão defeituosa pela última versão estável conhecida.

#### Proposta de Futura Melhoria (Rollback Avançado)

Uma abordagem mais rápida e robusta, ideal para ambientes de produção, seria aprimorar o pipeline para criar tags de imagem Docker versionadas (ex: usando a hash do commit Git, como `saulodemonte/desafio-lacrei-app:a1b2c3d`).

Com isso, o rollback seria quase instantâneo, executado diretamente no servidor via SSH, sem a necessidade de um novo build, seguindo os passos:

```bash
# 1. Conectar-se ao servidor EC2 via SSH

# 2. Parar e remover o contêiner atual
docker stop lacrei-container && docker rm lacrei-container

# 3. Iniciar o contêiner com a tag da versão estável anterior
docker run -d -p 80:3000 --name lacrei-container saulodemonte/desafio-lacrei-app:<hash_do_commit_estavel>

``` 
---

## 🛡️ 5. Checklist de Segurança Aplicado

As seguintes medidas de segurança foram implementadas neste projeto para garantir a integridade do ambiente e a proteção de dados sensíveis, conforme solicitado no desafio.

- **Gerenciamento de Segredos (Secrets Management):**
  - Todas as credenciais sensíveis — chaves de acesso da AWS, a chave SSH para o servidor EC2 e o token de acesso do Docker Hub — **não** foram escritas diretamente no código (`hardcoded`).
  - Em vez disso, foram armazenadas de forma segura como **GitHub Secrets** criptografados. O pipeline de CI/CD acessa essas credenciais apenas em tempo de execução, garantindo que elas não fiquem expostas no repositório de código.

- **Firewall de Rede (AWS Security Group):**
  - A instância EC2 está protegida por um *Security Group* que atua como um firewall virtual.
  - O acesso de rede foi configurado seguindo o **princípio do menor privilégio**, permitindo tráfego de entrada (`inbound`) apenas nas portas estritamente necessárias:
    - `Porta 22 (SSH)`: Para acesso administrativo remoto.
    - `Porta 80 (HTTP)`: Para acesso público à aplicação web.
    - `Porta 443 (HTTPS)`: Reservada para a futura implementação de tráfego seguro.

- **Autenticação Segura ao Servidor (SSH Key Pair):**
  - O acesso ao terminal do servidor EC2 não é feito por senha, mas sim por um **par de chaves criptográficas (SSH Key Pair)**.
  - A chave privada (`.pem`) é mantida em posse do desenvolvedor, garantindo que apenas entidades autorizadas possam acessar o servidor.

- **Próximos Passos de Segurança (Propostas):**
  - **HTTPS/TLS:** Implementar um certificado SSL/TLS (ex: via Let's Encrypt) para criptografar todo o tráfego entre o cliente e o servidor.
  - **Usuário IAM Dedicado:** Criar um usuário IAM na AWS com permissões mínimas e específicas para as necessidades do pipeline, em vez de usar chaves de um usuário com privilégios mais amplos.