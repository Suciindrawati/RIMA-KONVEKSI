import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../models/produk_model.dart';
import 'auth_service.dart';

class ProdukService {
  final _auth = AuthService();

  Future<Map<String, String>> _headers({bool isMultipart = false}) async {
    final token = await _auth.getToken();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (!isMultipart) headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<Map<String, dynamic>> getPaginated(int page) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.produk}?page=$page'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil data produk');
  }

  Future<List<ProdukModel>> getAll() async {
    final response = await http.get(Uri.parse(ApiConstants.produk), headers: await _headers());
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['data'];
      return list.map((e) => ProdukModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data produk');
  }

  Future<ProdukModel> create(ProdukModel p, {Uint8List? imageBytes, String? fileName}) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.produk));
    request.headers.addAll(await _headers(isMultipart: true));
    
    request.fields['nama_produk'] = p.namaProduk;
    request.fields['jenis_produk'] = p.jenisProduk;
    request.fields['stok'] = p.stok.toString();
    request.fields['deskripsi'] = p.deskripsi ?? '';

    if (imageBytes != null && fileName != null) {
      String extension = fileName.split('.').last.toLowerCase();
      request.files.add(http.MultipartFile.fromBytes(
        'gambar', 
        imageBytes, 
        filename: fileName,
        contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
      ));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProdukModel.fromJson(data['data']);
    }
    throw Exception('Server Error (${response.statusCode}): ${response.body}');
  }

  Future<ProdukModel> update(int id, ProdukModel p, {Uint8List? imageBytes, String? fileName}) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.produk}/$id'));
    request.headers.addAll(await _headers(isMultipart: true));
    request.fields['_method'] = 'PUT';
    
    request.fields['nama_produk'] = p.namaProduk;
    request.fields['jenis_produk'] = p.jenisProduk;
    request.fields['stok'] = p.stok.toString();
    request.fields['deskripsi'] = p.deskripsi ?? '';

    if (imageBytes != null && fileName != null) {
      String extension = fileName.split('.').last.toLowerCase();
      request.files.add(http.MultipartFile.fromBytes(
        'gambar', 
        imageBytes, 
        filename: fileName,
        contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
      ));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProdukModel.fromJson(data['data']);
    }
    throw Exception('Server Error (${response.statusCode}): ${response.body}');
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('${ApiConstants.produk}/$id'), headers: await _headers());
    if (response.statusCode != 200) throw Exception('Gagal menghapus produk');
  }
}
