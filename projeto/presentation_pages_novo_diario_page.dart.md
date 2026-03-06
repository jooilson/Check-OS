# novo_diario_page.dart
(c:/Projetos/checkos/lib/presentation/pages/novo_diario_page.dart)

# Descricao Geral
Pagina para criar novo Diario de Bordo.

# Responsabilidade no Sistema
Formulario para registro de diario associado a uma OS.

# Dependencias
- flutter/material.dart
- checkos/data/models/diario_model.dart
- checkos/data/repositories/diario_repository.dart
- checkos/data/repositories/os_repository.dart

# Campos do Formulario
- Numero OS (referencia)
- Numero Diario (auto-gerado)
- Data
- Nome Cliente
- Servico
- Relato Cliente
- Responsavel
- KM Inicial/Final
- Intervalo
- Observacoes
- Assinatura

# Fluxo
1. Seleciona OS existente
2. Preenche formulario
3. DiarioRepository.addDiario()
4. Atualiza total KM da OS

# Integracao
- DiarioRepository: addDiario()
- OsRepository: calcularAtualizarTotalKm()
- DiarioModel: dados do formulario

