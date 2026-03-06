# Contexto Global para IAs - Projeto CheckOS

## Visão Geral do Projeto

**CheckOS** é um sistema de gestão de Ordens de Serviço (OS) e Diários de Bordo desenvolvido em Flutter com Firebase. Permite que empresas gerenciem ordens de serviço, funcionários, diários de bordo e clientes.

---

## Stack Tecnológico

| Tecnologia | Versão/Nota |
|-----------|-------------|
| Flutter | 3.x |
| Firebase | Auth, Firestore, Storage, Messaging |
| Estado | Provider + ChangeNotifier |
| Arquitetura | Clean Architecture (parcial) |
| Plataformas | Android, iOS, Web, Windows |

---

## Estrutura de Diretórios

```
lib/
├── app.dart                    # Widget raiz
├── main.dart                   # Entry point
├── firebase_options.dart       # Config Firebase
├── core/                       # Configurações globais
│   ├── constants/              # Cores, rotas, strings
│   ├── context/               # Auth e Employee contexts
│   ├── routes/                # Gerenciador de rotas
│   ├── theme/                 # Temas
│   └── utils/                 # Logger
├── data/                       # Camada de dados
│   ├── models/                # Models Firestore
│   └── repositories/          # Implementações
├── domain/                     # Camada de domínio
│   ├── entities/              # Entidades
│   └── repositories/          # Interfaces
├── presentation/               # Camada de apresentação
│   ├── pages/                  # Páginas
│   └── widgets/                # Widgets
├── services/                   # Serviços externos
└── utils/                      # Utilitários
```

---

## Entidades Principais

### Usuário (User)
- **Coleção**: `users`
- **Campos**: id, email, name, companyId, role (owner/admin/user), isOwner, isActive
- **Roles**: owner (dono), admin (administrador), user (comum)

### Empresa (Company)
- **Coleção**: `companies`
- **Campos**: id, name, cnpj, phone, address, email, logoUrl, plan, ownerId

### Funcionário (Employee)
- **Coleção**: `employees`
- **Campos**: id, name, email, role, phone, cpf, companyId, isActive

### Ordem de Serviço (OS)
- **Coleção**: `os`
- **Campos**: numeroOs, nomeCliente, servico, relatoCliente, responsavel, kmInicial, kmFinal, horaInicio, horaTermino, osfinalizado, garantia, pendente, relatoTecnico, assinatura, imagens, companyId

### Diário de Bordo
- **Coleção**: `diarios`
- **Campos**: osId, numeroOs, data e campos similares a OS

---

## Fluxos Principais

### 1. Autenticação
```
App → AuthWrapper → FirebaseAuth stream
  ├── Logado + empresa → HomePage
  ├── Logado + sem empresa → CadastroEmpresaPage
  └── Não logado → AuthPage (Login)
```

### 2. Criar OS
```
HomePage → NovaOsPage → Formulário → OsRepository.addOs() → Firestore
```

### 3. Gerenciar Funcionários
```
HomePage → EmployeeManagementPage → EmployeeAddPage → AuthService.registerEmployee()
```

---

## Padrões de Código

### Models
- Herdam de Entity (Equatable)
- Métodos `fromFirestore()` e `toFirestore()`
- Métodos `copyWith()` para immutabilidade

### Repositories
- Acessam FirebaseFirestore diretamente
- Retornam Entities
- Poucos têm interface definida

### Services
- Lógica de negócio complexa
- Integração com Firebase Auth e outros serviços

### Pages/Widgets
- Provider para estado
- Separação UI e lógica
- Widgets reutilizáveis

---

## Regras de Negócio

1. **Criação de Empresa**: Primeiro usuário se torna owner
2. **Permissões**: owner/admin podem gerenciar usuários
3. **OS**: Apenas usuários ativos podem criar OS
4. **companyId**: Obrigatório para quase todas operações
5. **Soft Delete**: Usuários são desativados, não deletados

---

## Pontos de Atenção

1. **companyId**: Pode ser null em UserModel - verificar antes de usar
2. **Duplicação**: Employees e Users podem ter dados duplicados
3. **Regras Firestore**: Estão básicas - permitem muito acesso
4. **App Check**: Desabilitado em desenvolvimento
5. **Push Notifications**: Requer configuração adicional

---

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

---

## Documentação Relacionada

| Arquivo | Descrição |
|---------|-----------|
| arquitetura_do_sistema.md | Visão geral completa |
| mapa_projeto.md | Estrutura de pastas |
| fluxo_autenticacao.md | Detalhes de login/cadastro |
| fluxo_firestore.md | Estrutura do banco |
| mapa_telas.md | Todas as telas |
| mapa_rotas.md | Sistema de navegação |
| analise_arquitetural.md | Problemas identificados |
| melhorias_arquitetura.md | Recomendações |

---

## Para Nova IA Trabalhar no Projeto

1. Leia `contexto_global_ia.md` para visão geral
2. Consulte `arquitetura_do_sistema.md` para detalhes técnicos
3. Use arquivos `*.md` correspondentes para entender arquivos específicos
4. Use `mapa_rotas.md` para navegar entre telas
5. Referencie `analise_arquitetural.md` para evitar problemas conhecidos

---

## Estado Atual do Projeto

- **Versão**: 1.0.0+1
- **Estágio**: Em produção (com limitações)
- **Manutenção**: Ativa
- **Documentação**: Completa

---

## Contato/Manutenção

Este projeto foi documentado automaticamente para facilitar manutenção e evolução. Para dúvidas, consulte a documentação específica ou os arquivos `.md` correspondentes.

---

**Última atualização**: Documentação gerada automaticamente
**Versão do Projeto**: 1.0.0+1

