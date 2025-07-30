# Jornada do Projeto: Um Guia Passo a Passo

Este documento detalha a jornada completa de construção da solução para o Desafio DevOps da Lacrei Saúde, servindo como um tutorial e um registro de aprendizado de todo o processo.

---

### **Etapa 1: Fundação e Teste Local**

#### Objetivo:
O objetivo inicial foi criar a "matéria-prima" do projeto: uma aplicação Node.js funcional e as instruções para sua containerização com Docker. Antes de qualquer automação ou implantação na nuvem, era crucial garantir que a aplicação pudesse ser construída e executada de forma padronizada e isolada no ambiente de desenvolvimento local.

#### Conceitos Chave:
- **Node.js:** Ambiente de execução para o código JavaScript do lado do servidor.
- **Express.js:** Framework minimalista para Node.js, utilizado para criar a API e a rota `/status`.
- **Docker:** Plataforma de containerização que "empacota" a aplicação e todas as suas dependências em uma unidade isolada e portátil chamada contêiner.
- **Dockerfile:** Um arquivo de texto que contém a "receita", o passo a passo de comandos para o Docker construir a imagem da nossa aplicação.

#### Passo a Passo Executado:
1.  **Estrutura do Projeto:** Foi criada uma pasta local para o projeto.
2.  **Definição da Aplicação (`package.json`):** Criei o arquivo para definir os metadados do projeto e declarar a dependência do `express`.
3.  **Código-Fonte (`app.js`):** Implementei um servidor web simples com uma única rota `GET /status` para atender ao requisito do desafio.
4.  **Instruções de Containerização (`Dockerfile`):** Criei o `Dockerfile` definindo a imagem base (`node:18-alpine`), copiando os arquivos necessários, instalando as dependências com `npm install` e definindo o comando de inicialização (`CMD`).
5.  **Validação Local:**
    - A aplicação foi testada nativamente com o comando `node app.js`.
    - A imagem Docker foi construída com `docker build -t desafio-lacrei-app .`.
    - O contêiner foi executado com `docker run -p 3000:3000 ...` e a aplicação foi validada através do navegador, confirmando o sucesso da containerização.

### **Etapa 2: Versionamento e Publicação do Código**

#### Objetivo:
Com a aplicação funcionando localmente, o próximo passo foi mover o código para um sistema de controle de versão e hospedá-lo em um repositório remoto. Isso foi fundamental para rastrear o histórico de alterações e, principalmente, para servir como ponto de partida para o futuro pipeline de CI/CD.

#### Conceitos Chave:
- **Git:** Sistema de controle de versão distribuído, que usei para gerenciar o histórico do código-fonte.
- **GitHub:** Plataforma de hospedagem para repositórios Git, que também provê as ferramentas de automação (GitHub Actions).
- **Repositório (Local e Remoto):** O repositório local (na pasta `.git`) vive na minha máquina, enquanto o remoto (no GitHub) serve como um backup centralizado e ponto de integração.
- **`.gitignore`:** Um arquivo de configuração que instrui o Git sobre quais arquivos e pastas devem ser ignorados (como a pasta `node_modules`).

#### Passo a Passo Executado:
1.  **Inicialização do Repositório Local:** Executei o comando `git init` na pasta do projeto para criar o repositório local.
2.  **Criação do `.gitignore`:** Criei um arquivo `.gitignore` com a entrada `/node_modules` para evitar o versionamento de milhares de arquivos de dependências.
3.  **Resolução de Problemas:** Foi necessário um processo de debug para limpar a *staging area* do Git, que havia capturado a `node_modules` acidentalmente antes da criação do `.gitignore`. Usei os comandos `git reset` e `git rm -rf --cached .` para corrigir o estado do versionamento.
4.  **Criação do Repositório Remoto:** Criei um novo repositório público e vazio diretamente na interface do GitHub.
5.  **Primeiro Commit:** Adicionei os arquivos do projeto (`git add .`) e os salvei no histórico local com o comando `git commit`.
6.  **Conexão e Envio:** Conectei o repositório local ao remoto com `git remote add origin ...` e enviei o código pela primeira vez ao GitHub com `git push -u origin main`.

