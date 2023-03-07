// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, unnecessary_string_interpolations, prefer_const_constructors_in_immutables, no_logic_in_create_state

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:bad_words/bad_words.dart';
// import 'package:just_audio/just_audio.dart';

final Map easterEggs = {
    "never": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            "gonna give you up",
            style: TextStyle(
                fontSize: 24
            ),
        ),
    ),
    "never gonna give you up": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            ("${"never gonna game\n"*10}\nNEW GAMER MERCH:- https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
            style: TextStyle(
                fontSize: 24
            ),
        ),
    ),
    "rick astley": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            "GOD",
            style: TextStyle(
                fontSize: 48
            ),
        ),
    ),
    "rick": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            "- roll",
            style: TextStyle(
                fontSize: 36
            ),
        ),
    ),
    "rickroll": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            "I have no idea, visit to learn more:- https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            style: TextStyle(
                fontSize: 36
            ),
        ),
    ),
    "shanvanth": () => Container(
        padding: EdgeInsets.all(25),
        child: Text(
            "Me, myself and I made this app",
            style: TextStyle(
                fontSize: 36
            ),
        ),
    ),
};


Widget emptyWidget() {
    return SizedBox.shrink();
}

Function phoneticParse = (Map list) {
    List listPhonetic = list["phonetics"];
    if (listPhonetic.isNotEmpty) {
        // print(listPhonetic[listPhonetic.length-1]);
        //https://pub.dev/packages/just_audio
        return listPhonetic[listPhonetic.length-1]["text"];
    } else {
        return "";
    }
};

void main() { // flutter build apk --no-shrink --release
// flutter install --use-application-binary="build\app\outputs\flutter-apk\app-release.apk"
    runApp(MaterialApp(
        initialRoute: "/home",
        routes: {
            "/home": (context) =>  Home(),
            "/help": (context) =>  Help(),
            "/about": (context) =>  About(),
        },
    ));
}

class Help extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Help"),
                backgroundColor: Colors.green.shade800,
            ),
            body: SafeArea(
                child: Container(
                    padding: EdgeInsets.fromLTRB(0,15,0,0),
                    child: Word(),
                )
            ),
        );
    }
}

class About extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("About"),
                backgroundColor: Colors.green.shade800,
            ),
            body: SafeArea(
                child: Container(
                    padding: EdgeInsets.all(25),
                    child: Text(
                        """Version: v0.3
Made By: Shanvanth Arunmozhi""",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: "CourierPrime",
                        ),
                    ),
                )
            ),
        );
    }
}

class Home extends StatefulWidget {
    @override
    State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

    final Filter badWordFilter = Filter();
    final TextEditingController _controller = TextEditingController();
    late FocusNode _focusNode;
    Widget displayWidget = Word();


    @override
    void initState() {
        super.initState();
        _focusNode = FocusNode();
        // _controller.addListener(() {
        //     _controller.text = badWordFilter.clean(_controller.text).split('').reversed.join();
        // });
    }

    @override
    void dispose() {
        _controller.dispose();
        _focusNode.dispose();
        super.dispose();
    }

    void unknownWord() {
        setState(() {
            displayWidget = Word(
                word:"Unknown Word",
                phonetic:r"\try removing spaces or extra words\",
                meanings: [],
                // origin:"${res[0]["origin"]}",
            );
            // displayDefine = """${res[0]["meanings"][0]["definitions"][0]["definition"]}""";
        });
    }

    void internetProblem() {
        setState(() {
            displayWidget = Word(
                word:"Internet Problem",
                phonetic:r"\try changing or switching on Wi-Fi\",
                meanings: [],
                // origin:"${res[0]["origin"]}",
            );
            // displayDefine = """${res[0]["meanings"][0]["definitions"][0]["definition"]}""";
        });
    }


