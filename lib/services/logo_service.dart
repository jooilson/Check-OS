import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar o logo da empresa.
/// Salva e carrega o logo da empresa em um local persistente.
class LogoService {
  static const String _logoPathKey = 'company_logo_path';

  /// Salva o logo da empresa.
  /// Recebe um arquivo de imagem e o salva em um diretório persistente.
  static Future<String?> saveLogo(File logoFile) async {
    try {
      // Web não suporta operações de sistema de arquivos locais da mesma forma
      if (kIsWeb) {
        print('[LogoService] Web não suporta salvamento local de arquivos');
        return null;
      }
      
      print('[LogoService] Iniciando salvamento do logo: ${logoFile.path}');
      
      // Valida se o arquivo existe
      if (!await logoFile.exists()) {
        print('[LogoService] Erro: Arquivo não existe: ${logoFile.path}');
        return null;
      }

      // Obtém o diretório de documentos da aplicação
      final appDir = await getApplicationDocumentsDirectory();
      print('[LogoService] App directory: ${appDir.path}');
      
      final logoDir = Directory('${appDir.path}/company');
      
      // Cria o diretório se não existir
      if (!await logoDir.exists()) {
        print('[LogoService] Criando diretório: ${logoDir.path}');
        await logoDir.create(recursive: true);
      }

      final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = File('${logoDir.path}/$fileName');
      
      print('[LogoService] Copiando arquivo para: ${savedFile.path}');
      
      // Copia o arquivo para o diretório da aplicação
      final copiedFile = await logoFile.copy(savedFile.path);
      
      // Valida se a cópia foi bem-sucedida
      if (!await copiedFile.exists()) {
        print('[LogoService] Erro: Arquivo não foi copiado com sucesso');
        return null;
      }

      // Salva o caminho nas preferências
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoPathKey, savedFile.path);
      
      print('[LogoService] Logo salvo com sucesso em: ${savedFile.path}');
      return savedFile.path;
    } on FileSystemException catch (e) {
      print('[LogoService] Erro de acesso ao arquivo: $e');
      return null;
    } catch (e) {
      print('[LogoService] Erro inesperado ao salvar logo: $e');
      return null;
    }
  }

  /// Carrega o caminho do logo armazenado.
  static Future<String?> getLogoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_logoPathKey);
      
      print('[LogoService] Caminho salvo: $path');
      
      if (path != null && await File(path).exists()) {
        print('[LogoService] Arquivo existe: $path');
        return path;
      }
      
      print('[LogoService] Arquivo não encontrado: $path');
      return null;
    } catch (e) {
      print('[LogoService] Erro ao carregar caminho do logo: $e');
      return null;
    }
  }

  /// Carrega o logo como um arquivo.
  static Future<File?> getLogoFile() async {
    try {
      final path = await getLogoPath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          print('[LogoService] Logo carregado: $path');
          return file;
        }
      }
      print('[LogoService] Logo não encontrado');
      return null;
    } catch (e) {
      print('[LogoService] Erro ao carregar logo: $e');
      return null;
    }
  }

  /// Deleta o logo armazenado.
  static Future<bool> deleteLogo() async {
    try {
      // Web não suporta operações de sistema de arquivos locais
      if (kIsWeb) {
        print('[LogoService] Web não suporta exclusão de arquivos locais');
        return false;
      }
      
      final path = await getLogoPath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print('[LogoService] Arquivo deletado: $path');
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logoPathKey);
      
      print('[LogoService] Logo deletado com sucesso');
      return true;
    } catch (e) {
      print('[LogoService] Erro ao deletar logo: $e');
      return false;
    }
  }
}
