# gerarpdf.dart
(c:/Projetos/checkos/lib/utils/gerarpdf.dart)

# Descricao Geral
Utilitario para geracao de PDFs.

# Responsabilidade no Sistema
Gera documentos PDF de OS e relatorios.

# Metodos
- **gerarPDFOS(OsModel os)** - Gera PDF da OS
- **gerarPDFDiario(DiarioModel diario)** - Gera PDF do diario
- **gerarRelatorioOS(List<OsModel> lista)** - Gera relatorio

# Dependencias
- pdf (pacote)
- printing (pacote)

# Uso
```dart
await gerarPDFOS(osModel);
await Printing.layoutPdf(onLayout: (format) => pdf);
```

