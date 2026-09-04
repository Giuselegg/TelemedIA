import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

Uint8List? convertiImmagineInPng(Uint8List bytes) {
  final immagine = img.decodeImage(bytes);
  if (immagine == null) return null;
  return Uint8List.fromList(img.encodePng(immagine));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messaggi = [];
  bool _isLoading = false;
  bool _isElaborazioneFile = false;
  PlatformFile? _fileSelezionato;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  static const Color colorPrimaryDark = Color(0xFF0A2540);
  static const Color colorTealAccent = Color(0xFF00A896);
  static const Color colorBlueAction = Color(0xFF0066FF);
  static const Color colorBgLight = Color(0xFFE8F1F5);
  static const Color colorSponsorBg = Color(0xFFDDEFF2);
  static const Color colorUserBubble = Color(0xFFD0E8FF);
  static const Color colorAiBubble = Colors.white;

  Future<void> _toggleMicrofono() async {
    if (!_isListening) {
      final disponibile = await _speech.initialize();
      if (disponibile) {
        setState(() {
          _isListening = true;
        });
        await _speech.listen(
          onResult: (risultato) {
            setState(() {
              _messageController.text = risultato.recognizedWords;
            });
          },
        );
      }
    } else {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<String> _askAI(String richiesta) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://telemedia-olim.onrender.com/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'richiesta': richiesta,
              'fileName': _fileSelezionato?.name,
              'fileBytes': _fileSelezionato?.bytes != null
                  ? base64Encode(_fileSelezionato!.bytes!)
                  : null,
              'messaggi': _messaggi
                  .expand(
                    (m) => [
                      {'ruolo': 'user', 'contenuto': m['utente'] ?? ''},
                      {'ruolo': 'assistant', 'contenuto': m['ai'] ?? ''},
                    ],
                  )
                  .toList(),
            }),
          )
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['risposta'] ?? 'Nessuna risposta ricevuta.';
      }
      return 'Errore del server (${response.statusCode}): impossibile elaborare il file.';
    } catch (e) {
      return 'Impossibile collegarsi al server TelemedIA. Il file potrebbe essere troppo grande o la connessione è scaduta.';
    }
  }

  void _inviaMessaggio() async {
    final richiesta = _messageController.text.trim();
    if (richiesta.isEmpty && _fileSelezionato == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    _messaggi.add({
      'utente': _fileSelezionato != null
          ? '$richiesta\n📎 File allegato: ${_fileSelezionato!.name}'
          : richiesta,
      'ai': '',
    });
    final prompt = richiesta.isEmpty ? 'Analizza il file allegato.' : richiesta;
    final risposta = await _askAI(prompt);
    setState(() {
      _messaggi[_messaggi.length - 1] = {
        'utente': _messaggi[_messaggi.length - 1]['utente'] ?? '',
        'ai': risposta,
      };
      _messageController.clear();
      _fileSelezionato = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: colorTealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/screens/assets/giuseppe2024.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'TELEMED',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: colorPrimaryDark,
                            ),
                          ),
                          Text(
                            'IA',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: colorTealAccent,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Il tuo partner digitale per ogni esigenza",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A607A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 700;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorPrimaryDark.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      _messaggi.isEmpty
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Benvenuto in TelemedIA',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorPrimaryDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'La nostra Intelligenza Artificiale è pronta ad aiutarti.',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: _messaggi.length,
                                              itemBuilder: (context, index) {
                                                final messaggio =
                                                    _messaggi[index];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                              maxWidth:
                                                                  constraints
                                                                      .maxWidth *
                                                                  0.5,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              colorUserBubble,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          messaggio['utente'] ??
                                                              '',
                                                          style: const TextStyle(
                                                            color:
                                                                colorPrimaryDark,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    if ((messaggio['ai'] ?? '')
                                                        .isNotEmpty)
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                maxWidth:
                                                                    constraints
                                                                        .maxWidth *
                                                                    0.55,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 12,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                colorAiBubble,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFFE2E8F0,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                messaggio['ai'] ??
                                                                    '',
                                                                style: const TextStyle(
                                                                  color:
                                                                      colorPrimaryDark,
                                                                  fontSize: 14,
                                                                  height: 1.4,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Clipboard.setData(
                                                                      ClipboardData(
                                                                        text:
                                                                            messaggio['ai'] ??
                                                                            '',
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          4.0,
                                                                        ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .copy,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                );
                                              },
                                            ),
                                      if (_isLoading || _isElaborazioneFile)
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: colorTealAccent
                                                    .withValues(alpha: 0.3),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorPrimaryDark
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  color: colorTealAccent,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _isElaborazioneFile
                                                      ? 'Preparazione del file in corso...'
                                                      : 'TelemedIA sta elaborando...',
                                                  style: const TextStyle(
                                                    color: colorPrimaryDark,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Un momento di pazienza per favore',
                                                  style: TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorPrimaryDark.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        minLines: 1,
                                        maxLines: 3,
                                        style: const TextStyle(
                                          color: colorPrimaryDark,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _fileSelezionato != null
                                              ? 'Allegato: ${_fileSelezionato!.name}'
                                              : 'Scrivi o parla con TelemedIA...',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                        ),
                                        onSubmitted: (_) => _inviaMessaggio(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.attach_file,
                                        color: Color(0xFF64748B),
                                        size: 22,
                                      ),
                                      tooltip: 'Allega file o video',
                                      onPressed: () async {
                                        final result =
                                            await FilePicker.pickFiles(
                                              withData: true,
                                              type: FileType.any,
                                            );
                                        if (result != null) {
                                          setState(() {
                                            _isElaborazioneFile = true;
                                          });
                                          await Future.delayed(
                                            const Duration(milliseconds: 100),
                                          );
                                          PlatformFile file =
                                              result.files.single;
                                          final extension = file.extension
                                              ?.toLowerCase();
                                          if ((extension == 'webp' ||
                                                  extension == 'gif') &&
                                              file.bytes != null) {
                                            try {
                                              final pngBytes = await compute(
                                                convertiImmagineInPng,
                                                file.bytes!,
                                              );
                                              if (pngBytes != null) {
                                                final nomeFile =
                                                    '${file.name.replaceAll(RegExp(r'\.(webp|gif)$', caseSensitive: false), '')}.png';
                                                file = PlatformFile(
                                                  name: nomeFile,
                                                  size: pngBytes.length,
                                                  bytes: Uint8List.fromList(
                                                    pngBytes,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              debugPrint(
                                                'Errore conversione immagine: $e',
                                              );
                                            }
                                          }
                                          setState(() {
                                            _fileSelezionato = file;
                                            _isElaborazioneFile = false;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isListening
                                            ? Icons.stop_circle
                                            : Icons.mic,
                                        color: colorTealAccent,
                                        size: 24,
                                      ),
                                      tooltip: _isListening
                                          ? 'Ferma registrazione'
                                          : 'Parla',
                                      onPressed: _toggleMicrofono,
                                    ),
                                    const SizedBox(width: 4),
                                    Material(
                                      color: colorBlueAction,
                                      shape: const CircleBorder(),
                                      elevation: 0,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: _inviaMessaggio,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorSponsorBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'SPAZIO SPONSOR',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: colorTealAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Icon(
                                    Icons.health_and_safety_outlined,
                                    size: 56,
                                    color: colorTealAccent.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Insieme per la tua salute',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Questo spazio è dedicato ai partner che supportano l\'innovazione e il benessere.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
