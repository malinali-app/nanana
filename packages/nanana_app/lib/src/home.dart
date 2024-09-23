import 'package:flutter/material.dart';
import 'package:nanana_app/src/app/l10n.dart';
import 'package:nanana_app/src/capture_create.dart';
import 'package:nanana_app/src/drawer.dart';
import 'package:nanana_app/src/capture_view.dart';
import 'package:nanana_app/src/mobx/crud_stores/captures.dart';
import 'package:nanana_app/src/models/capture.dart';
import 'package:nanana_app/src/widgets/app_bar_search.dart';
import 'package:provider/provider.dart';

class CapturesView extends StatelessWidget {
  const CapturesView({super.key});

  @override
  Widget build(BuildContext context) {
    final transcriptionStore =
        Provider.of<TranscriptionStore>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // TODO pursue search and use mobx reaction
        // title: TopBarSearchCaptures(transcriptionStore),
        // actions: [TopBarAction(transcriptionStore)],
      ),
      drawer: const DrawerNanana(),
      floatingActionButton: FloatingActionButton(
          tooltip: context.l10n.createNewTranscription,
          child: const Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateTranscriptionView(),
              ),
            );
          }),
      body: GridView.count(
        primary: true,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: <Widget>[
          for (final notation in CaptureDummy.captures) CardWidget(notation),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final Capture notation;
  const CardWidget(this.notation, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TranscriptionView(isEdit: false, capture: notation),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        elevation: 3.0,
        color: Colors.teal[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("${notation.artist}\n${notation.song}"),
            ],
          ),
        ),
      ),
    );
  }
}
