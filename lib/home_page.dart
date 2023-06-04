import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pallete.dart';
import 'package:flutter_application_1/feature_box.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'openai_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State <HomePage> createState() => _HomePageState();
}

class _HomePageState extends State <HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTexttoSpeech();
  }

  Future<void> initTexttoSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {

    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Hello Wadud'),
        ),
        leading: const Icon(Icons.waving_hand, size: 30,),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //virtual assistant icon
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                        ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image:DecorationImage(image: AssetImage(
                        'assets/images/virtualAssistant.png',
                        ),
                        ),
                    ),
                    
                  ),
                ],
              ),
            ),
      
            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40).copyWith(
                      top: 30,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 112, 185, 230),
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: Radius.zero,
                      ),
                    
                    ),
                    child:   Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child:  Text(
                        generatedContent == null? 'Hello, I am your Virtual Assistant, how can i help you?'
                        : generatedContent! , 
                        style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null? 20: 18,
                      ),),
                    ),
                ),
              ),
            ),
            if(generatedImageUrl !=null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.network(generatedImageUrl!)),
            ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl ==null ,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 20,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text('Here are a few suggestions', style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ),
            //suggestions list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: SlideInLeft(
                child: Column(
                  children: const [
                    FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText: 'A smarter way to stay organized and informed with ChatGPT',
                      ),
                      FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: 'Get inspired and stay creative with your personal assistant powered by Dall-E',
                      ),
                      FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText: 'Get the best voice assistant powered by Dall-E and ChatGPT',
                      ),
                  ],
                ),
              ),
            ),
          ]),
      ),
        floatingActionButton: ZoomIn(
          child: FloatingActionButton(
            backgroundColor: Pallete.firstSuggestionBoxColor,
            onPressed: () async{
              if(await speechToText.hasPermission && speechToText.isNotListening) {
                await startListening();
        
              }
        
              else if(speechToText.isListening) {
                final speech = await openAIService.isArtPromptAPI(lastWords);
                if(speech.contains('https')) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                  setState(() {});
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  await systemSpeak(speech);
                  setState(() {});
                }
                await systemSpeak(speech) ;
                await stopListening();
              } else {
                initSpeechToText();
              }
            },
            child:  Icon(speechToText.isListening ? Icons.stop : Icons.mic,
            ),
          ),
        ),
    );
  }
}