# Prompts para Melhoria do Projeto CheckOS

Este arquivo contém prompts detalhados para cada uma das tarefas de melhoria identificadas na análise do projeto.

## 1. Atualização de Dependências (Prioridade Alta)

**Prompt:**
"Analise o arquivo `pubspec.yaml`, identifique todas as dependências desatualizadas e atualize-as para as versões mais recentes e estáveis. Execute `flutter pub upgrade --major-versions` e resolva quaisquer conflitos ou quebras de funcionalidade que surjam durante o processo. Após a atualização, realize testes completos para garantir que o aplicativo continue funcionando como esperado."

---

## 2. Refatoração do Gerenciamento de Tema (Prioridade Alta)

**Prompt:**
"Refatore o sistema de gerenciamento de tema do aplicativo. Substitua a abordagem atual, que passa o estado do tema manualmente através da árvore de widgets, por uma solução de gerenciamento de estado mais robusta. Utilize o pacote `provider` (já presente no projeto) para criar um `ThemeProvider`. Este provider deve ser responsável por fornecer o tema atual (claro/escuro) e o método para alternar entre os temas. Remova a passagem manual de `isDarkMode` e `onThemeChanged` dos widgets `HomePage` e `ConfigPage`."

---

## 3. Arquitetura e Injeção de Dependência (Prioridade Média)

**Prompt:**
"Fortaleça a arquitetura do projeto e implemente um sistema de injeção de dependência. Reative o inicializador do `get_it` que está comentado no arquivo `main.dart`. Configure o `get_it` para registrar o `AuthService` como um singleton. Em seguida, modifique a `HomePage` para obter a instância do `AuthService` através do `get_it` em vez de instanciá-la diretamente. Revise a estrutura de pastas e mova o `AuthService` para um local mais apropriado dentro da camada de `data` ou `domain`."

---

## 4. Remoção de Código Comentado e Features Inacabadas (Prioridade Média)

**Prompt:**
"Realize uma limpeza no código-fonte do projeto. Revise os arquivos `main.dart` e `home_page.dart` e remova todos os trechos de código que estão comentados e não são mais úteis. Investigue a rota comentada `configuracoes` no arquivo `routes.dart`. Se a funcionalidade não for ser implementada em breve, remova a rota. Caso contrário, crie uma issue detalhando o que precisa ser feito para que a funcionalidade seja concluída."

---

## 5. Consistência no Roteamento (Prioridade Baixa)

**Prompt:**
"Simplifique e padronize a lógica de roteamento do aplicativo. Uma vez que o gerenciamento de tema tenha sido refatorado (usando o `provider`), a `HomePage` não precisará mais receber parâmetros relacionados ao tema. Modifique o arquivo `routes.dart` para remover o tratamento especial dado à rota da `HomePage` na função `onGenerateRoute`, tornando o sistema de roteamento mais consistente."

---

## 6. Internacionalização (i18n) (Prioridade Baixa)

**Prompt:**
"Implemente a internacionalização (i18n) no aplicativo para prepará-lo para múltiplos idiomas. Externalize todas as strings hardcoded da interface do usuário (como 'Configurações', 'Sair', 'Modo Claro', etc.) para arquivos de tradução dedicados, utilizando o suporte nativo do Flutter para i18n. Comece com o suporte para 'pt_BR' e 'en_US'."
