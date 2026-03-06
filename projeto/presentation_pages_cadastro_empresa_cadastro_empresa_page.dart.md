# cadastro_empresa_page.dart
(c:/Projetos/checkos/lib/presentation/pages/cadastro_empresa/cadastro_empresa_page.dart)

# Descrição Geral
Página de cadastro de empresa para novos usuários.

# Responsabilidade no Sistema
Coleta dados da empresa (onboarding) após primeiro login.

# Dependências
- flutter/material.dart
- provider
- checkos/data/repositories/company_repository.dart
- checkos/services/firebase/auth_service.dart

# Campos do Formulário
- Nome da empresa (obrigatório)
- CNPJ (opcional)
- Telefone (opcional)
- Endereço (opcional)
- Email (opcional)

# Fluxo
1. Usuário faz primeiro login
2. companyId null detected
3. Exibe CadastroEmpresaPage
4. CompanyRepository.createCompany()
5. Link usuário-empresa
6. Redireciona para HomePage

# Integração
- CompanyRepository: criar empresa
- AuthService: linkUserToCompany
- AuthContext: atualizar dados

