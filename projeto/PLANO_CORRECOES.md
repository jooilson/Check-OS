# 📋 PLANO DE CORREÇÕES - CHECKOS

## Status: Em Andamento

### ✅ Concluído
- [x] Auditoria completa do sistema
- [x] Implementar EmployeeContext/Provider (criado lib/core/context/employee_context.dart)
- [x] Integração do EmployeeContext no app.dart
- [x] Correção dos logs em novaos_page.dart (CREATE_OS e UPDATE_OS)
- [x] Correção dos logs em detalhes_os_page.dart (DELETE_OS)
- [x] Configurar EmployeeContext no login (definir funcionário atual após autenticação)
- [x] Limpar EmployeeContext no logout (config_page.dart)
- [x] Corrigir duplicação de coleções de funcionários (auth_service.dart)
- [x] Sincronização de coleções (employee_repository.dart)

### ⏳ Pendente (Refatoração Avançada)
- [ ] Adicionar campo funcionariosIds aos modelos OS e Diario (requer mudanças significativas nos modelos e formulários)

---

## Resumo das Correções Realizadas

### Fase 1: EmployeeContext ✅
- `lib/core/context/employee_context.dart` - Criado
- `lib/app.dart` - Integração realizada

### Fase 2: Logs de Auditoria ✅
- `lib/presentation/pages/novaos_page.dart` - CREATE_OS e UPDATE_OS
- `lib/presentation/pages/detalhes_os_page.dart` - DELETE_OS

### Fase 3: Login/Logout ✅
- `lib/presentation/pages/login/login_page.dart` - Define contexto após login
- `lib/presentation/pages/config_page.dart` - Limpa contexto no logout

### Fase 4: Unificação de Coleções ✅
- `lib/services/firebase/auth_service.dart` - employees como fonte principal
- `lib/data/repositories/employee_repository.dart` - Sincronização mantida

---

## Pendente: Campo funcionariosIds

Esta é uma refatoração mais complexa que envolve:
1. Adicionar campo `funcionariosIds` (List<String>) aos modelos OS e Diario
2. Atualizar formulários para capturar IDs dos funcionários
3. Atualizar a lógica de exibição para usar IDs em vez de nomes

**Nota:** Esta mudança requer alterações significativas na interface do usuário e na lógica de negócio.

