import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:language_picker_native_tongue/language_picker_native_tongue.dart';
import 'package:languages_dart/languages_dart.dart';
import 'package:nanana_app/src/app/top_provider.dart';
import 'package:nanana_app/src/app/ze_stuff.dart';
import 'package:nanana_app/src/widgets/editor/find_panel_view.dart';
import 'package:nanana_app/src/capture_view.dart';
import 'package:nanana_app/src/mobx/crud_stores/captures.dart';
import 'package:nanana_app/src/mobx/validators/abstract.dart';
import 'package:nanana_app/src/mobx/validators/capture.dart';
import 'package:nanana_app/src/models/capture.dart';
import 'package:nanana_app/src/widgets/dialog.dart';
import 'package:nanana_app/src/youtube_metadata_capturer.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:re_editor/re_editor.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const double widgetHeightSpacer = 12;

class CreateTranscriptionView extends StatefulWidget {
  const CreateTranscriptionView({super.key});

  @override
  State<CreateTranscriptionView> createState() =>
      _CreateTranscriptionViewState();
}

class _CreateTranscriptionViewState extends State<CreateTranscriptionView> {
  final scrollController = ScrollController();
  late TranscriptionFormStore validator;
  final languageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final store = Provider.of<TranscriptionStore>(context, listen: false);
    validator = TranscriptionFormStore(store);
    validator.setupValidations();
    languageTextController.text = validator.language.name;
  }

  @override
  void dispose() {
    languageTextController.dispose();
    super.dispose();
  }

  Future<YoutubeMetadata> captureYoutubeMetadata() async {
    final yt = YoutubeExplode();
    final id = VideoId(validator.youtubeUrl.trim());

    final video = await yt.videos.get(id);
    String title = '', description = '', duration = '', thumbnailUrl = '';
    thumbnailUrl = video.thumbnails.highResUrl;
    title = video.title;
    duration = video.duration.toString();
    description = video.description;
    return YoutubeMetadata(
      title: title,
      description: description,
      duration: duration,
      thumbnailUrl: thumbnailUrl,
    );
  }

// TODO put a loader %
  Future<String> downloadYoutubeVideo() async {
    final top = Provider.of<TopProvider>(context, listen: false);
    // Here you should validate the given input or else an error
    // will be thrown.
    final yt = YoutubeExplode();
    final id = VideoId(validator.youtubeUrl.trim());
    final video = await yt.videos.get(id);

    // Display info about this video.
    /*               await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                        'Title: ${video.title}, Duration: ${video.duration}',
                      ),
                    );
                  },
                ); */

    // Request permission to write in an external directory.
    // (In this case downloads)
    // await Permission.storage.request();

    // Get the streams manifest and the audio track.
    final manifest = await yt.videos.streamsClient.getManifest(id);

    final videoStream = manifest
        .muxed.bestQuality; // XXX consider choosing video quality in settings
    // yt.videos.streamsClient.get(audio).pipe(streamConsumer)
    // Build the directory.
    final fileName = '${video.title}_${video.id}.${videoStream.container.name}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    final filePath = path.join(
      top.songsFilesDir.uri.toFilePath(),
      fileName,
    );

    // Open the file to write.
    final file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Open the file in writeAppend.
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);

    // Pipe all the content of the stream into our file.
    // await yt.videos.streamsClient.get(audio).pipe(fileStream);
    /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */
// Track the file download status.
    final len = videoStream.size.totalBytes;
    var count = 0;

    // Create the message and set the cursor position.
    final msg = 'Downloading ${video.title}.${videoStream.container.name}';
    stdout.writeln(msg);

    // Listen for data received.
    print(filePath);
    await for (final data in yt.videos.streamsClient.get(videoStream)) {
      // Keep track of the current downloaded data.
      count += data.length;

      // Calculate the current progress.
      final progress = ((count / len) * 100).ceil();

      print(progress.toStringAsFixed(0));

      // Write to file.
      output.add(data);
    }
    await output.close();
    print(filePath);
    return filePath;
    // // Show that the file was downloaded.
