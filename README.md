# Desafio Técnico – DevOps na Lacrei Saúde

Repositório contendo a solução para o desafio técnico de DevOps da Lacrei Saúde. Este projeto implementa pipelines de CI/CD para o deploy automatizado de uma aplicação Node.js em ambientes de **Staging** e **Produção** na AWS, utilizando as melhores práticas de segurança e automação.

> 📄 **Nota do Desenvolvedor:** Para um passo a passo detalhado de toda a jornada de construção deste projeto, incluindo cada comando, desafio e decisão técnica, por favor, veja o documento **[Jornada do Projeto](JORNADA_DO_PROJETO.md)**.

## 🚀 Tecnologias Utilizadas

- **Aplicação:** Node.js com Express.js
- **Containerização:** Docker
- **Cloud:** AWS (EC2, IAM, CloudWatch, SNS)
- **Registro de Contêiner:** GitHub Container Registry (GHCR)
- **CI/CD:** GitHub Actions
- **Controle de Versão:** Git & GitHub

---

## ⚙️ 1. Setup dos Ambientes (Staging e Produção)

Foram configurados dois ambientes independentes na AWS utilizando o serviço EC2 para garantir o isolamento entre testes e produção.

As especificações para **ambas** as instâncias (`lacrei-staging-server` e `lacrei-production-server`) são:

- **Provedor Cloud:** AWS
- **Região:** `us-east-1` (Norte da Virgínia)
- **Serviço:** EC2 (Elastic Compute Cloud)
- **AMI (Sistema Operacional):** Ubuntu Server 22.04 LTS
- **Tipo de Instância:** `t2.micro` (Qualificada para o Nível Gratuito)
- **Chave de Acesso:** `lacrei-devops-key.pem` foi gerada e é reutilizada para acesso seguro via SSH a ambos os servidores.
- **Security Group (Firewall):** Um único grupo de segurança (`lacrei-webserver-sg`) é aplicado a ambas as instâncias, com regras para permitir tráfego nas portas:
  - **Porta 22 (SSH):** Para acesso administrativo remoto.
  - **Porta 80 (HTTP):** Para o redirecionamento automático para HTTPS.
  - **Porta 443 (HTTPS):** Para acesso seguro à aplicação.

---

## 🔄 2. Fluxo de CI/CD

O projeto utiliza dois pipelines de CI/CD distintos com **GitHub Actions**, um para cada ambiente. A grande melhoria implementada foi a migração do Docker Hub para o **GitHub Container Registry (GHCR)**, tornando a autenticação mais simples e segura.

### Pipeline de Staging (`deploy-staging.yml`)
1.  **Gatilho (Trigger):** Acionado automaticamente a cada `push` na branch `main`.
2.  **Autenticação:** O pipeline faz login no GHCR usando um `GITHUB_TOKEN` automático e seguro.
3.  **Build & Push:** A imagem Docker é construída e enviada para o GHCR com a tag `latest`.
4.  **Deploy:** O pipeline conecta-se ao servidor de **staging** via SSH e executa um script que baixa a nova imagem e reinicia o contêiner com as configurações de HTTPS e logging.
5.  **Teste:** Um "smoke test" é executado com `curl` para validar que a aplicação está no ar e respondendo corretamente.

### Pipeline de Produção (`deploy-production.yml`)
1.  **Gatilho (Trigger):** Acionado **manualmente** através da criação de uma `tag` de versão no Git (ex: `v1.0.0`).
2.  **Autenticação:** O processo é idêntico ao de staging.
3.  **Build & Push:** A imagem Docker é construída e enviada para o GHCR com uma tag de versão explícita, baseada na tag do Git (ex: `v1.0.0`), permitindo rastreabilidade.
4.  **Deploy:** O pipeline conecta-se ao servidor de **produção** e executa o mesmo processo de deploy.
5.  **Teste:** Um "smoke test" similar ao de staging valida o sucesso da implantação.

---

## ⚠️ 3. Registro de Erros e Decisões Tomadas

Durante o projeto, diversos desafios foram encontrados. A documentação a seguir detalha os problemas e as soluções aplicadas.

#### 1. Política de Execução do PowerShell
- **Problema:** O PowerShell bloqueou a execução de scripts `npm`, impedindo a verificação da instalação.
- **Solução:** A política de execução foi alterada para `RemoteSigned` com privilégios de administrador.

#### 2. `node_modules` no Controle de Versão
- **Problema:** A pasta `node_modules` foi acidentalmente adicionada à área de preparação do Git.
- **Solução:** Foi criado um arquivo `.gitignore` para ignorar a pasta, e o cache do Git foi limpo com `git rm -rf --cached .` antes de um novo `add`.

#### 3. Permissões da Chave SSH no Windows
- **Problema:** O cliente SSH retornou erros de "permissões muito abertas" (`UNPROTECTED PRIVATE KEY FILE!`) no arquivo `.pem`.
- **Solução:** As permissões do arquivo no Windows foram ajustadas para permitir acesso apenas ao usuário proprietário do arquivo.

#### 4. Erro de Conexão no Deploy (`i/o timeout`)
- **Problema:** O pipeline começou a falhar na etapa de deploy via SSH após a criação de um IP Fixo (Elástico).
- **Solução:** O diagnóstico revelou que o segredo `AWS_HOST` no GitHub ainda continha o IP antigo. A solução foi atualizar o segredo com o novo IP Fixo.

