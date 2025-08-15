# Desafio Técnico – DevOps na Lacrei Saúde

---

## ✨ Boas-vindas ao Desafio de DevOps da Lacrei Saúde!

Estamos muito felizes com seu interesse em fazer parte do nosso time voluntário! 💙

Na Lacrei Saúde, acreditamos que tecnologia é uma ponte para o cuidado, e que a infraestrutura por trás da nossa plataforma deve ser tão acolhedora e segura quanto o atendimento que oferecemos.

Este desafio foi pensado para ser realizado dentro do tempo disponível da nossa jornada de voluntariado: **3 meses com dedicação de 18 horas semanais**.

> 📅 Temos dois encontros obrigatórios por semana:
> 
> 
> 🕖 **Segundas e terças, das 19h às 20h30** (horário de Brasília)
> 

---

## 💡 Sobre a Atividade Voluntária

- **Duração:** 3 meses
- **Carga horária:** 18 horas semanais
- **Encontros obrigatórios:**
    
    🕖 Segundas e terças, das 19h às 20h30 (horário de Brasília)
    

---

## 🎯 Proposta do Desafio

Sua missão é construir um pipeline de deploy seguro, escalável e eficiente, que permita a publicação de aplicações em ambientes de **staging e produção**, seguindo boas práticas de infraestrutura, automação e segurança, visto que todos nossos dados são tratados como sensíveis.

Este desafio simula exatamente a rotina do time de DevOps da Lacrei Saúde, garantindo que o deploy seja estável, documentado e confiável, tanto em staging quanto em produção.

Construa com a gente um ambiente de deploy seguro, estável e inclusivo.

---

## 📝 Sobre a aplicação fictícia

Crie um repositório contendo uma aplicação simples de teste (Node.js com uma rota `/status`) e um Dockerfile configurado. 

A partir disso, você poderá adaptar ou propor melhorias na estrutura de CI/CD para otimizar o processo de deploy.

---

### 📋 **O que esperamos de você — Itens obrigatórios:**

- ✅ **Setup de ambientes:**
    
    🔸 **Staging e produção**, ambos na AWS, utilizando:
    
    - Docker
    - GitHub Actions
    - AWS (EC2, Lightsail, ECS ou serviço equivalente)
- ✅ **Deploy de uma aplicação fictícia:**
    
    🔸 Uma API simples (Node.js com rota `/status`) hospedada nos ambientes.
    
    🔸 Containerizada com Docker.
    
- ✅ **Pipeline CI/CD completo:**
    
    🔸 Utilizando GitHub Actions, contendo:
    
    - Build da imagem
    - Testes (mínimo validação do container)
    - Deploy automatizado para staging e produção
    - Steps claros, com validação antes do deploy
- ✅ **Segurança como pilar:**
    
    🔸 Gerenciamento seguro de secrets (via GitHub Secrets ou AWS Secrets Manager)
    
    🔸 Configuração de CORS se aplicável
    
    🔸 Uso obrigatório de HTTPS/TLS no ambiente
    
    🔸 Políticas de acesso restritivas nos ambientes (princípio do menor privilégio)
    
- ✅ **Observabilidade:**
    
    🔸 Logs acessíveis da aplicação e do deploy
    
    🔸 Proposta ou implementação de monitoramento básico (CloudWatch)
    
- ✅ **Documentação obrigatória:**
    
    🔸 README contendo:
    
    - Setup dos ambientes
    - Fluxo de CI/CD (com desenho se possível)
    - Registro dos erros encontrados e decisões tomadas
    - Processo de rollback
    - Checklist de segurança aplicado
- ✅ **Rollback funcional:**
    
    🔸 Descreva no README como executar rollback de forma segura.
    
    🔸 Sugestões: Deploy Blue/Green, revert de imagem Docker, ou rollback manual documentado.
    
- 🟨 **(Bônus recomendado):**
    
    🔸 Proposta de integração com a Assas (real, mock ou arquitetura)
    
    🔸 Implementação de alertas (ex.: via Slack ou AWS SNS)
    

---

## 🧩 Como irá fazer:

1. Realizar o setup dos ambientes de **staging** e **produção**, usando:
    - Docker
    - AWS
    - GitHub Actions
2. Aplicar um **deploy completo de uma aplicação fictícia** (em um repositório no GitHub).
3. Documentar todas as etapas do processo: ex: erros encontrados, decisões técnicas, melhorias propostas e o que achar pertinente para uma boa compreensão do projeto.
4. Propor um fluxo de **integração com a AssAs** (split de pagamento), podendo ser:
    - Implementação real (opcional)
    - Mock de integração (Postman ou arquitetura)
    - Proposta de fluxo com base em documentação pública
5. (Opcional, mas valorizado!) Documentar como seria feito o **rollback** da aplicação em caso de falha no deploy.

---

## 📅 Entrega

<aside>
📁

Em um **link público na plataforma Notion**, incluir : 

- Um breve texto contando por que deseja fazer parte da nossa missão em contexto com a profissão de DevOps.
- Link dos ambientes de staging e produção
- Link do repositório no GitHub (público)
</aside>

Você terá **5 dias corridos** após o recebimento deste desafio para finalizá-lo.

Ao concluir, envie um **e-mail com o link da entrega (repositório, documentação e deploy)** para:

📧 `desenvolvimento.humano@lacreisaude.com.br`

---

## 🏗️ **Critérios de Aceite**

| Item | Obrigatório | Observações |
| --- | --- | --- |
| Deploy funcional (staging e produção) | ✅ | Ambientes separados, funcionando corretamente. |
| Docker + GitHub Actions + AWS | ✅ | Configuração robusta e replicável. |
| Pipeline CI/CD completo com validações | ✅ | Inclui lint, testes (mínimos), build e deploy. |
| Segurança aplicada (secrets, HTTPS, acesso) | ✅ | Demonstra responsabilidade com ambientes sensíveis. |
| Observabilidade (logs) | ✅ | Logs do deploy e da aplicação configurados. |
| Documentação clara no README | ✅ | Fluxo do pipeline, ambientes, rollback, checklist de segurança. |
| Monitoramento e alertas básicos | ✅ | Fortemente recomendado (CloudWatch, Grafana, Slack, etc.) |
| Rollback documentado e funcional | 🟨 Opcional | Pode ser via Docker, GitHub Actions, AWS ou estratégia sugerida. |
| Integração com Assas (mock ou arquitetura) | 🟨 Opcional | Demonstra visão de integração entre sistemas. |

---

## 💙 Nosso agradecimento

Na Lacrei Saúde, acreditamos que **código é cuidado**, e tecnologia pode transformar realidades.

Ficamos muito felizes com sua dedicação e vontade de contribuir com algo tão significativo. 

Seu trabalho será parte da construção de um sistema que acolhe, respeita e protege.

---

> 🥰 Boa sorte! Estamos torcendo por você. 🌈
>