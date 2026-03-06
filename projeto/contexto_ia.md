# Contexto para IAs - Projeto CheckOS

## Visão Geral do Projeto

O **CheckOS** é um sistema de gestão de Ordens de Serviço (OS) e Diários de Bordo desenvolvido em Flutter com Firebase como backend. O sistema permite que empresas gerenciem suas ordens de serviço, funcionários, diários de bordo e clientes de forma centralizada.

## Stack Tecnológico

- **Frontend**: Flutter 3.x
- **Backend**: Firebase (Firestore, Auth, Storage, Cloud Messaging)
- **Estado**: Provider + ChangeNotifier
- **Arquitetura**: Clean Architecture (Domain, Data, Presentation)
- **Plataformas**: Android, iOS, Web, Windows

## Estrutura de Diretórios

```
lib/
├── app.dart                    # Widget raiz da aplicação
├── main.dart                   # Ponto de entrada
├── firebase_options.dart       # Configurações do Firebase
├── core/                       # Configurações globais
│   ├── constants/              # Cores, rotas, strings
│   ├── context/                # Auth e Employee contexts
│   ├── routes/                 # Gerenciador de rotas
│   ├── theme/                  # Temas (light/dark)
│   └── utils/                  # Logger
├── data/                       # Camada de dados
│   ├── models/                 # Modelos (Firestore)
│   └── repositories/           # Implementações
├── domain/                     # Camada de domínio
│   ├── entities/               # Entidades de negócio
│   └── repositories/           # Interfaces
├── presentation/               # Camada de apresentação
│   ├── pages/                  # Páginas/screens
│   └── widgets/                # Widgets reutilizáveis
├── services/                   # Serviços externos
└── utils/                      # Utilitários
```

## Conceitos Importantes

### Sistema de Roles
- **Owner**: Dono da empresa (criador inicial)
- **Admin**: Administrador com permissões completas
- **User**: Usuário comum com acesso limitado

### Coleções Firestore
- `users` - Usuários do sistema
- `employees` - Funcionários da empresa
- `companies` - Empresas cadastradas
- `os` - Ordens de serviço
- `diarios` - Diários de bordo
- `logs` - Auditoria de ações

### Fluxo de Autenticação
1. AuthWrapper verifica estado de autenticação
2. Se autenticado, busca dados do usuário
3. Se não tem empresa, redireciona para cadastro
4. Se autenticado e com empresa, vai para HomePage

### Gestão de OS
- OS contém: dados do cliente, serviço, responsáveis, KM, tempo, assinatura
- Cada OS pode ter múltiplos funcionários associados
- Pode gerar diários de bordo vinculados
- Suporte a imagens e assinaturas digitais

### Gestão de Diários
- Diários vinculados a OS existentes
- Registros de bordo com dados detalhados
- Possibilidade de anexar imagens

## Padrões de Código

### Models
- Herdam de Entity (Equatable)
- Métodos `fromFirestore()` e `toFirestore()`
- Métodos `copyWith()` para immutabilidade
- Validações no construtor

### Repositories
- Implementam interfaces do domain
- Usam FirebaseFirestore para operações
- Retornam Entities (não Models)

### Services
- Lógica de negócio complexa
- Integração com Firebase Auth
- Gerenciamento de permissões

### Pages/Widgets
- Usam Provider para estado
- Separação clara de UI e lógica
- Widgets reutilizáveis em presentation/widgets

## Regras de Negócio Principais

1. **Criação de Empresa**: Primeiro usuário se torna owner
2. **Permissões**: Only owner/admin podem gerenciar usuários
3. **OS**: Apenas users ativos podem criar OS
4. **Dados**: companyId é obrigatório para quase todas operações
5. **Soft Delete**: Usuários são desativados, não deletados

## Comandos Úteis

```bash
# Desenvolvimento
flutter run

# Build Android
flutter build apk --release

# Build Web
flutter build web

# Análise
flutter analyze
```

## Pontos de Atenção

1. **companyId**: Verificar sempre existência antes de operações
2. **Sincronização**: Employees e Users podem ter dados duplicados
3. **Firebase Rules**: Regras de segurança configuradas em firestore.rules
4. **App Check**: Desabilitado em desenvolvimento
5. **Push Notifications**: Requer configuração adicional

## Para Nova IA Trabalhar no Projeto

1. Leia `arquitetura_do_sistema.md` para visão geral
2. Consulte arquivos .md correspondentes para detalhes
3. Use os modelos (data/models/) como referência
4. Entenda o fluxo em core/context/
5. Use AppRouter para navegação
6. AuthService para autenticação
7. PermissionService para permissões

---

**Última atualização**: Documentação gerada automaticamente
**Versão do Projeto**: 1.0.0+1

