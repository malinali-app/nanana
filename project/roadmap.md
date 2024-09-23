# nanana

- TODO : NANANA recréer un compte à Kevin sur outlook pour gérer le hosting 

A crowdsourcing app to bring out African lyrics captures and translations.

db content can be search on the web
contributions must be done through the app (android,iOS,mac,windows)


// edit du 31 Mai 2024 (retour de Taïbou)

//Alphadio Dara
//Djikké
//https://youtu.be/QLh9-t5GO1Q?si=N20h5usZXzjNC6OC

// ! incruste la vidéo pas le mp3
// je crois qu'il y a un player open source qui pourrait être mieux que l'autre package
// met sekouba bambino
// TODO remove icons.save, saving should be automatic
// saving should/could work offline

sekouoba bambino
https://youtu.be/ZNT9fmH8-Tk?si=h8borKfankfJcFnE

//TODO : icone pour intent qui ouvre youtube (webview qui redirige)
// TODO : un peu + d'espace entre le player et l'editeur
// autofocus sur l'éditeur et hint si possible (...)

// FAB en bas à droite avec les actions
// après piublication je récupère une url
// publier puis partager

// ajouter traduit par
// ajouter des likes
// ajouter le nombre de vues


// edit du 29 Mai 2024
Concernant les endpoints de transcription ce serait bien de séparer la création de l'en-tête de la transcription (song, artist, language, youtubeUrl) du corps (lyrics)
On ne souhaite pt être pas mettre à jour les infos de l'en-tête et par contrer les lyrics seront bcp mises à jour, au fur et à mesure de la transcription.

sauvegarde de la saisie des paroles automatiques


## user space

User (
	email,
	password,
	name,
	avatar,
	dateCreate,
	dateUpdate,
	captures,
	translations,
	evaluations,
	comments
)
- user can access their contributions from user view
- user can access latest contributions from home view
- user can search for a song by artist, song, album, source language, is translation available
- if song is found in db
	- user can rank others contributions (i.e. à la stackoverflow) // phase2
	- user can comment // phase2
- if no match in db suggest to create a first transcription

## transcribe

Capture (
	required id,
	required artist,
	album = '',
	required song,
	required youtubeUrl,
	required language,
	required userId,
	required dateCreate,
	dateUpdate?,
	isPublished, // TODO add this
	lyrics = ''
)

- user can play youtube video
- user can run a speech to text function to prepare lyrics
- user can write lyrics in a custom text editor
- user can save/update/delete the transcription
- user can share the transcription url

_once song is saved user can translate it_

## translate

Translation (
	required id,
	required transcriptionId,
	required userId,
	required sourceLanguage,
	required targetLanguage,
	required dateCreate,
	dateUpdate?,
	text = ''
)

- user can run a AI/MT function to prepare translation
- user can write lyrics (line per line line below the transcription for mobile/responsive design)
- user can save/update/delete the translation
- user can share the transcription url


## tech issues
- user authent (firebase for quick/free set-up ?)
- language list is constraining on purpose
	- it will prevent users from creating captures from languages __WE__ are not interested in
- languages list for AI speech2text and for AI translation must be filtered to match this list
- AI languages lists will probably not match this list, it would be better to grey-out the option


// 2024_05_20 
- le site web sera propulsé aussi par top shelf en html