### **Etapa 3: Criação do Ambiente de Staging na AWS**

#### Objetivo:
O objetivo desta etapa foi provisionar a infraestrutura de nuvem para o primeiro ambiente (Staging). Criei um servidor virtual na AWS que seria o destino dos deploys automatizados, garantindo um local isolado e padronizado para os testes da aplicação.

#### Conceitos Chave:
- **AWS (Amazon Web Services):** Provedor de serviços de nuvem que utilizei para hospedar a infraestrutura.
- **EC2 (Elastic Compute Cloud):** Serviço da AWS que fornece capacidade computacional redimensionável (máquinas virtuais) na nuvem.
- **Instância:** Uma máquina virtual individual no ambiente EC2.
- **AMI (Amazon Machine Image):** O template de software (neste caso, `Ubuntu Server 22.04 LTS`) que usei para lançar a instância.
- **Security Group:** Um firewall virtual que controla o tráfego para a instância. Configurei-o para permitir acesso nas portas `22` (SSH), `80` (HTTP) e `443` (HTTPS).
- **SSH (Secure Shell) e Key Pair:** O método de conexão segura para administrar o servidor remotamente. Em vez de senhas, utilizei um par de chaves criptográficas (`.pem`) para a autenticação.
- **IP Elástico:** Um endereço de IP estático e fixo, que aloquei para garantir que o endereço do servidor não mudasse após reinicializações.

#### Passo a Passo Executado:
1.  **Provisionamento da Instância:** Pelo console da AWS, lancei uma nova instância EC2 `t2.micro` com uma AMI do Ubuntu Server 22.04 LTS na região `us-east-1`.
2.  **Configuração de Segurança:** Criei e baixei um novo par de chaves (`lacrei-devops-key.pem`) para o acesso SSH. Criei um Security Group (`lacrei-webserver-sg`), configurando as regras de firewall para as portas necessárias.
3.  **Conexão e Resolução de Problemas:** Realizei a primeira conexão via SSH. Foi necessário ajustar as permissões do arquivo `.pem` no Windows, que por padrão eram muito abertas, para satisfazer os requisitos de segurança do cliente SSH.
4.  **Preparação do Servidor:** Após conectar, instalei o Docker Engine na instância (`docker.io`) e adicionei o usuário `ubuntu` ao grupo `docker` para poder executar comandos sem `sudo`.
5.  **Criação do IP Fixo:** Para garantir um endereço estável, aloquei um IP Elástico e o associei à instância de staging.

### **Etapa 4: Automação do Deploy em Staging (CI/CD)**

#### Objetivo:
O objetivo desta etapa foi criar um "robô" (o pipeline de CI/CD) para automatizar completamente o processo de entrega da aplicação. A meta era que, a cada nova alteração enviada ao repositório, a aplicação fosse automaticamente construída, empacotada e implantada no servidor de staging, eliminando a necessidade de qualquer intervenção manual.

#### Conceitos Chave:
- **CI/CD (Continuous Integration/Continuous Deployment):** A prática de automatizar as fases de construção, teste e implantação de software.
- **GitHub Actions:** A plataforma de automação nativa do GitHub que utilizei para construir o pipeline.
- **Workflow:** O processo automatizado, definido em um arquivo de configuração no formato YAML (`.github/workflows/deploy-staging.yml`).
- **GitHub Secrets:** O "cofre" seguro do repositório, onde armazenei todas as credenciais sensíveis (como as chaves da AWS) para que o pipeline pudesse usá-las sem expô-las no código.
- **GitHub Container Registry (GHCR):** O registro de contêineres nativo do GitHub. Optei por usá-lo para hospedar as imagens Docker, o que simplificou e tornou a autenticação mais segura.

#### Passo a Passo Executado:
1.  **Criação dos Segredos:** Configurei os GitHub Secrets necessários para a automação: `AWS_HOST` (IP do servidor), `AWS_USERNAME` (usuário `ubuntu`) e `AWS_SSH_KEY` (a chave privada `.pem`).
2.  **Criação do Arquivo de Workflow:** Criei a estrutura de pastas `.github/workflows/` e o arquivo `deploy-staging.yml`.
3.  **Definição do Pipeline:** Estruturei o pipeline com os seguintes passos:
    - **Gatilho:** O pipeline seria acionado a cada `push` na branch `main`.
    - **Build & Push:** A imagem Docker seria construída e enviada para um registro de contêineres.
    - **Deploy:** O pipeline se conectaria via SSH ao servidor de staging para baixar a nova imagem e reiniciar o contêiner.
