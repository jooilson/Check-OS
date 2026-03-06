# Fluxo Completo do Sistema - CheckOS

## Visão Geral

Este documento descreve os principais fluxos do sistema CheckOS, desde a criação de dados até operações complexas.

---

## 1. FLUXO: CRIAR CLIENTE

### 1.1 Descrição
O sistema não tem CRUD explícito de clientes. Clientes são criados implicitamente ao criar uma OS.

### 1.2 Fluxo

```
NovaOsPage
    │
    ├── Usuário preenche nome do cliente
    │       └── "João Silva"
    │
    ├── Ao salvar OS
    │       └── OsRepository.addOs()
    │
    └── OS salva com nomeCliente
            └── Cliente criado implicitamente
```

### 1.3 Observação

**PROBLEMA**: Não há gerenciamento de clientes como entidade separada.
- Cliente é apenas uma string (nome)
- Não há histórico de clientes
- Não há dados de contato do cliente

---

## 2. FLUXO: CRIAR ORDEM DE SERVIÇO (OS)

### 2.1 Descrição
Criar uma nova ordem de serviço é a principal funcionalidade do sistema.

### 2.2 Fluxo Completo

```
┌─────────────────────────────────────────────────────────────┐
│ NOVA OS PAGE                                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. PREENCHER FORMULÁRIO                                     │
│    ├── Número OS (auto-incrementado)                        │
│    ├── Nome Cliente                                         │
│    ├── Serviço                                              │
│    ├── Relato do Cliente                                    │
│    ├── Responsável                                          │
│    ├── Tem Pedido? → Número Pedido                          │
│    ├── Funcionários (multi-select)                          │
│    ├── KM Inicial                                           │
│    └── Data/Hora de Início                                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. VALIDAR FORMULÁRIO                                       │
│    └── formKey.currentState!.validate()                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. SALVAR OS                                                │
│    └── OsRepository.addOs(osModel)                         │
│                                                                 │
│    ├── Gera ID único                                         │
│    ├── Adiciona companyId                                    │
│    ├── Adiciona timestamps                                   │
│    └── Envia para Firestore                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. ADICIONAR LOG (AUDITORIA)                                │
│    └── LogRepository.addLog()                               │
│                                                                 │
│    ├── action: "create"                                      │
│    ├── entityType: "os"                                      │
│    ├── userId: currentEmployee.id                           │
│    └── companyId: currentEmployee.companyId                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. REDIRECIONAR                                             │
│    └── Navigator.pop(context)                               │
│            └── ListaPage (atualizada)                       │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Código Simplificado

```dart
Future<void> _salvarOS() async {
  // 1. Validar
  if (!formKey.currentState!.validate()) return;

  // 2. Criar modelo
  final os = OsModel(
    numeroOs: numeroOs,
    nomeCliente: _nomeClienteController.text,
    servico: _servicoController.text,
    companyId: employee.companyId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 3. Salvar
  await osRepository.addOs(os);

  // 4. Log
  await logRepository.addLog(...);

  // 5. Voltar
  if (mounted) Navigator.pop(context);
}
```

---

## 3. FLUXO: ADICIONAR IMAGENS

### 3.1 Descrição
Adicionar fotos a uma OS para documentação.

### 3.2 Fluxo

```
DetalhesOsPage
    │
    ├── Botão "Adicionar Imagem"
    │
    ├── ImagePicker.pickImage()
    │       └── Abre câmera ou galeria
    │
    ├── FirebaseStorage.upload()
    │       └── Envia para Firebase Storage
    │       └── URL retornada
    │
    ├── Atualizar OS
    │       └── OsRepository.updateOs()
    │       └── imagens.add(url)
    │
    └── Exibir imagem na OS
```

### 3.3 Código

```dart
Future<void> _adicionarImagem() async {
  final picker = ImagePicker();
  final XFile? imagem = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1024,
    maxHeight: 1024,
  );

  if (imagem != null) {
    // Upload para Storage
    final url = await _uploadImagem(imagem);

    // Atualizar OS
    final imagens = List<String>.from(osModel.imagens);
    imagens.add(url);
    await osRepository.updateOs(osModel.copyWith(imagens: imagens));
  }
}
```

---

## 4. FLUXO: GERAR RELATÓRIO PDF

### 4.1 Descrição
Gerar PDF de uma OS para impressão ou envio.

### 4.2 Fluxo

```
DetalhesOsPage
    │
    ├── Botão "Gerar PDF"
    │
    ├── gerarPDF(osModel)
    │       └── Utils/gerarpdf.dart
    │
    ├── Gerar documento PDF
    │       ├── Dados da OS
    │       ├── Cliente
    │       ├── Serviços
    │       └── Assinatura
    │
    ├── Printing.layoutPDF()
    │       └── Abrir visualizador/impressor
    │
    └── (Opcional) Share.share()
            └── Compartilhar arquivo
