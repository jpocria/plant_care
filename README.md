# 🌱 Plant Care - Documentação Técnica

Um aplicativo de monitoramento inteligente de plantas construído com **Flutter** e **Firebase**. Este projeto demonstra boas práticas de arquitetura, padrões de design e integração com serviços em nuvem. Documentação criada para fins de estudo.

---

## 📋 Índice

1. [Stack Tecnológico](#-stack-tecnológico)
2. [Arquitetura](#-arquitetura)
3. [Integrações Principais](#-integrações-principais)
4. [Estrutura de Diretórios](#-estrutura-de-diretórios)
5. [Plataformas Suportadas](#-plataformas-suportadas)
6. [Decisões de Design](#-decisões-de-design)

---

## 🛠️ Stack Tecnológico

| Componente | Tecnologia | Versão | Propósito |
|-----------|-----------|--------|----------|
| **Linguagem** | Dart | ≥3.0.0, <4.0.0 | Linguagem nativa do Flutter |
| **Framework** | Flutter | (conforme pubspec.yaml) | Framework UI para múltiplas plataformas |
| **Database** | Cloud Firestore | 5.4.4 | Banco de dados NoSQL em tempo real |
| **Autenticação** | Firebase Authentication | 5.3.1 | Gerenciamento seguro de usuários |
| **Storage** | Firebase Storage | 12.3.2 | Armazenamento de arquivos em nuvem |
| **Push Notifications** | Firebase Messaging | 15.1.3 | Notificações push em tempo real |
| **Gerenciamento de Estado** | Provider | 6.1.1 | Reatividade e notificação de mudanças |
| **Injeção de Dependência** | GetIt | 7.6.7 | Instância global de serviços |
| **Navegação** | Go Router | 13.0.0 | Roteamento robusto e type-safe |

### Por que essas escolhas?

- **Dart/Flutter**: Cross-platform (Android, iOS, Web) com Hot Reload para desenvolvimento rápido
- **Firebase**: Backend gerenciado (sem servidor para manter), escalável e com recursos prontos
- **Provider**: Simples, performático e ideal para apps de médio porte
- **GetIt**: Service Locator para desacoplamento e testabilidade
- **Go Router**: Navegação declarativa, suporta deep linking e web routing

---

## 🏗️ Arquitetura

O projeto segue o padrão **Clean Architecture** com 3 camadas principais:

```
┌─────────────────────────────────────────────────────────────┐
│  PRESENTATION (Apresentação)                                │
│  ├── Screens   → Telas/Features da aplicação                │
│  ├── Widgets   → Componentes reutilizáveis (UI)             │
│  ├── Theme     → Tema, cores, estilos globais               │
│  └── Router    → Configuração de rotas e navegação          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  DATA (Camada de Dados)                                     │
│  ├── Repositories → Abstração de dados (contrato)           │
│  └── Models       → Estruturas de dados do domínio          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  CORE (Camada de Negócio)                                   │
│  └── Services  → Lógica de negócio (Firebase, APIs)         │
└─────────────────────────────────────────────────────────────┘
```

### Por que essa arquitetura?

✅ **Separação de Responsabilidades**: Cada camada tem um único propósito  
✅ **Testabilidade**: Fácil criar testes unitários e mockar dependências  
✅ **Manutenibilidade**: Mudanças em uma camada não afetam as outras  
✅ **Escalabilidade**: Fácil adicionar novos features seguindo o padrão  

### Fluxo de Dados

```
1. User interage com uma Screen (Presentation)
   ↓
2. Screen chama método do Repository (Data)
   ↓
3. Repository chama Service correspondente (Core)
   ↓
4. Service executa operação (Firebase, API, etc)
   ↓
5. Resultado volta para Repository → Screen → UI atualizada
```

---

## 🔌 Integrações Principais

### 1️⃣ Firebase (Backend Gerenciado)

**Pacotes usados**:
- `firebase_core: ^3.6.0` — Inicialização do Firebase
- `cloud_firestore: ^5.4.4` — Banco de dados NoSQL
- `firebase_auth: ^5.3.1` — Autenticação de usuários
- `firebase_storage: ^12.3.2` — Upload/download de arquivos
- `firebase_messaging: ^15.1.3` — Push notifications
- `firebase_app_check: ^0.3.1+4` — Segurança (validar requisições legítimas)

**Como foi integrado**:

No `main.dart`, o Firebase é inicializado antes de rodar a app:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

O `firebase_options.dart` (gerado automaticamente pela FlutterFire CLI) contém credenciais para cada plataforma (Android, Web). Isso permite:
- ✅ Diferentes projetos Firebase por plataforma (segurança)
- ✅ Configuração automática sem hardcoding de chaves

**Serviços Firebase implementados**:
- `AuthService` — Login, registro, logout com Google Sign-In
- `FirestoreService` — CRUD de dados (plantas, alertas, usuários)
- `StorageService` — Upload de fotos de plantas
- `NotificationService` — Receber e exibir notificações push

**Por que Firebase?**
- Sem necessidade de gerenciar servidor próprio
- Escalável automaticamente
- Recursos prontos: autenticação, banco de dados, storage, notificações
- Excelente para prototipagem e MVPs

---

### 2️⃣ Autenticação com Google Sign-In

**Pacote**: `google_sign_in: ^6.2.1`

**Implementação**:
- Usuários fazem login via Google (botão "Entrar com Google")
- Firebase Authentication gerencia sessão
- Token armazenado localmente (Firebase SDK cuida automaticamente)
- Logout limpa credenciais

**Por que?**
- UX melhor (sem criar senha)
- Segurança: credenciais gerenciadas pelo Google
- Funciona em Web, Android e iOS

---

### 3️⃣ Gerenciamento de Estado com Provider

**Pacote**: `provider: ^6.1.1`

**Como usa**:

Repositories são `ChangeNotifier`, ou seja, notificam listeners quando dados mudam:

```dart
// No main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => sl<AuthRepository>()),
    ChangeNotifierProvider(create: (_) => sl<PlantRepository>()),
  ],
  child: PlantCareApp(),
)
```

**Em uma Screen**:
```dart
// Escuta mudanças
final plants = context.watch<PlantRepository>().plants;
// Executa ação sem reconstruir
context.read<PlantRepository>().addPlant(newPlant);
```

**Por que Provider?**
- ✅ Simples e intuitivo para iniciantes
- ✅ Performance: rebuild apenas widgets afetados
- ✅ Funciona bem com arquitetura Clean Architecture
- ✅ Suporta múltiplos providers

---

### 4️⃣ Injeção de Dependência com GetIt

**Pacote**: `get_it: ^7.6.7`

**Implementação**:

```dart
// Registro de serviços (um Service Locator global)
final GetIt sl = GetIt.instance;

void _setupDependencies() {
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<AuthService>()),
  );
}

// Uso em qualquer lugar
final auth = sl<AuthService>();
```

**Por que GetIt?**
- ✅ Evita passar dependências por construtor (reduces boilerplate)
- ✅ Singleton global — uma única instância compartilhada
- ✅ Fácil de mockar para testes
- ✅ Desacopla classes (uma classe não precisa saber como criar a outra)

---

### 5️⃣ Navegação com Go Router

**Pacote**: `go_router: ^13.0.0`

**Configurado em**: `lib/presentation/router/app_router.dart`

**Features**:
- ✅ Declarativo (rotas definidas em um só lugar)
- ✅ Type-safe (sem string magic)
- ✅ Deep linking automático
- ✅ Web URL suportado

**Por que Go Router?**
- Padrão atual recomendado pela comunidade Flutter
- Substitui Navigator 1.0 (mais complexo)
- Integra bem com web

---

### 6️⃣ Notificações com Flutter Local Notifications + Firebase Messaging

**Pacotes**:
- `firebase_messaging: ^15.1.3` — Receber mensagens push
- `flutter_local_notifications: ^16.3.0` — Exibir notificações

**Como funciona**:

1. App recebe mensagem do Firebase Cloud Messaging (FCM)
2. `NotificationService` intercepta e exibe com `flutter_local_notifications`
3. Usuário toca na notificação → app navega para tela relevante

**Por que dois pacotes?**
- `firebase_messaging`: Recebe mensagens (cloud) — infraestrutura
- `flutter_local_notifications`: Exibe no dispositivo — UI
- Separação: backend envia via FCM, app exibe localmente

---

### 7️⃣ Conectividade com Connectivity Plus

**Pacote**: `connectivity_plus: ^5.0.2`

**Uso**:
- Detecta se device tem internet (WiFi, dados móveis, offline)
- Services podem usar para decidir se sincronizam com servidor
- Útil para offline-first apps

---

### 8️⃣ Utilitários

| Pacote | Versão | Uso |
|--------|--------|-----|
| `intl` | 0.19.0 | Internacionalização (datas, horas) |
| `uuid` | 4.3.3 | Gerar IDs únicos |
| `logger` | 2.0.2+1 | Logs formatados para debug |
| `shared_preferences` | 2.2.2 | Armazenar dados simples localmente |
| `crypto` | 3.0.3 | Hash e criptografia |
| `path` | 1.9.0 | Manipular paths (abstrair SO) |
| `cached_network_image` | 3.3.1 | Cachear imagens da internet |
| `image_picker` | 1.0.7 | Selecionar imagens (galeria/câmera) |
| `shimmer` | 3.0.0 | Loading shimmer effect |

---

## 📁 Estrutura de Diretórios

```
lib/
├── main.dart
│   └── Ponto de entrada da app
│       • Inicializa Firebase
│       • Configura dependências (GetIt)
│       • Configura Provider
│       • Define MaterialApp
│
├── core/
│   └── services/
│       ├── auth_service.dart       → Lógica de autenticação
│       ├── firestore_service.dart  → Operações Firestore (CRUD)
│       ├── storage_service.dart    → Upload/download arquivos
│       ├── notification_service.dart → Notificações push
│       └── connectivity_service.dart → Detectar conexão
│
├── data/
│   ├── models/
│   │   ├── user_model.dart    → Struct de usuário
│   │   ├── plant_model.dart   → Struct de planta
│   │   └── alert_model.dart   → Struct de alerta
│   │
│   └── repositories/
│       ├── auth_repository.dart    → Abstrai AuthService (ChangeNotifier)
│       ├── plant_repository.dart   → Abstrai Firestore + Storage
│       └── alert_repository.dart   → Abstrai Firestore de alertas
│
└── presentation/
    ├── theme/
    │   └── app_theme.dart      → Cores, tipografia, tema Material
    │
    ├── router/
    │   └── app_router.dart     → Configuração de rotas (Go Router)
    │
    ├── screens/
    │   ├── auth/               → Login, registro
    │   ├── home/               → Tela inicial
    │   ├── plant/              → Adicionar/editar/detalhar planta
    │   ├── alerts/             → Histórico de alertas
    │   └── profile/            → Perfil do usuário
    │
    └── widgets/
        ├── custom_button.dart       → Botão reutilizável
        ├── custom_text_field.dart   → TextField customizado
        ├── loading_overlay.dart     → Overlay de loading
        ├── plant_card.dart          → Card exibindo planta
        └── stat_card.dart           → Card de estatísticas
```

### Fluxo de Estrutura

```
Usuario interage com Screen (ex: plant/add_plant_screen.dart)
    ↓
Screen usa context.read/watch PlantRepository (Provider)
    ↓
PlantRepository chama FirestoreService e StorageService (GetIt)
    ↓
Services executam operação (Firebase)
    ↓
Repository notifica ouvintes (ChangeNotifier)
    ↓
Screen reconstrói com novos dados
```

---

## 🌍 Plataformas Suportadas

| Plataforma | Configurado | Status Firebase | Notas |
|-----------|-----------|-----------------|-------|
| 🤖 **Android** | ✅ Sim | ✅ Completo | `google-services.json` presente |
| 🌐 **Web** | ✅ Sim | ✅ Completo | Firestore no navegador |
| 🍎 **iOS** | ❌ Não | ❌ Não | Pasta estruturada, mas sem Firebase |
| 💻 **macOS** | ❌ Não | ❌ Não | Pasta estruturada, mas sem Firebase |
| 🪟 **Windows** | ❌ Não | ❌ Não | Pasta estruturada, mas sem Firebase |
| 🐧 **Linux** | ❌ Não | ❌ Não | Pasta estruturada, mas sem Firebase |

Para adicionar iOS, rodar: `flutterfire configure` e selecionar iOS.

---

## 💡 Decisões de Design

### 1. Por que Clean Architecture?

A arquitetura em 3 camadas (Core, Data, Presentation) foi escolhida porque:

- **Testabilidade**: Services e Repositories podem ser mockados facilmente
- **Escalabilidade**: Adicionar novo feature segue o mesmo padrão
- **Manutenibilidade**: Mudança no Firebase não afeta Presentation

Exemplo: Se trocar de Firestore para SQL, apenas Services mudam.

### 2. Por que Repository Pattern?

```dart
// Ruim: Screen chama Firebase diretamente
plants = await firestore.collection('plants').get();

// Bom: Screen chama Repository (abstração)
plants = await repository.getPlants();
```

O Repository **abstrai** onde os dados vêm (Firestore, API, local) da View. Se depois decidir trazer dados de uma API REST, só muda o Repository.

### 3. Por que ChangeNotifier?

Repositories herdam de `ChangeNotifier` para:
- Notificar Screens quando dados mudam
- Screens se atualizam automaticamente
- Sem precisa de callbacks aninhados (callback hell)

### 4. Offline Support (Considerar)

Com `shared_preferences` + `connectivity_plus`, é possível:
- Armazenar dados localmente quando offline
- Sincronizar quando internet voltar
- UX melhor mesmo sem conexão

Cloud Firestore também tem modo offline nativo.

### 5. Por que GetIt para GetIt?

Ao invés de:
```dart
// Ruim: passar por construtor
class PlantRepository {
  PlantRepository(this.firestore, this.storage, this.connectivity);
}
```

Usamos:
```dart
// Bom: GetIt cuida
final firestore = sl<FirestoreService>();
```

Benefícios: menos boilerplate, fácil testar (trocar sl<T> por mock).

---

## 🎓 Para Iniciantes em Flutter

### Conceitos-chave aprendidos aqui:

1. **Padrão MVC/MVVM/Clean Architecture** → Organizar código grande
2. **Provider + ChangeNotifier** → Reatividade sem setState
3. **Service Locator (GetIt)** → Injeção de dependência
4. **Repository Pattern** → Abstração de dados
5. **Firebase** → Backend sem manter servidor
6. **Rotas com Go Router** → Navegação moderna
7. **Modelos vs Repositories** → Models = dados, Repositories = lógica

### Próximos passos para aprender:

- [ ] Ler sobre Clean Architecture
- [ ] Entender Provider (watch vs read)
- [ ] Explorar Firebase Console
- [ ] Fazer testes unitários nos Services
- [ ] Adicionar suporte a iOS (via `flutterfire configure`)

---

## 📚 Referências

- [Flutter Documentation](https://flutter.dev)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [GetIt Package](https://pub.dev/packages/get_it)
- [Go Router Package](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Última atualização**: 12 de maio de 2026  
**Versão do Projeto**: 1.0.0+1
