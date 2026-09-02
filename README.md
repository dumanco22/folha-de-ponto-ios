# Folha de Ponto — Sunny Brinquedos (iOS)

App iOS (Swift + SwiftUI + SwiftData) para controle de ponto, com exatamente as mesmas
regras de cálculo da versão Android e da planilha `Horas.xlsx`.

Requisitos: iPhone com **iOS 17+**. Para compilar, o ideal é um **Mac com Xcode 15+**
— mas se você só tem Windows, o **Caminho C** abaixo compila num Mac gratuito do
GitHub Actions, sem precisar comprar nada.

## Como abrir no Xcode

Existem três caminhos. Use o **Caminho A** se tiver um Mac e puder instalar uma
ferramenta pelo Terminal; o **Caminho B** se tiver um Mac mas preferir não instalar
nada; e o **Caminho C** se você só tem Windows/Linux e não tem Mac nenhum.

### Caminho A — com XcodeGen (recomendado, mais rápido)

O [XcodeGen](https://github.com/yonaskolb/XcodeGen) lê o arquivo `project.yml` e gera o
`.xcodeproj` automaticamente — evita qualquer risco de projeto corrompido.

1. Instale o XcodeGen (uma vez só), no Terminal do Mac:
   ```
   brew install xcodegen
   ```
   (se não tiver o Homebrew: instale em https://brew.sh primeiro)
2. Extraia o `.zip` deste projeto e, no Terminal, entre na pasta:
   ```
   cd caminho/para/FolhaDePontoIOS
   xcodegen generate
   ```
3. Abra o arquivo gerado `FolhaDePonto.xcodeproj` (duplo clique, ou `open FolhaDePonto.xcodeproj`).
4. Selecione um simulador de iPhone e rode com ▶.

### Caminho B — manualmente, sem instalar nada

1. Abra o Xcode → **File → New → Project… → iOS → App**.
   - Product Name: `FolhaDePonto`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: Swift
   - Marque "iOS 17" como Minimum Deployment.
2. Feche o Xcode, e na pasta do projeto que ele criou, **substitua** os arquivos
   `FolhaDePontoApp.swift`, `ContentView.swift` (pode apagar este) e `Assets.xcassets`
   pelos deste pacote.
3. No Finder, arraste as pastas `Models`, `Domain`, `Data`, `Util` e `Views` (dentro de
   `FolhaDePonto/`) para dentro do grupo do projeto no Xcode (marque "Copy items if
   needed" e "Create groups").
4. Rode com ▶.

### Caminho C — sem Mac nenhum, usando o GitHub Actions (grátis)

Esse caminho compila o app num Mac "emprestado" pelo GitHub (de graça) e te entrega um
arquivo `.ipa` para instalar no seu iPhone direto do Windows, usando o **Sideloadly**.
Já vem pronto: o arquivo `.github/workflows/build-ios.yml` dentro deste pacote configura
tudo — você só precisa subir o código para o GitHub.

**Limitação a saber antes de começar:** como não usamos uma conta paga da Apple
(Apple Developer Program, US$ 99/ano), o app instalado expira em **7 dias** — depois
disso é só reinstalar de novo (grátis, o app não muda, é só repetir os passos 5–7 abaixo,
ou até 2× por semana se quiser evitar o app "sumir" do celular).

**1. Crie uma conta no GitHub** (gratuita): https://github.com/signup

**2. Crie um repositório novo:**
   - Em https://github.com/new, dê um nome (ex: `folha-de-ponto-ios`), marque
     **Public**, e clique em **Create repository**. Deixe sem README/gitignore
     (nós já temos).

**3. Suba o código deste pacote para o repositório.** No seu PC, com o
   [Git para Windows](https://git-scm.com/download/win) instalado, abra o Prompt de
   Comando/PowerShell na pasta `FolhaDePontoIOS` (a que você extraiu do zip) e rode:
   ```
   git init
   git add .
   git commit -m "Primeira versão"
   git branch -M main
   git remote add origin https://github.com/dumanco22/folha-de-ponto-ios.git
   git push -u origin main
   ```
   (troque `SEU-USUARIO` e o nome do repositório pelos que você escolheu — o GitHub
   pode pedir para você fazer login/autenticar na hora do `push`.)

**4. O build começa sozinho.** Assim que o `push` terminar, vá até a aba **Actions** do
   seu repositório no site do GitHub — vai aparecer um build rodando ("Build iOS...").
   Leva uns 5 a 10 minutos. Se der erro vermelho, me manda o log que eu corrijo.

**5. Baixe o `.ipa` gerado.** Quando o build terminar com ✅, clique nele, role até
   **Artifacts** e baixe `FolhaDePonto-ipa` (vem como `.zip`; dentro tem o
   `FolhaDePonto.ipa`).

**6. Instale o [Sideloadly](https://sideloadly.io/) no seu PC Windows** (gratuito) —
   também precisa do iTunes (ou só o "Apple Devices"/"Apple Mobile Device Support")
   instalado para o Windows reconhecer o iPhone por cabo.

**7. Conecte o iPhone por cabo USB**, abra o Sideloadly, arraste o `FolhaDePonto.ipa`
   para dentro dele, digite seu **Apple ID** (o mesmo da App Store — é só para assinar o
   app, não precisa ser conta paga) e clique em **Start**. Ele pode pedir a senha e um
   código de verificação em duas etapas.

**8. Confie no desenvolvedor no iPhone:** vá em **Ajustes → Geral → VPN e Gerenciamento
   de Dispositivo**, toque no seu Apple ID listado lá e em **Confiar**. Sem esse passo o
   iOS bloqueia a abertura do app com um aviso de "desenvolvedor não confiável".

Pronto — o app aparece na tela inicial do iPhone como qualquer outro.

*Se o Sideloadly reclamar de "bundle identifier already in use"*, é só abrir as opções
avançadas dele e adicionar um sufixo ao identificador (ex: trocar
`com.sunnybrinquedos.folhadeponto` por `com.sunnybrinquedos.folhadeponto.danrley`) —
não afeta nada no funcionamento do app.

**Alternativa ao Sideloadly:** o [AltStore](https://altstore.io/) faz a mesma coisa e
consegue renovar o app automaticamente toda semana sozinho (enquanto o iPhone estiver na
mesma rede Wi-Fi do PC com o AltServer aberto), então você não precisa repetir os passos
6–8 toda semana.

## Regras de cálculo (idênticas à planilha e ao app Android)

- **Período:** começa no dia 24 de um mês e fecha no dia 23 do mês seguinte (configurável
  em Configurações).
- **Segunda a quinta:** 07:40 às 17:30, com 1h de almoço (12:00–13:00).
- **Sexta-feira:** 07:40 às 17:10, com 1h de almoço.
- **Sábado e domingo:** todo o tempo trabalhado é hora extra 100%.
- **Dias de semana:** horas além do horário previsto (menos 1h de almoço) contam como
  hora extra 60%.
- **Valores:** hora normal configurável (padrão R$ 16,00); extra 60% = hora normal × 1,6;
  extra 100% = hora normal × 2; valor de folga e valor de vale (IFOOD) por dia também
  configuráveis.

## Funcionalidades

- **Bater ponto** com um toque (grava o horário atual) ou edição manual de qualquer
  horário do dia (toque no campo → seletor de horário).
- Navegação entre períodos (mês anterior/seguinte) para consultar o histórico completo.
- Resumo do período: horas trabalhadas, normais, extra 60%, extra 100%, folgas, IFOOD e
  total geral de extras em R$.
- Marcação de **Folga** e **IFOOD** por dia, com campo de observação livre.
- **Exportar PDF** do período (botão na parte inferior), com a tela de compartilhar do
  iOS (enviar por e-mail, WhatsApp, salvar em Arquivos etc.).
- Tema claro/escuro automático (segue o sistema).

## Estrutura do projeto

```
FolhaDePonto/
├── FolhaDePontoApp.swift   Ponto de entrada + configuração do SwiftData
├── Models/                 DiaPonto (SwiftData), ConfiguracaoData, DiaCalculado, PeriodoResumo
├── Domain/                 Regras de negócio (cálculo de horas, período, datas, horários)
├── Data/                   ConfiguracaoStore (UserDefaults) + acesso ao SwiftData
├── Views/                  Telas em SwiftUI (Início, Detalhe do Dia, Configurações)
└── Util/                   Formatação e exportação de PDF
```

Todos os dados ficam salvos localmente no aparelho (SwiftData + UserDefaults), sem
necessidade de internet, conta ou servidor.

## Observação importante

Este projeto foi escrito e revisado cuidadosamente (sem um Mac disponível para compilar
e testar de fato, já que o ambiente onde ele foi gerado é Linux). A lógica de cálculo foi
verificada matematicamente, e o código segue os padrões usuais de SwiftUI + SwiftData.
Se o Xcode apontar algum erro de compilação na primeira vez que abrir, me envie a
mensagem de erro (ou print da tela) que eu corrijo rapidamente.
