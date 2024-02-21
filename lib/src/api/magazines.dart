import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

enum KbinAPIMagazinesFilter { all, subscribed, moderated, blocked }

enum KbinAPIMagazinesSort { active, hot, newest }

class APIMagazines {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIMagazines(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<DetailedMagazineListModel> list({
    int? page,
    KbinAPIMagazinesFilter? filter,
    KbinAPIMagazinesSort? sort,
    String? search,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = (filter == null || filter == KbinAPIMagazinesFilter.all)
            ? '/api/magazines'
            : '/api/magazines/${filter.name}';
        final query = queryParams(
          (filter == null || filter == KbinAPIMagazinesFilter.all)
              ? {'p': page?.toString(), 'sort': sort?.name, 'q': search}
              : {'p': page?.toString()},
        );

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazines');

        return DetailedMagazineListModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community/list';
        final query = queryParams({
          'limit': '50',
          'listingType': 'All',
          'sort': 'TopAll',
          'page': page?.toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazines');

        return DetailedMagazineListModel.fromLemmy(
            jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<DetailedMagazineModel> get(int magazineId) async {
    final path = '/api/magazine/$magazineId';

    final response = await httpClient.get(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to load magazine');

    return DetailedMagazineModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedMagazineModel> getByName(String magazineName) async {
    final path = '/api/magazine/name/$magazineName';

    final response = await httpClient.get(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to load magazine');

    return DetailedMagazineModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedMagazineModel> putSubscribe(int magazineId, bool state) async {
    final path =
        '/api/magazine/$magazineId/${state ? 'subscribe' : 'unsubscribe'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to send subscribe');

    return DetailedMagazineModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedMagazineModel> putBlock(int magazineId, bool state) async {
    final path = '/api/magazine/$magazineId/${state ? 'block' : 'unblock'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to send block');

    return DetailedMagazineModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
