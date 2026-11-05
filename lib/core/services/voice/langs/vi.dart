part of '../voice_language.dart';

class _ViVoiceLanguage extends VoiceLanguage {
  const _ViVoiceLanguage()
    : super(
        code: 'vi',
        whisperLanguage: 'vi',
        systemSttLocales: const ['vi_VN', 'vi-VN', 'vi'],
        deviceTtsLocales: const ['vi-VN'],
        deviceTtsFallback: 'vi-VN',
        neuralVoiceId: 'vi_VN-vais1000-medium',
        // Kokoro has no Vietnamese voice; intentionally use English af_heart.
        streamingVoiceId: 'af_heart',
        // ponytail: preserve the fork's English narration/commands fallback;
        // add Vietnamese grammar after native-speaker review.
        transcript: _enTranscriptGrammar,
        messages: _enVoiceMessages,
        commands: _enVoiceCommands,
        speech: const _EnSpeechGrammar(),
      );

  @override
  LocalVoiceCommand? semanticCommand(String text) =>
      const _EnVoiceLanguage().semanticCommand(text);
}
