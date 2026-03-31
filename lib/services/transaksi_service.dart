import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/transaksi_model.dart';
import 'auth_service.dart';

class TransaksiService {
  final _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPaginated({int page = 1, String? status}) async {
    String url = '${ApiConstants.transaksi}?page=$page';
    if (status != null) url += '&status=$status';
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil data transaksi');
  }

  Future<List<TransaksiModel>> getAll() async {
    final response = await http.get(Uri.parse(ApiConstants.transaksi), headers: await _headers());
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['data'];
      return list.map((e) => TransaksiModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data transaksi');
  }

  Future<TransaksiModel> create(TransaksiModel t) async {
    final response = await http.post(
      Uri.parse(ApiConstants.transaksi),
      headers: await _headers(),
      body: jsonEncode(t.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return TransaksiModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal menyimpan transaksi');
  }

  Future<TransaksiModel> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.transaksi}/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return TransaksiModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal update transaksi');
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('${ApiConstants.transaksi}/$id'), headers: await _headers());
    if (response.statusCode != 200) throw Exception('Gagal menghapus transaksi');
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(Uri.parse(ApiConstants.dashboard), headers: await _headers());
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Gagal mengambil data dashboard');
  }
}