4.  **Resolução de Problemas de Autenticação (Decisão Estratégica):**
    - **Problema:** A tentativa inicial de usar o Docker Hub como registro de contêineres encontrou um erro persistente e raro de `insufficient_scope`, mesmo com um token de acesso configurado corretamente.
    - **Solução:** Tomei a decisão estratégica de abandonar o Docker Hub e migrar para o **GitHub Container Registry (GHCR)**. Esta abordagem se provou superior, pois a autenticação é feita de forma nativa e automática com o `GITHUB_TOKEN`, eliminando a necessidade de gerenciar tokens de terceiros e resolvendo o problema de permissão de uma vez por todas.
5.  **Sucesso do Pipeline:** Após a migração para o GHCR, o pipeline de staging foi executado com sucesso, automatizando o deploy do início ao fim.

### **Etapa 5: Implementação de Segurança (HTTPS)**

#### Objetivo:
O objetivo desta etapa foi adicionar uma camada de segurança essencial à aplicação, implementando o protocolo HTTPS. Isso garante que toda a comunicação entre o navegador do usuário e o servidor seja criptografada, eliminando o aviso de "Não seguro" do navegador e protegendo os dados em trânsito, um requisito obrigatório do desafio.

#### Conceitos Chave:
- **HTTPS (Hypertext Transfer Protocol Secure):** A versão segura do protocolo HTTP, que utiliza criptografia SSL/TLS.
- **SSL/TLS:** Certificados digitais que autenticam a identidade de um site e permitem a comunicação criptografada.
- **Let's Encrypt:** Uma Autoridade Certificadora (CA) gratuita e automatizada que usei para obter os certificados SSL/TLS.
- **Certbot:** O software cliente que instalei no servidor para solicitar, gerenciar e renovar automaticamente os certificados da Let's Encrypt.
- **DuckDNS:** Um serviço de DNS dinâmico gratuito, que utilizei para obter um nome de domínio (`.duckdns.org`) e apontá-lo para o IP Fixo do servidor.
- **Docker Volumes (`-v`):** Um recurso do Docker que permite "espelhar" uma pasta do servidor para dentro do contêiner. Foi crucial para dar à aplicação Node.js acesso aos arquivos de certificado.
- **Variáveis de Ambiente (`-e`):** Utilizadas para passar informações de configuração para a aplicação dentro do contêiner, tornando o código mais flexível e reutilizável entre ambientes.

#### Passo a Passo Executado:
1.  **Configuração do Domínio:** Criei um subdomínio no DuckDNS (`saulo-devops-lacrei.duckdns.org`) e o apontei para o IP Elástico do servidor de staging.
2.  **Geração do Certificado:** Conectei-me ao servidor via SSH e utilizei o Certbot no modo `standalone` para gerar os certificados SSL para o domínio. Para isso, foi necessário parar temporariamente o contêiner da aplicação para liberar a porta 80 para o processo de validação.
3.  **Refatoração da Aplicação (`app.js`):** Modifiquei o código da aplicação para que ela se tornasse configurável. Ela passou a ler o nome do domínio de uma variável de ambiente (`DOMAIN_NAME`) para encontrar os arquivos de certificado corretos. Além disso, criei dois servidores: um HTTPS na porta `8443` para a aplicação principal e um servidor HTTP na porta `3000` com a única função de redirecionar todo o tráfego para HTTPS.
4.  **Atualização do Pipeline:** Modifiquei o `deploy-staging.yml` para habilitar o HTTPS no contêiner:
    - Adicionei o mapeamento de portas `-p 443:8443` (HTTPS) e `-p 80:3000` (HTTP Redirect).
    - Adicionei um volume com a flag `-v /etc/letsencrypt:/etc/letsencrypt:ro` para dar à aplicação acesso de leitura aos certificados.
    - Adicionei a variável de ambiente com a flag `-e DOMAIN_NAME=...` para informar à aplicação qual certificado carregar.
