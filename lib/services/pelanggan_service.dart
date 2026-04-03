import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/pelanggan_model.dart';
import 'auth_service.dart';

class PelangganService {
  final _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPaginated(int page, {String? search}) async {
    String url = '${ApiConstants.pelanggan}?page=$page';
    if (search != null && search.isNotEmpty) url += '&search=$search';
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil data pelanggan');
  }

  Future<List<PelangganModel>> getAll() async {
    final response = await http.get(
      Uri.parse(ApiConstants.pelanggan),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? data;
      return list.map((e) => PelangganModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data pelanggan');
  }

  Future<PelangganModel> create(PelangganModel p) async {
    final response = await http.post(
      Uri.parse(ApiConstants.pelanggan),
      headers: await _headers(),
      body: jsonEncode(p.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PelangganModel.fromJson(data['data'] ?? data);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal menyimpan pelanggan');
  }

  Future<PelangganModel> update(int id, PelangganModel p) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.pelanggan}/$id'),
      headers: await _headers(),
      body: jsonEncode(p.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PelangganModel.fromJson(data['data'] ?? data);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengupdate pelanggan');
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.pelanggan}/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus pelanggan');
    }
  }
}