    // ignore: non_constant_identifier_names
    void Define(String submitText) async {
        Widget oldWidget = displayWidget;
        setState(() => displayWidget = Column(
            children: <Widget>[
                Container(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(
                        color: Colors.green.shade800, 
                    )
                ),
                emptyWidget(),
            ]
        ));
        // displayText = "$submitText";
        if (!(submitText.startsWith("{") && submitText.endsWith("}"))) {
            if (easterEggs.containsKey(submitText)) {
                setState(() => displayWidget = easterEggs[submitText]());
                return null;
            }
        } else {
            submitText = submitText.substring(1,submitText.length-1);
        }
        if (badWordFilter.isProfane(submitText) || submitText.contains("*")) {
            _controller.text = badWordFilter.clean(submitText);
           setState(() {displayWidget = oldWidget;});
            return null;
        }
        if (submitText != "" && submitText != " ") {
            Uri url = Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$submitText");
            try {
                Response response = await get(url);
                if (response.statusCode == 200) {
                    var res = jsonDecode(response.body);
                    if (res.runtimeType == List) {
                        setState(() {
                            displayWidget = Word(
                                word:"${res[0]["word"]}",
                                phonetic:"${phoneticParse(res[0])}",
                                
                                meanings: res[0]["meanings"],
                                // origin:"${res[0]["origin"]}",
                            );
                            // displayDefine = """${res[0]["meanings"][0]["definitions"][0]["definition"]}""";
                        });
                    } else {
                        unknownWord();
                    }
                } else {
                    unknownWord();
                }
            }
            on  ClientException {
                internetProblem();
            }
        } else {
            setState(() {
                displayWidget = oldWidget;
            });
        }
    }

    void selectAll() => _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.value.text.length);
    
    final double rowofpagesHeight = 100;
    

    @override
    Widget build(BuildContext context) {
        Widget rowofpages = Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
                height: rowofpagesHeight,
                child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.all(25),
                                child: ElevatedButton.icon(
                                    onPressed: () {Navigator.pushNamed(context, "/help");},
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade800),
                                    ),
                                    label: Text(
                                            "Help",
                                            style:TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w300,
                                            ),
                                        ),
                                    icon: Icon(Icons.help),
                                ),
                            ),
                        ),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.all(25),
                                child: ElevatedButton.icon(
                                    onPressed: () {Navigator.pushNamed(context, "/about");},
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade800),
                                    ),
                                    label: Text(
                                            "About",
                                            style:TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w300,
                                            ),
                                        ),
                                    icon: Icon(Icons.person),
                                ),
                                ),
                        ),
                    ]
                ),
            ),
        );
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Book Of Words",
                    style: TextStyle(
                        fontFamily: "CourierPrime",
                        // fontSize: 45,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                backgroundColor: Colors.green.shade800,
                centerTitle: true,
            ),
            body: Stack(
                children: <Widget>[
                    ListView(
                        primary: false,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        shrinkWrap: true,
                        children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(25.0),
                                child: TextField(
                                    // onTap: selectAll,
                                    focusNode: _focusNode,
                                    controller: _controller,
                                    decoration: InputDecoration(
                                        hintText: "Type any word",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                                    ),
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontFamily: "CourierPrime",
                                        // fontWeight: FontWeight.bold,
                                    ),
                                    onSubmitted: Define,
                                ),
                            ),
                            displayWidget,
                            SizedBox(height: rowofpagesHeight,),
                        ],
                    ),
                    rowofpages,
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    if (_focusNode.hasFocus) {
                        Define(_controller.text);
                        _focusNode.unfocus();
                    } else {
                        _focusNode.requestFocus();
                        selectAll();
                    }
                },
                backgroundColor: Colors.green.shade800,
                child: Icon(Icons.search),
            ),
            bottomSheet: Padding(padding: EdgeInsets.only(bottom: rowofpagesHeight*4/3)),
        );
    }
}

class Word extends StatelessWidget {
    String word;
    String phonetic;
    List meanings;

    Word({this.word="{null}",this.phonetic=r"{\null\}",this.meanings=const[]});
    Widget meaningsTemplate() {
        return Container(
            padding: EdgeInsets.fromLTRB(0,10,5,10),
            child: ListView(
                primary: false,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                shrinkWrap: true,
                children: List.generate(meanings.length,(i) {
                    return Meaning(meaning:meanings[i],index:i);
                }),
            )
        );
    }
    @override
    Widget build(BuildContext context) {
        if (phonetic == r"{\null\}") {
            return Word(
                word: "Word",
                phonetic: "/phonetic/",
                meanings: [
                    {
                        "partOfSpeech": "Part of speech",
                        "definitions": [
                            {
                                "definition": "Definiton of word",
                                "synonyms": [
                                    "Synonyms of word"
                                ],
                                "antonyms": [
                                    "Antonyms of word"
                                ],
                                "example": "Example of word",
                            }
                        ],
                        "synonyms": [
                            "Synonyms of word"
                        ],
                        "antonyms": [
                            "Antonyms of word"
                        ]
                    }
                ],
            );
        } else {
            return Container(
                padding: EdgeInsets.fromLTRB(25,10,5,10),
                child: ListView(
                    primary: false,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    shrinkWrap: true,
                    children: <Widget>[
                            Wrap(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                Text(
                                    "$word\t",
                                    style: TextStyle(
                                        fontSize: 40,
                                        // fontFamily: "CourierPrime",
                                        // fontWeight: FontWeight.bold,
                                    ),
                                ),
                                Text(
                                    "$phonetic",
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontStyle: FontStyle.italic,
                                        // fontFamily: "CourierPrime",
                                    ),
                                ),
                                ],
                            ),
                        meaningsTemplate(),
                    ],
                ),
            );
        }
    }
}

