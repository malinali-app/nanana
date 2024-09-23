// Dart imports:
import 'dart:convert' as convert;

// Package imports:
import 'package:collection/collection.dart';
import 'package:languages_dart/languages_dart.dart';
import 'package:mobx/mobx.dart';
import 'package:nanana_app/src/models/capture.dart';
import 'package:nanana_app/src/shared_prefs/endpoint_base.dart';

part 'captures.g.dart';

class ReadAllCaptures implements EndpointBase<List<Capture>, void> {
  ReadAllCaptures();

  @override
  Future<List<Capture>> request(void data) {
    // TODO: implement request
    throw UnimplementedError();
  }
}

class UpdateTranscription implements EndpointBase<Capture, Capture> {
  UpdateTranscription();

  @override
  Future<Capture> request(Capture data) {
    // TODO: implement request
    throw UnimplementedError();
  }
}

class CreateTranscription implements EndpointBase<Capture, Capture> {
  CreateTranscription();

  @override
  Future<Capture> request(Capture data) async {
    // TODO: implement request
    // throw UnimplementedError();
    return data;
  }
}

class TranscriptionService {
  final CreateTranscription create;
  final ReadAllCaptures readAll;
  final UpdateTranscription update;
  TranscriptionService(this.create, this.readAll, this.update);
}

extension Filter on ObservableList<Capture> {
  List<Capture> searchBySong(String queryString) => List<Capture>.of(
      where((p) => p.song.clean.contains(queryString.clean)).toList());

  List<Capture> searchById(String queryString) => List<Capture>.of(
      where((p) => p.id.toString().contains(queryString.trim())).toList());

  ObservableList<Capture> searchByTitleOrIdObs(String queryString) =>
      ObservableList<Capture>.of(
          <Capture>{...searchBySong(queryString), ...searchById(queryString)});

  ObservableList<Capture> searchBySongObs(String queryString) =>
      ObservableList.of(searchBySong(queryString));

  ObservableList<Capture> searchByIdObs(String queryString) =>
      ObservableList<Capture>.of(searchById(queryString));

  ObservableList<Capture> sortedBySong() =>
      ObservableList.of(this..sort((a, b) => a.song.compareTo(b.song)));

  ObservableList<Capture> sortedBySongReversed() =>
      ObservableList.of(this..sort((a, b) => b.song.compareTo(a.song)));

  ObservableList<Capture> sortedById() {
    return ObservableList.of(
      this..sort((a, b) => a.id.compareTo(b.id)),
    );
  }

  ObservableList<Capture> sortedByIdReversed() {
    return ObservableList.of(
      this..sort((a, b) => b.id.compareTo(a.id)),
    );
  }
}

enum SortedBy {
  unsorted,
  song,
  songReversed,
  id,
  idReversed,
}

enum SearchedBy { titleOrId, none } // categories will be added her eventually

class TranscriptionStore = TranscriptionStoreBase with _$TranscriptionStore;

abstract class TranscriptionStoreBase with Store {
  final TranscriptionService _transcriptionService;

  TranscriptionStoreBase(this._transcriptionService) {
    initialLoading = true;
    _transcriptionService;
    captures = ObservableList<Capture>();
    _capturesFiltered = ObservableList<Capture>();
    sortedBy = Observable(SortedBy.id);
    sortBy(SortedBy.id);
  }

  @observable
  bool initialLoading = true;

  @observable
  SearchedBy _searchedByPrivate = SearchedBy.none;

  SearchedBy get searchedBy => _searchedByPrivate;

  @action
  void setSearchedBy(SearchedBy val) => _searchedByPrivate = val;

  @observable
  String _queryStringPrivate = '';

  String get queryString => _queryStringPrivate;

  @action
  void setQueryString(String val) {
    _queryStringPrivate = val;
  }

  @observable
  Observable<SortedBy> sortedBy = Observable(SortedBy.song);

  @observable
  ObservableList<Capture> captures = ObservableList.of(<Capture>[]);

  @observable
  ObservableList<Capture> _capturesFiltered = ObservableList.of(<Capture>[]);

  @action
  ObservableList<Capture> sortBy(SortedBy sortBy) {
    switch (sortBy) {
      case SortedBy.id:
        captures = captures.sortedById();
        sortedBy = Observable(SortedBy.id);
        break;
      case SortedBy.idReversed:
        captures = captures.sortedByIdReversed();
        sortedBy = Observable(SortedBy.idReversed);
        break;
      case SortedBy.song:
        captures = captures.sortedBySong();
        sortedBy = Observable(SortedBy.song);
        break;
      case SortedBy.songReversed:
        captures = captures.sortedBySongReversed();
        sortedBy = Observable(SortedBy.songReversed);
        break;
      default:
    }
    return captures;
  }

  @action
  void searchBySongOrId() {
    if (captures.isNotEmpty) {
      if (searchedBy == SearchedBy.titleOrId) {
        if (queryString.isNotEmpty) {
          _capturesFiltered = captures.searchByTitleOrIdObs(queryString);
        } else {}
      }
    }
  }

  @computed
  ObservableList<Capture> get calibresSearchable {
    if (captures.isEmpty) {
      return ObservableList<Capture>.of([]);
    }
    if (queryString.isEmpty) {
      return ObservableList<Capture>.of(captures);
    }
    if (searchedBy == SearchedBy.titleOrId) {
      return ObservableList<Capture>.of(
          captures.searchByTitleOrIdObs(queryString));
    } else {
      return ObservableList<Capture>.of(captures);
    }
  }

  @action
  Future<bool> init({List<Capture>? data}) async {
    if (data != null && data.isNotEmpty) {
      captures = ObservableList.of(data);
    } else {
      final capturesFromRpc = await _transcriptionService.readAll.request(null);
      if (capturesFromRpc.isNotEmpty) {
        captures = ObservableList.of(capturesFromRpc);
      }
    }
    initialLoading = false;
    return initialLoading;
  }

  @action
  Future<void> clearSearch() async {
    setSearchedBy(SearchedBy.none);
    setQueryString('');
    // only way dart can clone a list
    _capturesFiltered = ObservableList<Capture>.of(captures.map(
      (e) => Capture(
          id: e.id,
          artist: e.artist,
          song: e.song,
          youtubeUrl: e.youtubeUrl,
          language: e.language,
          userId: e.userId),
    ));
  }

  @action
  Future<Capture> updateTranscription(Capture transcription) async {
    final updatedLine =
        await _transcriptionService.update.request(transcription);
    final index =
        captures.indexWhere((element) => element.id == updatedLine.id);
    captures.removeAt(index);
    captures.add(updatedLine);
    return transcription;
  }

  @action
  Future<ObservableList<Capture>> importFromJson(String json) async {
    final temp = (convert.json.decode(json) as List)
        .cast<Map>() // ?
        .cast<Map<String, dynamic>>()
        .map((line) => Capture.fromMap(line))
        .toList();
    captures = ObservableList.of(temp);
    for (final t in temp) {
      await _transcriptionService.create.request(t);
    }
    return captures;
  }

  @action
  Future<Capture> createOne(Capture data) async {
    final temp = await _transcriptionService.create.request(data);
    captures.add(temp);
    return temp;
  }
}
