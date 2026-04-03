import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../models/katalog_model.dart';
import 'auth_service.dart';

class KatalogService {
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
    String url = '${ApiConstants.katalog}?page=$page';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil data katalog');
  }

  Future<List<KatalogModel>> getAll() async {
    final response = await http.get(Uri.parse(ApiConstants.katalog), headers: await _headers());
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['data'];
      return list.map((e) => KatalogModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data katalog');
  }

  Future<KatalogModel> create(KatalogModel k, {Uint8List? imageBytes, String? imageName, List<Uint8List>? galleryBytes, List<String>? galleryNames}) async {
    final token = await _auth.getToken();
    final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.katalog));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['judul'] = k.judul;
    if (k.deskripsi != null) request.fields['deskripsi'] = k.deskripsi!;
    
    if (imageBytes != null && imageName != null) {
      String extension = imageName.split('.').last.toLowerCase();
      request.files.add(http.MultipartFile.fromBytes(
        'gambar', 
        imageBytes, 
        filename: imageName,
        contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
      ));
    }

    // New Gallery
    if (galleryBytes != null && galleryNames != null) {
      for (int i = 0; i < galleryBytes.length; i++) {
        String ext = galleryNames[i].split('.').last.toLowerCase();
        request.files.add(http.MultipartFile.fromBytes(
          'gallery[]', 
          galleryBytes[i], 
          filename: galleryNames[i],
          contentType: MediaType('image', ext == 'png' ? 'png' : 'jpeg'),
        ));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return KatalogModel.fromJson(data['data']);
    } else {
      throw Exception('Server Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<KatalogModel> update(int id, KatalogModel k, {Uint8List? imageBytes, String? imageName, List<Uint8List>? galleryBytes, List<String>? galleryNames}) async {
    final token = await _auth.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.katalog}/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT';
    request.fields['judul'] = k.judul;
    if (k.deskripsi != null) request.fields['deskripsi'] = k.deskripsi!;
    
    if (imageBytes != null && imageName != null) {
      String extension = imageName.split('.').last.toLowerCase();
      request.files.add(http.MultipartFile.fromBytes(
        'gambar', 
        imageBytes, 
        filename: imageName,
        contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
      ));
    }

    if (galleryBytes != null && galleryNames != null) {
      for (int i = 0; i < galleryBytes.length; i++) {
        String ext = galleryNames[i].split('.').last.toLowerCase();
        request.files.add(http.MultipartFile.fromBytes(
          'gallery[]', 
          galleryBytes[i], 
          filename: galleryNames[i],
          contentType: MediaType('image', ext == 'png' ? 'png' : 'jpeg'),
        ));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return KatalogModel.fromJson(data['data']);
    } else {
      throw Exception('Server Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('${ApiConstants.katalog}/$id'), headers: await _headers());
    if (response.statusCode != 200) throw Exception('Gagal menghapus katalog');
  }
}