```

### 4.2 Código

```dart
Future<void> _gerarPDF() async {
  final pdf = await gerarPDF(osModel);

  await Printing.layoutPdf(
    onLayout: (format) async => pdf,
    name: 'OS_${osModel.numeroOs}.pdf',
  );
}
```

---

## 5. FLUXO: CRIAR DIÁRIO DE BORDO

### 5.1 Descrição
Criar registro diário vinculado a uma OS existente.

### 5.2 Fluxo

```
DetalhesOsPage
    │
    ├── Botão "Criar Diário"
    │
    ├── Navegar para NovoDiarioPage(os)
    │
    ├── Preencher formulário
    │       ├── Data
    │       ├── Descrição
    │       └── Imagens
    │
    ├── DiarioRepository.addDiario()
    │       ├── osId = os.id
    │       ├── numeroOs = os.numeroOs
    │       └── companyId = os.companyId
    │
    └── LogRepository.addLog()
            └── Voltar para DetalhesOsPage
```

---

## 6. FLUXO: CADASTRAR FUNCIONÁRIO

### 6.1 Descrição
Adicionar novo funcionário à empresa (apenas Admin/Owner).

### 6.2 Fluxo

```
EmployeeManagementPage
    │
    ├── Botão "Adicionar"
    │
    ├── Navegar para EmployeeAddPage()
    │
    ├── Preencher formulário
    │       ├── Nome
    │       ├── Email
    │       ├── Telefone
    │       ├── CPF
    │       └── Role (user/admin)
    │
    ├── AuthService.registerEmployee()
    │       ├── Cria usuário no Firebase Auth
    │       └── Envia email de convite
    │
    ├── EmployeeRepository.addEmployee()
    │       └── Cria documento em employees
    │
    ├── UserRepository.createUser()
    │       └── Cria documento em users
    │
    └── LogRepository.addLog()
            └── Voltar para lista
```

### 6.3 Código

```dart
Future<void> _cadastrarFuncionario() async {
  // 1. Criar usuário no Firebase Auth
  final uid = await authService.registerEmployee(
    email: email,
    password: 'SenhaTemporaria123',
    name: nome,
    companyId: companyId,
    role: role,
  );

  // 2. Criar employee
  await employeeRepository.addEmployee(
    EmployeeModel(
      id: uid,
      name: nome,
      email: email,
      phone: telefone,
      cpf: cpf,
      companyId: companyId,
    ),
  );

  // 3. Log
  await logRepository.addLog(...);
}
```

---

## 7. FLUXO: FINALIZAR OS

### 7.1 Descrição
Marcar OS como finalizada com todos os dados de conclusão.

### 7.2 Fluxo

```
DetalhesOsPage
    │
    ├── Botão "Finalizar OS"
    │
    ├── Abrir dialog de confirmação
    │
    ├── Preencher dados de conclusão
    │       ├── KM Final
    │       ├── Hora de Término
    │       ├── Relatório Técnico
    │       └── Assinatura (opcional)
    │
    ├── OsRepository.updateOs()
    │       ├── osfinalizado = true
    │       ├── horaTermino = DateTime.now()
    │       └── totalKm = kmFinal - kmInicial
    │
    ├── LogRepository.addLog()
    │
    └── Atualizar UI
```

---

## 8. FLUXO: IMPORTAR DADOS (CSV)

### 8.1 Descrição
Importar OS ou funcionários de arquivo CSV.

### 8.2 Fluxo

```
ImportExportPage
    │
    ├── Botão "Importar CSV"
    │
    ├── FilePicker.pickFile()
    │       └── Selecionar arquivo CSV
    │
    ├── Ler arquivo
    │       └── Leitura de linhas CSV
    │
    ├── Processar dados
    │       ├── Validar colunas
    │       ├── Converter para modelos
    │       └── Mapear campos
    │
    ├── Importar para Firestore
    │       ├── Loop por registros
    │       └── Batch write (se muitos)
    │
    └── Mostrar resultado
            ├── Total importado
            └── Erros (se houver)