5.  **Validação:** Após o deploy bem-sucedido, confirmei que o acesso ao domínio via `https://` exibia o cadeado de segurança (🔒) no navegador.

### **Etapa 6: Criação do Ambiente de Produção**

#### Objetivo:
O objetivo foi criar um segundo ambiente na AWS, totalmente isolado do de staging, para servir como o ambiente de **Produção**. Isso cumpre um requisito central do desafio e simula um fluxo de trabalho real, onde novas funcionalidades são testadas em staging antes de serem promovidas para o ambiente dos usuários finais.

#### Conceitos Chave:
- **Múltiplos Ambientes:** Prática fundamental em DevOps para separar os estágios de desenvolvimento, teste (Staging) e uso real (Produção), garantindo estabilidade e segurança.
- **Reutilização de Recursos:** Para manter a consistência e a eficiência, reutilizei recursos sempre que possível, como o **Par de Chaves SSH** e o **Security Group**, que já estavam configurados corretamente.
- **Otimização de Custos:** Foi feita uma análise de custos sobre o uso de um segundo IP Fixo (Elástico). Para cumprir o desafio sem gerar cobranças, optei por usar o IP público dinâmico para a instância de produção, com a estratégia de mantê-la em execução durante o período de avaliação.

#### Passo a Passo Executado:
1.  **Lançamento da Instância:** Pelo console da AWS, lancei uma nova instância EC2 (`lacrei-production-server`), usando as mesmas configurações base da de staging (`t2.micro`, Ubuntu 22.04 LTS).
2.  **Reutilização de Configurações:** Durante a criação, em vez de gerar novos recursos, selecionei o Par de Chaves (`lacrei-devops-key.pem`) e o Security Group (`lacrei-webserver-sg`) já existentes.
3.  **Obtenção do IP Dinâmico:** Após a instância entrar no estado `Running`, anotei seu IP público dinâmico para ser usado na configuração do domínio e do pipeline.
4.  **Preparação do Servidor:** Assim como no de staging, conectei-me à nova instância via SSH e realizei a instalação e configuração do Docker Engine.

### **Etapa 7: Automação do Deploy em Produção**

#### Objetivo:
O objetivo foi criar um segundo pipeline de CI/CD, dedicado exclusivamente ao ambiente de produção. Este pipeline precisava ser mais controlado e seguro que o de staging, garantindo que apenas versões de código estáveis e explicitamente aprovadas fossem liberadas para os usuários finais.

#### Conceitos Chave:
- **Gatilho por Tag (Git Tags):** Diferente do pipeline de staging que dispara a cada `push` na branch `main`, optei por um gatilho baseado em tags do Git (ex: `v1.0.0`, `v1.0.1`). Criar uma tag é um ato intencional, que funciona como uma "autorização" formal para o deploy em produção.
- **Versionamento de Imagens (Image Tagging):** Para garantir a rastreabilidade e facilitar possíveis rollbacks, a imagem Docker enviada para o GHCR é marcada com a mesma versão da tag do Git (ex: `ghcr.io/saulocdemonte/desafio-lacrei-app:v1.0.1`), em vez de usar a tag genérica `:latest`.

#### Passo a Passo Executado:
1.  **Configuração do Segredo:** Criei um novo segredo no GitHub, `AWS_HOST_PROD`, para armazenar o endereço IP do servidor de produção.
2.  **Criação do Domínio e Certificado:** Criei um novo domínio de produção no DuckDNS (`saulo-prod-lacrei.duckdns.org`) e, conectado ao servidor de produção, gerei um novo certificado SSL com o Certbot para este domínio.
3.  **Criação do Workflow de Produção:** Criei o arquivo `.github/workflows/deploy-production.yml`.
4.  **Customização do Pipeline:** Adaptei o pipeline com as seguintes lógicas específicas para produção:
    - Alterei o gatilho (`on:`) para responder apenas a `push` de `tags` no formato `v*.*.*`.
    - Atualizei o passo de 'Build e Push' para usar a variável `${{ github.ref_name }}` do GitHub Actions, garantindo que a tag da imagem Docker fosse a mesma da tag do Git.
    - Apontei o passo de deploy para o servidor de produção, usando o segredo `AWS_HOST_PROD`.
    - Configurei o comando `docker run` para usar o HTTPS e a variável de ambiente `DOMAIN_NAME` específica da produção.