#### 5. Erro Persistente de Autenticação no Docker Hub (`insufficient_scope`)
- **Problema:** O pipeline de produção falhava consistentemente ao tentar enviar a imagem para o Docker Hub, mesmo com um token de acesso com permissões corretas. O pipeline de staging, no entanto, funcionava.
- **Decisão Estratégica:** Após esgotar as tentativas de debug, foi tomada a decisão de **migrar do Docker Hub para o GitHub Container Registry (GHCR)**. Esta solução alternativa se provou mais robusta, segura e integrada, resolvendo o problema de autenticação definitivamente ao usar o `GITHUB_TOKEN` nativo.

---

## ⏪ 4. Processo de Rollback

A estratégia de rollback utiliza a funcionalidade nativa do GitHub Actions para reverter uma versão.

#### Passos para o Rollback Manual:
1.  **Identificar o Deploy Estável:** Na aba **`Actions`**, encontrar a execução do workflow bem-sucedida que corresponde à versão estável.
2.  **Re-executar o Workflow:** Clicar no botão **`Re-run all jobs`** para iniciar uma nova execução usando o mesmo código-fonte (commit) da versão anterior.
3.  **Resultado:** O pipeline irá reconstruir a imagem da versão antiga, enviá-la ao GHCR e implantá-la no servidor, substituindo a versão com bug.

#### Proposta de Futura Melhoria (Rollback Avançado)
Como agora usamos tags de versão explícitas no GHCR (ex: `ghcr.io/...:v1.0.1`), o rollback pode ser feito de forma quase instantânea, conectando-se ao servidor via SSH e reiniciando o contêiner com a tag da versão estável anterior.

---

## 🛡️ 5. Checklist de Segurança Aplicado

- **Gerenciamento de Segredos:** Todas as credenciais (AWS, chave SSH) são gerenciadas de forma segura com **GitHub Secrets**. A autenticação com o GHCR utiliza o `GITHUB_TOKEN` automático, eliminando a necessidade de tokens manuais.
- **Firewall de Rede (AWS Security Group):** As instâncias EC2 estão protegidas por um firewall que permite tráfego apenas nas portas `22` (SSH), `80` (HTTP) e `443` (HTTPS).
- **Autenticação Segura ao Servidor:** O acesso é feito exclusivamente por chaves criptográficas (SSH Key Pair).
- **Conexão Criptografada (HTTPS/TLS):** A comunicação com a aplicação é criptografada com certificados SSL/TLS da Let's Encrypt em ambos os ambientes.

---

## 👁️ 6. Observabilidade (Logs e Monitoramento)

### Logging Centralizado com CloudWatch
Os logs da aplicação são transmitidos em tempo real para o **AWS CloudWatch Logs**, garantindo persistência e acesso centralizado para análise e debug. Isso foi configurado via driver `awslogs` do Docker.

### Monitoramento e Alertas Proativos (Bônus)
Foi implementado um sistema de alertas com **AWS CloudWatch Alarms** e **AWS SNS**. Um alarme monitora o uso de CPU da instância e envia uma notificação por email caso ultrapasse 70% por 5 minutos, permitindo uma ação proativa.

---

## 💰 Bônus: Proposta de Integração com Asaas

Esta seção descreve a arquitetura proposta para integrar a aplicação com o sistema de pagamentos Asaas, incluindo a criação de cobranças via API e a confirmação via Webhooks. A chave de API seria gerenciada de forma segura via GitHub Secrets.

---

## 🧹 7. Procedimento de Limpeza (Cleanup)

Para garantir a otimização de custos e a segurança após o período de avaliação deste desafio, todos os recursos provisionados na AWS devem ser removidos (descomissionados). O procedimento a seguir detalha a ordem correta para a limpeza completa do ambiente.

**Ordem de Remoção:**

1.  **Terminar as Instâncias EC2:**
    - Navegar até o painel do EC2.
    - Selecionar as instâncias `lacrei-staging-server` e `lacrei-production-server`.
    - Clicar em `Instance state` > `Terminate instance`. A ação "Terminate" apaga permanentemente as máquinas virtuais e seus discos de armazenamento.

2.  **Liberar os Endereços IP Elásticos:**
    - No painel do EC2, ir para a seção `Elastic IPs`.
    - Selecionar os dois IPs Fixos que foram alocados.
    - Clicar em `Actions` > `Release Elastic IP addresses`. Este passo só pode ser feito após as instâncias que os utilizam serem terminadas.

3.  **Excluir o Par de Chaves (Key Pair):**
    - No painel do EC2, ir para a seção `Key Pairs`.
    - Selecionar a chave `lacrei-devops-key` e excluí-la.

4.  **Excluir o Grupo de Segurança (Security Group):**
    - No painel do EC2, ir para a seção `Security Groups`.
    - Selecionar o grupo `lacrei-webserver-sg` e excluí-lo.

5.  **Excluir a Função IAM (IAM Role):**
    - Navegar até o serviço **IAM**.
    - Ir para `Roles` (Funções), selecionar a `EC2-CloudWatch-Logs-Role` e excluí-la.

6.  **Excluir Recursos de Observabilidade:**
    - Navegar até o serviço **CloudWatch**.
    - Em `Logs` > `Log groups`, selecionar `lacrei-staging-logs` e excluí-lo.
    - Em `Alarms` > `All alarms`, selecionar `Alarme_CPU_Alta_Staging` e excluí-lo.
    - Navegar até o serviço **SNS**.
    - Em `Topics`, selecionar `lacrei-alarms` e excluí-lo (isso também removerá a assinatura de email).

A execução destes passos garante que todos os recursos criados para o projeto sejam removidos, evitando qualquer cobrança futura na conta da AWS.