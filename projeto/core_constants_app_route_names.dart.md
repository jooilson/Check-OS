# app_route_names.dart
(c:/Projetos/checkos/lib/core/constants/app_route_names.dart)

# Descrição Geral
Arquivo de constantes que define todos os nomes de rotas da aplicação. Facilita a navegação e evita erros de digitação.

# Responsabilidade no Sistema
Centralizar todos os nomes de rotas da aplicação em um único local para fácil manutenção e referência.

# Dependências
Nenhuma dependência externa.

# Classes
Nenhuma classe definida. Apenas constantes.

# Métodos / Funções
Nenhum método definido. Apenas constantes estáticas.

# Constantes Definidas

## Rotas Principais
- `authWrapper` = '/'
- `home` = '/home'
- `login` = '/login'
- `register` = '/register'

## Rotas de OS
- `novaOs` = '/nova-os'
- `lista` = '/lista'
- `detalhesOs` = '/detalhes-os'
- `editOs` = '/edit-os'

## Rotas de Diários
- `novoDiario` = '/novo-diario'
- `editarDiario` = '/editar-diario'

## Rotas de Funcionários
- `employeeManagement` = '/employee-management'
- `addEmployee` = '/add-employee'
- `editEmployee` = '/edit-employee'

## Rotas de Configurações
- `configuracoes` = '/configuracoes'
- `logs` = '/logs'
- `importExport` = '/import-export'

## Rotas de Cadastro Empresa
- `cadastroEmpresa` = '/cadastro-empresa'

# Fluxo de Execução
Constantes são usadas em AppRouter.generateRoute e Navigator.pushNamed.

# Integração com o Sistema
- AppRouter: Usa estas constantes para identificação de rotas
- Páginas: Usam para Navigator.pushNamed

# Estrutura de Dados
Nenhuma estrutura de dados.

# Regras de Negócio
- Todas as rotas devem ter uma constante correspondente
- Construtor privado (AppRouteNames._()) impede instância

# Pontos Críticos
- Rota "/" (authWrapper) é a entrada principal do app

# Melhorias Possíveis
- Documentar cada rota com comentários
- Adicionar validação de rotas

# Observações Técnicas
- Classe com construtor privado para evitar instanciação
- Organização em grupos lógicos por funcionalidade

