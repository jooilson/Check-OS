# Sistema de Diários - Checklist OS

## Funcionalidades Implementadas

Implementei um sistema completo de gerenciamento de diários para cada Ordem de Serviço (OS). Agora você pode visualizar, criar, editar e deletar diários dentro dos detalhes de cada OS.

## O que foi criado:

### 1. **Modelo de Dados** (`lib/data/models/diario_model.dart`)
- Classe `DiarioModel` com campos:
  - `osId` e `numeroOs` - Referência à OS
  - `nomeCliente` - Nome do cliente
  - `data` - Data do diário
  - `kmInicial` e `kmFinal` - Quilometragem
  - `horaInicio`, `intervaloInicio`, `intervaloFim`, `horaTermino` - Horários
  - `createdAt` e `updatedAt` - Timestamps

### 2. **Repositório** (`lib/data/repositories/diario_repository.dart`)
- `addDiario()` - Adicionar novo diário
- `updateDiario()` - Atualizar diário existente
- `deleteDiario()` - Deletar diário
- `getDiario()` - Buscar diário específico
- `getDiarios()` - Listar todos os diários de uma OS
- `getDiariosStream()` - Stream em tempo real dos diários

### 3. **Pages (Páginas)**

#### `novo_diario_page.dart` (Atualizada)
- Agora salva os diários no Firebase
- Mostra indicador de carregamento enquanto salva
- Valida os formulários

#### `editar_diario_page.dart` (Nova)
- Permite editar todos os dados de um diário
- Altera a data do diário
- Atualiza horários e quilometragem
- Salva as alterações no Firebase

### 4. **Widget** (`lib/presentation/widgets/diario_list_widget.dart`)
- `DiarioListWidget` - Exibe lista de diários
- Usa `StreamBuilder` para atualizar em tempo real
- Cards expansíveis mostrando cada diário
- Cálculo automático de KM percorrido
- Botões de editar e deletar (aparece apenas se OS estiver pendente)
- Interface amigável com ícones

### 5. **Integração** (`detalhes_os_page.dart`)
- Adicionada seção "Diários Registrados" na página de detalhes
- Lista de diários aparece logo após as informações básicas
- Reflete em tempo real as mudanças

## Como usar:

### Adicionar novo diário:
1. Abra os detalhes de uma OS pendente
2. Clique em "Adicionar Diário"
3. Preencha os dados (KM inicial/final, horários)
4. Clique em "Salvar Diário"

### Visualizar diários:
1. Na página de detalhes da OS, role até "Diários Registrados"
2. Clique no card do diário para expandir e ver detalhes completos
3. Vê automaticamente o KM percorrido calculado

### Editar diário:
1. Na lista de diários, expanda o diário
2. Clique em "Editar"
3. Modifique os dados desejados
4. Clique em "Atualizar Diário"

### Deletar diário:
1. Na lista de diários, expanda o diário
2. Clique em "Deletar"
3. Confirme a exclusão

## Dados armazenados no Firebase:

Coleção: `diarios`
Campos:
```json
{
  "osId": "string",
  "numeroOs": "string",
  "nomeCliente": "string",
  "data": "ISO8601 timestamp",
  "kmInicial": "number",
  "kmFinal": "number",
  "horaInicio": "string HH:MM",
  "intervaloInicio": "string HH:MM",
  "intervaloFim": "string HH:MM",
  "horaTermino": "string HH:MM",
  "createdAt": "ISO8601 timestamp",
  "updatedAt": "ISO8601 timestamp"
}
```

## Recursos extras:

- ✅ Atualização em tempo real via Firestore Streams
- ✅ Validação de formulários
- ✅ Indicadores de carregamento
- ✅ Tratamento de erros com SnackBars
- ✅ Cálculo automático de KM percorrido
- ✅ Interface responsiva e amigável
- ✅ Apenas usuários com OS pendente podem editar/deletar diários

## Próximas melhorias possíveis:

- [ ] Adicionar campo de observações/notas ao diário
- [ ] Exportar diários em PDF
- [ ] Adicionar fotos aos diários
- [ ] Filtrar e buscar diários
- [ ] Gráficos de KM por dia/mês
- [ ] Relatório consolidado de diários