5.  **Teste do Deploy:** Para testar, executei os comandos `git tag v1.0.x` e `git push origin v1.0.x`, o que acionou o pipeline com sucesso e implantou a aplicação no ambiente de produção.

### **Etapa 8: Implementação da Observabilidade**

#### Objetivo:
O objetivo foi cumprir o requisito de observabilidade, garantindo que os logs gerados pela aplicação fossem capturados, centralizados e armazenados de forma persistente. Isso é essencial para monitorar a saúde da aplicação, analisar eventos e diagnosticar problemas sem precisar acessar o servidor diretamente.

#### Conceitos Chave:
- **Observabilidade:** Em DevOps, é a capacidade de entender o estado interno de um sistema a partir de seus outputs externos (neste caso, os logs).
- **AWS CloudWatch Logs:** Um serviço da AWS para armazenamento e monitoramento centralizado de arquivos de log.
- **IAM Role para EC2:** Uma forma segura de conceder permissões a uma instância EC2 para acessar outros serviços da AWS (como o CloudWatch) sem precisar armazenar chaves de acesso permanentes na máquina.
- **Docker Log Driver:** Um mecanismo que permite ao Docker redirecionar os logs dos contêineres para diferentes destinos. Utilizei o driver `awslogs`.

#### Passo a Passo Executado:
1.  **Concessão de Permissões (IAM Role):** Criei uma IAM Role (`EC2-CloudWatch-Logs-Role`) com a política `CloudWatchLogsFullAccess`. Em seguida, associei esta role a ambas as instâncias EC2 (staging e produção), concedendo-lhes a permissão necessária para enviar logs para o CloudWatch.
2.  **Configuração do Docker no Servidor:** Conectei-me a cada servidor via SSH e criei o arquivo `/etc/docker/daemon.json` para configurar o `awslogs` como o driver de log padrão.
3.  **Atualização dos Pipelines:** Para tornar a configuração mais robusta, adicionei flags explícitas de logging (`--log-driver` e `--log-opt`) ao comando `docker run` em ambos os arquivos de workflow (`.yml`), especificando o grupo de logs `lacrei-staging-logs`.
4.  **Resolução de Problemas:** O pipeline inicialmente falhou porque a IAM Role não havia sido associada à instância. Após identificar e corrigir este passo, o deploy seguinte funcionou perfeitamente.
5.  **Validação:** Verifiquei o sucesso da implementação acessando o serviço CloudWatch no console da AWS, localizando o grupo de logs e confirmando que as mensagens de inicialização da minha aplicação estavam sendo registradas.

### **Etapa 9: Configuração de Alertas (Bônus)**

#### Objetivo:
Para cumprir um dos itens bônus e adicionar uma camada de monitoramento proativo, o objetivo foi criar um sistema de alertas automáticos. A meta era ser notificado por email caso o servidor de staging apresentasse sinais de sobrecarga, permitindo uma ação corretiva antes que o serviço fosse impactado.

#### Conceitos Chave:
- **Monitoramento Proativo:** A prática de monitorar a saúde de um sistema e gerar alertas automáticos sobre possíveis problemas, em vez de reagir apenas quando uma falha ocorre.
- **AWS CloudWatch Alarms:** O serviço da AWS que permite criar "alarmes" que vigiam uma métrica específica (como uso de CPU) e disparam ações quando certas condições são atendidas.
- **AWS SNS (Simple Notification Service):** Um serviço de mensagens e notificações da AWS. Utilizei-o para criar um "Tópico" (um canal de notificações) para onde os alertas são enviados.
- **Métrica (`CPUUtilization`):** A métrica específica do CloudWatch que mede a porcentagem de utilização da CPU da instância EC2.

