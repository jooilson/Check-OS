# import_export_service.dart
(c:/Projetos/checkos/lib/services/import_export_service.dart)

# Descricao Geral
Servico para importacao e exportacao de dados.

# Responsabilidade no Sistema
Gerencia importacao e exportacao de OS e funcionarios.

# Metodos
- **exportEmployees(String companyId)** - Exporta funcionarios
- **importEmployees(List<Map> data, String companyId)** - Importa funcionarios
- **exportOS(String companyId)** - Exporta OS
- **importOS(List<Map> data, String companyId)** - Importa OS
- **generateExcel()** - Gera planilha Excel
- **parseCSV(String content)** - Parsa arquivo CSV

# Formatos Suportados
- CSV
- JSON
- Excel (futuro)

# Integracao
- EmployeeRepository: dados de funcionarios
- OsRepository: dados de OS

