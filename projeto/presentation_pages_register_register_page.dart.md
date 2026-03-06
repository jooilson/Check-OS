# register_page.dart
(c:/Projetos/checkos/lib/presentation/pages/register/register_page.dart)

# Descrição Geral
Página de registro/cadastro de nova empresa e usuário owner.

# Responsabilidade no Sistema
Permite que novos usuários criem uma conta e empresa simultaneamente (onboarding inicial).

# Dependências
- checkos/core/constants/app_route_names.dart
- checkos/services/firebase/auth_service.dart
- firebase_auth
- flutter/material.dart

# Classes
- **RegisterPage** (extends StatefulWidget)
  - Página de registro

- **_RegisterPageState** (State<RegisterPage>)
  - Estado da página

# Propriedades
- _formKey: GlobalKey<FormState>
- _nameController: TextEditingController
- _emailController: TextEditingController
- _passwordController: TextEditingController
- _confirmPasswordController: TextEditingController
- _companyNameController: TextEditingController
- _companyCNPJController: TextEditingController
- _authService: AuthService
- _isLoading: bool
- _errorMessage: String?

# Métodos / Funções
- **_signUp()** (Future<void>)
  - Finalidade: Criar conta e empresa
  - Valida formulário
  - Chama AuthService.createAccountWithCompany()
  - Redireciona para home

- **_getErrorMessage(String code)** (String)
  - Finalidade: Converter código de erro em mensagem

- **build(BuildContext)** (Widget)
  - Formulário com campos:
    - Nome, Email, Senha, Confirmar Senha
    - Nome da Empresa, CNPJ (opcional)

# Fluxo de Execução
1. Usuário preenche formulário
2. _signUp() valida dados
3. AuthService.createAccountWithCompany() cria:
   - Usuário no Firebase Auth
   - Empresa no Firestore
   - Documento do usuário com role owner
4. Redireciona para home

# Integração com o Sistema
- AuthService: Cria usuário e empresa
- Firebase Auth: Autenticação
- Firestore: Persistência

# Estrutura de Dados
- TextEditingControllers para campos de formulário

# Regras de Negócio
- Primeiro usuário é sempre owner
- CNPJ é opcional
- Senha mínima 6 caracteres

# Pontos Críticos
- Cria empresa automaticamente
- Usuário recebe role owner

# Melhorias Possíveis
- Adicionar mais campos de empresa
- Validação de CNPJ