#### Passo a Passo Executado:
1.  **Criação do Canal de Notificação (SNS Topic):** No console do SNS, criei um Tópico Padrão chamado `lacrei-alarms`.
2.  **Criação da Assinatura (SNS Subscription):** Criei uma "assinatura" para este tópico, utilizando o protocolo `Email` e cadastrando meu endereço de email pessoal como o destino (`Endpoint`). Foi necessário confirmar a inscrição através de um link enviado ao email.
3.  **Criação do Alarme (CloudWatch Alarm):** No console do CloudWatch, criei um novo alarme.
4.  **Definição da Métrica e Condição:** Configurei o alarme para monitorar a métrica `CPUUtilization` da instância de staging. A condição definida foi: disparar o alarme se a média de uso da CPU for **maior que 70%** por um período contínuo de **5 minutos**.
5.  **Configuração da Ação:** Configurei o alarme para, quando entrar no estado `In alarm`, enviar uma notificação para o Tópico SNS `lacrei-alarms`.
6.  **Validação:** Confirmei que o alarme foi criado com sucesso e apareceu na lista de alarmes, passando do estado inicial de "Dados insuficientes" para "OK".

### **Etapa 10: Finalização com Testes e Documentação**

#### Objetivo:
O objetivo da etapa final foi garantir a confiabilidade dos pipelines e consolidar todo o trabalho em uma documentação coesa e profissional. Isso incluiu a implementação de um teste de validação automatizado (conforme o requisito do desafio) e a criação dos documentos finais do projeto.

#### Conceitos Chave:
- **Smoke Test (Teste de Fumaça):** Um tipo de teste simples e rápido executado após um deploy para verificar se as funções mais críticas da aplicação estão funcionando. No nosso caso, o teste valida se o servidor web está no ar e respondendo na rota `/status`.
- **`curl`:** Uma ferramenta de linha de comando para fazer requisições web. Utilizei a flag `-f` (fail), que faz o comando falhar se o servidor responder com um erro HTTP (como 404 ou 500), o que automaticamente falharia o pipeline.
- **Documentação Técnica (`README.md`):** O arquivo que serve como a porta de entrada e o manual principal do projeto.

#### Passo a Passo Executado:
1.  **Implementação do Smoke Test:** Adicionei um novo passo chamado "Validar Deploy" ao final de ambos os workflows (`deploy-staging.yml` e `deploy-production.yml`).
2.  **Configuração do Teste:** O passo executa um `sleep 15` para aguardar a inicialização do contêiner, seguido por um `curl -f` que acessa a URL `/status` de cada ambiente respectivo (Staging ou Produção). O sucesso deste passo confirma que o deploy não apenas foi executado, mas resultou em uma aplicação funcional e acessível.
3.  **Finalização da Documentação Principal:** Realizei a criação e revisão completa do arquivo `README.md` do repositório, garantindo que todas as seções obrigatórias e bônus do desafio fossem preenchidas com informações precisas, refletindo o estado final do projeto.
4.  **Criação deste Documento (`JORNADA_DO_PROJETO.md`):** Como um passo final de excelência, criei este documento para servir como um tutorial detalhado e um registro de aprendizado de toda a jornada, desde a concepção até a entrega final, demonstrando a capacidade de documentar processos complexos.

---

### **Etapa 11: Procedimento de Limpeza (Cleanup)**

#### Objetivo:
A etapa final, após a conclusão e avaliação do projeto, é remover (descomissionar) todos os recursos provisionados na AWS para garantir a otimização de custos e a segurança, evitando cobranças futuras.

#### Passo a Passo para Remoção Segura:

1.  **Terminar as Instâncias EC2:**
    - Navegar até o painel do EC2.
    - Selecionar as instâncias `lacrei-staging-server` e `lacrei-production-server`.
    - Clicar em `Instance state` > `Terminate instance`. A ação "Terminate" apaga permanentemente as máquinas virtuais.

2.  **Liberar os Endereços IP Elásticos:**
    - No painel do EC2, ir para a seção `Elastic IPs`.
    - Selecionar os dois IPs Fixos que foram alocados.
    - Clicar em `Actions` > `Release Elastic IP addresses`.

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
    - Em `Topics`, selecionar `lacrei-alarms` e excluí-lo.

    A execução destes passos garante que todos os recursos criados para o projeto sejam removidos, evitando qualquer cobrança futura na conta da AWS.