Widget multiThesaurasGenerator(List<String> list,String textname) {
    if (list.isNotEmpty) {
        return Container(
            padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
            child: Text(
                "$textname: ${list.join(", ")}",
                style: TextStyle(
                    fontSize: 16,
                ),
            ),
        );
    } else {
        return emptyWidget();
    }
}

Widget similar(List<String> list) {
    return multiThesaurasGenerator(list, "Similar");
}
Widget opposite(List<String> list) {
    return multiThesaurasGenerator(list, "Opposite");
}

class Meaning extends StatelessWidget {
    Map meaning;
    int index;

    Meaning({this.meaning=const {},this.index=0});

    late String partOfSpeech;
    late List definitions;
    late List<String> synonyms;
    late List<String> antonyms;
    late List<Widget> widgets;

    Widget definitionsTemplate() {
        return ListView(
            primary: false,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            shrinkWrap: true,
            children: List.generate(definitions.length,(i) {
                return Definition(definition:definitions[i],index:i);
            }),
        );
    }

    @override
    Widget build(BuildContext context) {
        partOfSpeech = meaning["partOfSpeech"];
        definitions = meaning["definitions"];
        synonyms = List<String>.from(meaning["synonyms"]);
        antonyms = List<String>.from(meaning["antonyms"]);
        widgets = <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(
                    "${index+1}) $partOfSpeech",
                    style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 24,
                    ),
                ),
            ),
            similar(synonyms),
            opposite(antonyms),
            definitionsTemplate(),
        ];
        
        return Container(
            padding: EdgeInsets.fromLTRB(25,0,5,0),
            child: ListView(
                primary: false,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                shrinkWrap: true,
                children: widgets,
            ),
        );
    }
}

class Definition extends StatelessWidget {
    Map definition;
    int index;
    late List<Widget> widgets;
    late List<String> synonyms;
    late List<String> antonyms;
    late String defined;

    Definition({this.definition=const {},this.index=0});

    @override
    Widget build(BuildContext context) {
        defined = definition["definition"];
        synonyms = List<String>.from(definition["synonyms"]);
        antonyms = List<String>.from(definition["antonyms"]);
        widgets = <Widget>[
            Text(
                "${index+1}. $defined",
                style: TextStyle(
                    // color: Colors.grey,
                    // fontStyle: FontStyle.italic,
                    fontSize: 16,
                ),
            ),
            similar(synonyms),
            opposite(antonyms),
        ];
        if (definition.containsKey("example")) {
            widgets.add(multiThesaurasGenerator([definition["example"]], "Example"));
        }
        return Container(
            padding: EdgeInsets.fromLTRB(25,5,5,5),
            child: ListView(
                primary: false,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                shrinkWrap: true,
                children: widgets,
            ),
        );
    }
}

// class AudioButton extends StatefulWidget {
//     String url;

//     AudioButton(this.url);

//     @override
//     State<AudioButton> createState() => _AudioButtonState(url);
// }

// class _AudioButtonState extends State<AudioButton> {
//     String url;
//     final AudioPlayer _audioPlayer = AudioPlayer();
//     IconData icon = Icons.volume_up;
//     late dynamic func;

//     _AudioButtonState(this.url) {
//         _audioPlayer.setUrl(url);
//     }

//     void play() async {
//         await _audioPlayer.play();
//         setState(() {
//             icon = Icons.pause;
//             func = pause;
//         });
//     }

//     void pause() async {
//         await _audioPlayer.pause();
//         setState(() {
//             icon = Icons.play_arrow;
//             func = play;
//         });
//     }


//     @override
//     Widget build(BuildContext context) {
//         return FloatingActionButton.small(
//             onPressed: func(),
//             child: Icon(
//                 icon,
//                 color: Colors.green.shade800,
//             ),
//         );
//     }
// }