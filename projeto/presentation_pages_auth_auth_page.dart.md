# auth_page.dart
(c:/Projetos/checkos/lib/presentation/pages/auth/auth_page.dart)

# Descricao Geral
Pagina de autenticacao (login).

# Responsabilidade no Sistema
Interface para login de usuarios.

# Campos
- Email
- Senha
- Botao Login
- Link Esqueceu senha
- Link Cadastrar

# Fluxo
1. Usuario preenche email/senha
2. AuthService.signInWithEmailAndPassword()
3. Busca dados do usuario
4. Redireciona para home ou cadastro empresa

# Integracao
- AuthService: autenticacao
- AuthContext: estado global

