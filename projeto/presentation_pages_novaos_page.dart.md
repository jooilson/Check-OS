# novaos_page.dart
(c:/Projetos/checkos/lib/presentation/pages/novaos_page.dart)

# Descricao Geral
Pagina para criar ou editar Ordem de Servico.

# Responsabilidade no Sistema
Formulario completo para registro de OS.

# Dependencias
- flutter/material.dart
- checkos/data/models/os_model.dart
- checkos/data/repositories/os_repository.dart

# Campos do Formulario
- Numero OS (auto-gerado)
- Nome do Cliente
- Servico
- Relato do Cliente
- Responsavel
- Tem Pedido? (checkbox)
- Numero do Pedido
- Funcionarios (lista)
- KM Inicial
- KM Final
- Hora Inicio
- Intervalo Inicio/Fim
- Hora Termino
- Garantia (checkbox)
- Pendente (checkbox)
- Descricao Pendente
- Relatorio Tecnico
- Assinatura (base64)
- Imagens (lista URLs)

# Fluxo
1. Validacao do formulario
2. OsRepository.addOs() ou updateOs()
3. Redireciona para lista

# Integracao
- OsRepository: addOs(), updateOs()
- OsModel: dados do formulario
- EmployeeRepository: lista de funcionarios

