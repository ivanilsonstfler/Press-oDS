# apppresao

A new Flutter project.
# Controle de Pressão Arterial (Flutter)

Aplicativo mobile para **registro e acompanhamento de pressão arterial**, inspirado em uma versão anterior feita com **Flask + SQLAlchemy** e agora totalmente convertida para **Dart/Flutter**, rodando **offline** com banco local.

O app permite:

- Cadastro e login de usuários  
- Registro de medições (sistólica/diastólica)  
- Classificação automática (Normal, Elevada, Estágio 1, Estágio 2)  
- Campo para notas e remédios tomados  
- Registro de “como estou me sentindo” (👍 / 😐 / 👎)  
- Dashboard com resumo (média, máxima, mínima, última medição)  
- Gráfico da evolução da pressão  
- Modo consulta (para mostrar os dados ao médico)  
- Exportar medições em **CSV** (pode enviar por WhatsApp, e-mail etc.)  

---

## Tecnologias utilizadas

- **Flutter** (SDK ≥ 3.10.0)  
- **Dart**  
- **Hive / hive_flutter** – banco de dados local (Android + Web)  
- **provider** – gerenciamento simples de estado  
- **intl** – formatação de datas  
- **crypto** – hash de senha (SHA-256)  
- **fl_chart** – gráficos (sistólica/diastólica)  
- **share_plus** – compartilhar CSV (e futuros backups)  

---

## Estrutura do projeto

```text
lib/
  main.dart

  models/
    user.dart          # Modelo de usuário
    medicao.dart       # Modelo de medição de pressão

  db/
    # (vazio, app_database.dart foi substituído por Hive)

  repositories/
    user_repository.dart     # CRUD de usuário em Hive
    medicao_repository.dart  # CRUD de medições em Hive

  providers/
    auth_provider.dart       # Lida com login, logout, usuário atual

  screens/
    login_screen.dart        # Tela de login
    register_screen.dart     # Tela de cadastro
    dashboard_screen.dart    # Dashboard (medições + gráfico, bottom nav)
    profile_screen.dart      # Tela de perfil (dados pessoais)
    pressure_chart_tab.dart  # Aba de gráfico dentro do dashboard
    consulta_screen.dart     # "Modo consulta", lista limpa pra médico

  utils/
    export_utils.dart        # Gera CSV a partir das medições


Funcionalidades principais
Autenticação

Cadastro com:

nome de usuário

e-mail

senha (armazenada com hash SHA-256 em Hive)

Login / logout com AuthProvider.

Medições de pressão

Campos:

Sistólica (mmHg)

Diastólica (mmHg)

Notas (opcional)

Remédios tomados (opcional)

Humor (bem / ok / mal)

Classificação automática:

Normal

Elevada

Hipertensão Estágio 1

Hipertensão Estágio 2

Validação de faixas (ex.: sistólica entre 50–300, diastólica entre 30–200).

Dashboard

Saudação com o nome de usuário.

Card de resumo:

Média sist/diast

Máxima e mínima

Última medição

Card “Nova medição” com botão de ajuda:

Explica as faixas de pressão (normal, elevada, estágios de hipertensão).

Campo “Como você está se sentindo?” (👍 😐 👎).

Filtro por intervalo de datas (Início/Fim).

Lista de medições com:

Data/hora

Status com cor (verde, amarelo, laranja, vermelho)

Humor

Notas e remédios (se preenchidos).

Gráfico

Aba separada no bottom navigation: Medições / Gráfico.

Gráfico de linha com:

Curva da sistólica

Curva da diastólica

Eixo X: datas das medições.

Tooltip ao tocar nos pontos (data + valores).

Modo consulta

Acesso pelo menu da AppBar (⋮ → Modo consulta).

Tela limpa, sem botões de edição:

Mostra medições com data/hora, status, notas, remédios e humor.

Pensada para mostrar ao médico durante a consulta.

Exportar CSV

Menu da AppBar (⋮ → Exportar CSV).

Gera um CSV com colunas:

data_hora,sistolica,diastolica,status,humor,notas,remedios


Usa share_plus para abrir o menu de compartilhamento do sistema
(WhatsApp, e-mail, Google Drive etc.).

Requisitos

Flutter SDK 3.10.0 ou superior

Android Studio ou VS Code com extensão Flutter

Emulador Android (AVD) ou dispositivo físico com modo desenvolvedor ativado

Configuração do ambiente

Verifique se o Flutter está instalado:

flutter doctor


Clone o projeto (ou copie a pasta para sua máquina).

Dentro da pasta do projeto:

flutter pub get

Executando o app
Android (emulador ou dispositivo físico)

Inicie um emulador pelo Android Studio (AVD) ou conecte um dispositivo físico.

Liste os dispositivos:

flutter devices


Rode o app:

flutter run -d <id_do_dispositivo>

Web (Chrome)
flutter run -d chrome


A versão Web é útil para testes rápidos, mas a interface foi pensada principalmente para mobile.

Geração de APK (Android)

Para gerar um APK de teste:

flutter build apk


O arquivo será criado em:

build/app/outputs/flutter-apk/app-release.apk

Próximos passos / ideias futuras

Notificações locais para lembrar o usuário de medir a pressão.

Proteção por PIN ou biometria na abertura do app.

Backup completo dos dados em JSON e restauração em outro aparelho.

Múltiplos perfis (ex.: medir pressão de diferentes familiares).