/*                 await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content:
                          Text('Download completed and saved to: $filePath'),
                    );
                  },
                ); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          // do the syncing saving boogie
          validator.validateAll();
          if (validator.hasErrors) {
            return;
          }
          try {
            final transcription = await validator.createTranscriptionFromForm();
            print(transcription.toMap());
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    TranscriptionView(isEdit: true, capture: transcription),
              ),
            );
          } catch (e) {
            return InformDialog.showDialogNanana("$e", context);
          }
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        title: Text('Create new lyrics capture',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontFamily: 'Barokah', color: Colors.black),
            overflow: TextOverflow.visible),
        actions: [],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Observer(builder: (_) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // TODO fill the onsubmit to preload other fields
                YoutubeUrlTextField(validator),
                const SizedBox(height: widgetHeightSpacer),
/*                 if (validator.youtubeUrl.isNotEmpty)
                  ElevatedButton(
                      child: const Text('Capture'),
                      onPressed: () => setState(() {})), */
                if (validator.youtubeUrl.isNotEmpty)
                  FutureBuilder2<YoutubeMetadata>(
                      future: captureYoutubeMetadata(),
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator.adaptive();
                        } else if (snap.hasError ||
                            (snap.connectionState != ConnectionState.waiting &&
                                !snap.hasData)) {
                          return ColoredBox(
                              color: const Color.fromRGBO(236, 64, 122, 1),
                              child: Text('error ${snap.error}'));
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                width: 360,
                                height: 144,
                                child: Image.network(
                                  snap.data!.thumbnailUrl,
                                  fit: BoxFit.scaleDown,
                                  frameBuilder: ((context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    return child;
                                    //if (wasSynchronouslyLoaded) return child;
                                    //return Loader.animatedSwitcher(child, frame);
                                  }),
                                  errorBuilder: (_, o, stack) =>
                                      Loader.blankIcon,
                                ),
                              ),
                              if (snap.data!.title.isNotEmpty)
                                Text('Title: ${snap.data!.title}'),
                              /* if (snap.data!.description.isNotEmpty)
                                Text('Description: ${snap.data!.description}'), */
                              if (snap.data!.duration.isNotEmpty)
                                Text('Duration: ${snap.data!.duration}'),
                              ElevatedButton(
                                child: const Text('Download video'),
                                onPressed: () async {
                                  try {
                                    final videoPath =
                                        await downloadYoutubeVideo();
                                    validator.videoPath = videoPath;
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ],
                          );
                        }
                      }),
                // TODO make downloading video optionnal
                SongTextField(validator),
                const SizedBox(height: widgetHeightSpacer),
                ArtistTextField(validator),
                const SizedBox(height: widgetHeightSpacer),
                // languageTextWidget
                GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => Theme(
                        data: Theme.of(context),
                        child: LanguagePickerDialog(
                          searchInputDecoration: const InputDecoration(
                            icon: Icon(Icons.search),
                          ),
                          isSearchable: true,
                          title: const Text(''),
                          onValuePicked: (Language language) async {
                            setState(() {
                              validator.language = language;
                              languageTextController.text =
                                  language.name.isEmpty &&
                                          language.nameEn.isEmpty
                                      ? ''
                                      : language.name.isEmpty
                                          ? language.nameEn
                                          : language.name;
                            });
                          },
                          itemBuilder: (language) => LanguageWidget(language),
                        ),
                      ),
                    );
                  },
                  child: TextFormField(
                    maxLines: 1,
                    style: const TextStyle(color: Colors.black),
                    enabled: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Language*',
                      labelStyle: const TextStyle(color: Colors.black),
                      icon: const Icon(Icons.translate),
                      errorText: validator.errorStore.languageError,
                    ),
                    controller: languageTextController,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class YoutubeUrlTextField<S extends FormStoreAbstract> extends StatelessWidget {
  final S store;
  const YoutubeUrlTextField(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      name: 'youtubeUrlTextField',
      builder: (_) => TextFormField(
        initialValue: store.song,
        key: const Key('youtube'),
        onChanged: (value) => store.youtubeUrl = value,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: 'Youtube Url',
            icon: const Icon(Icons.music_video),
            errorText: store.errorStore.youtubeUrlError),
        autofocus: true,
      ),
    );
  }
}

class SongTextField<S extends FormStoreAbstract> extends StatelessWidget {
  final S store;
  const SongTextField(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      name: 'songTextField',
      builder: (_) => TextFormField(
        initialValue: store.song,
        key: const Key('song'),
        onChanged: (value) => store.song = value,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: 'Song*',
            icon: const Icon(Icons.short_text),
            errorText: store.errorStore.songError),
        autofocus: false,
      ),
    );
  }
}

class ArtistTextField<S extends FormStoreAbstract> extends StatelessWidget {
  final S store;
  const ArtistTextField(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      name: 'artistTextField',
      builder: (_) => TextFormField(
        initialValue: store.artist,
        key: const Key('artist'),
        onChanged: (value) => store.artist = value,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: 'Artist*',
            icon: const Icon(Icons.supervised_user_circle_sharp),
            errorText: store.errorStore.artistError),
        autofocus: false,
      ),
    );
  }
}