```

---

## 9. FLUXO: EXPORTAR DADOS

### 9.1 Descrição
Exportar OS ou diários para CSV ou PDF.

### 9.2 Fluxo

```
ImportExportPage
    │
    ├── Selecionar tipo de dados
    │       └── OS ou Diários
    │
    ├── Selecionar formato
    │       └── CSV ou PDF
    │
    ├── Buscar dados
    │       └── OsRepository.getOsList()
    │
    ├── Gerar arquivo
    │       ├── CSV: converter para texto
    │       └── PDF: usar gerarpdf.dart
    │
    └── Compartilhar/Salvar
            └── Share.share() ou FilePicker
```

---

## 10. FLUXO: GERENCIAR EMPRESA

### 10.1 Descrição
Editar dados da empresa após cadastro inicial.

### 10.2 Fluxo

```
ConfigPage
    │
    ├── Seção "Dados da Empresa"
    │
    ├── Editar campos
    │       ├── Nome
    │       ├── CNPJ
    │       ├── Telefone
    │       ├── Endereço
    │       └── Logo
    │
    ├── CompanyRepository.updateCompany()
    │
    └── Se mudou logo
            └── LogoService.uploadLogo()
                    └── Atualizar logoUrl
```

---

## 11. FLUXO: LOGOUT

### 11.1 Descrição
Sair da conta e limpar dados locais.

### 11.2 Fluxo

```
ConfigPage ou Drawer
    │
    ├── Botão "Sair"
    │
    ├── Dialog de confirmação
    │
    ├── AuthService.signOut()
    │       └── FirebaseAuth.signOut()
    │
    ├── Limpar contexto
    │       └── EmployeeContext.clear()
    │
    ├── Limpar dados locais
    │       └── SharedPreferences.clear()
    │
    └── Redirecionar para AuthPage
            └── Navigator.pushAndRemoveUntil()
```

---

## 12. FLUXO: UPLOAD DE LOGO

### 12.1 Descrição
Empresa faz upload do logo.

### 12.2 Fluxo

```
ConfigPage ou CadastroEmpresaPage
    │
    ├── Botão "Alterar Logo"
    │
    ├── ImagePicker.pickImage()
    │       └── Selecionar imagem
    │
    ├── LogoService.uploadLogo()
    │       ├── FirebaseStorage.upload()
    │       └── Retorna URL
    │
    ├── CompanyRepository.updateCompany()
    │       └── logoUrl = novaUrl
    │
    └── Atualizar UI
```

---

## 13. FLUXO: VERIFICAR PERMISSÕES

### 13.1 Descrição
Verificar se usuário pode executar ação.

### 13.2 Fluxo

```
Página qualquer
    │
    ├── Ação do usuário
    │
    ├── PermissionService.canExecute()
    │       ├── Verifica role do usuário
    │       └── Verifica tipo de ação
    │
    ├── Se permitido
    │       └── Executar ação
    │
    └── Se negado
            └── Mostrar Snackbar
                    └── "Acesso negado"
```

---

## 14. RESUMO DE FLUXOS

| Fluxo | Origem | Destino | Repository |
|-------|--------|---------|------------|
| Criar OS | NovaOsPage | Firestore | OsRepository |
| Editar OS | DetalhesOsPage | Firestore | OsRepository |
| Finalizar OS | DetalhesOsPage | Firestore | OsRepository |
| Adicionar Imagem | DetalhesOsPage | Storage | FirebaseStorage |
| Criar Diário | NovoDiarioPage | Firestore | DiarioRepository |
| Cadastrar Funcionário | EmployeeAddPage | Firestore + Auth | EmployeeRepository + AuthService |
| Importar CSV | ImportExportPage | Firestore | Various |
| Exportar | ImportExportPage | Arquivo | Various |
| Editar Empresa | ConfigPage | Firestore | CompanyRepository |
| Upload Logo | ConfigPage | Storage | LogoService |
| Logout | ConfigPage | Firebase | AuthService |

---

## 15. PONTOS CRÍTICOS NOS FLUXOS

### 15.1 Concorrência

- Múltiplos usuários podem editar mesma OS
- Não há locking de registros

### 15.2 Validação

- Validação principalmente no cliente
- Pouca validação server-side

### 15.3 Erros

- Tratamento de erros básico
- Não há retry automático

### 15.4 Sincronização

- Users e Employees podem divergir
- companyId pode ser null

