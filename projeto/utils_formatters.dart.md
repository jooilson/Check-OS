# formatters.dart
(c:/Projetos/checkos/lib/utils/formatters.dart)

# Descrição Geral
Utilitários para formatação de dados.

# Responsabilidade no Sistema
Fornece funções de formatação de datas, números e textos.

# Métodos
- **formatDate(DateTime date)** - Formata data para dd/MM/yyyy
- **formatDateTime(DateTime date)** - Formata data e hora
- **formatCurrency(double value)** - Formata valor monetário
- **formatPhone(String phone)** - Formata telefone
- **formatCPF(String cpf)** - Formata CPF
- **formatCNPJ(String cnpj)** - Formata CNPJ
- **formatCEP(String cep)** - Formata CEP
- **formatKm(double km)** - Formata quilômetros
- **formatPlate(String plate)** - Formata placa de veículo

# Uso
```dart
final dateStr = formatDate(DateTime.now());
final phoneStr = formatPhone('11999999999');
```

