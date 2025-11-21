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
