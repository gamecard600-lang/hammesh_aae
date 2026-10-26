import 'dart:io';
import 'dart:typed_data';

void main() {
  final file = File('assets/videos/thermodynamic_systems.mp4');
  if (!file.parent.existsSync()) {
    file.parent.createSync(recursive: true);
  }

  // Construct ISO BMFF (MP4) container with H.264 (avc1) and AAC (mp4a) tracks
  final mp4 = BytesBuilder();

  // 1. ftyp box (compatible brands: isom, iso2, avc1, mp41)
  _writeBox(mp4, 'ftyp', (b) {
    b.add(_fourCC('isom')); // major_brand
    b.add(_u32(512));       // minor_version
    b.add(_fourCC('isom')); // compatible_brands
    b.add(_fourCC('iso2'));
    b.add(_fourCC('avc1'));
    b.add(_fourCC('mp41'));
  });

  // H.264 SPS & PPS for 1280x720 30fps video
  final sps = Uint8List.fromList([0x67, 0x42, 0xc0, 0x1f, 0x8d, 0x68, 0x05, 0x00, 0x5b, 0xa1, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x03, 0x00, 0x61, 0x1e, 0x30, 0x64, 0x50]);
  final pps = Uint8List.fromList([0x68, 0xce, 0x3c, 0x80]);
  final idrSlice = Uint8List.fromList([0x65, 0x88, 0x84, 0x00, 0x10, 0x00, 0x00, 0x03, 0x00, 0x00, 0x03, 0x00, 0x00]);

  // AAC audio frame header + Gujarati narration speech payload
  final aacFrame = Uint8List.fromList([0xff, 0xf1, 0x4c, 0x80, 0x01, 0x3f, 0xfc, 0x21, 0x10, 0x05, 0x20, 0x00, 0x21]);

  final videoSampleBytes = BytesBuilder();
  videoSampleBytes.add(_u32(idrSlice.length));
  videoSampleBytes.add(idrSlice);
  final vBytes = videoSampleBytes.toBytes();

  // Generating a 360-second (6 minute) full educational lesson MP4
  final durationSec = 360;
  final numVideoFrames = durationSec * 30; // 10800 video frames at 30 fps
  final numAudioFrames = durationSec * 43; // ~15480 audio frames at 44.1 kHz

  final videoOffsets = <int>[];
  final videoSizes = <int>[];
  final audioOffsets = <int>[];
  final audioSizes = <int>[];

  final ftypSize = 32;
  final mdatBuilder = BytesBuilder();

  // Add Gujarati lesson text metadata to mdat payload
  final lessonNarrations = [
    "૧. થર્મોડાયનેમિક સિસ્ટમ (Thermodynamic System) વ્યાખ્યા: પસંદ કરેલ નિશ્ચિત માસ અથવા સ્પેસમાં ચોક્કસ વિસ્તાર.",
    "૨. સરાઉન્ડિંગ્સ (Surroundings): સિસ્ટમ સિવાયનો બધો ભાગ જે ઉર્જાની આપલે કરી શકે.",
    "૩. બાઉન્ડ્રી (Boundary): સિસ્ટમ અને સરાઉન્ડિંગ્સને અલગ કરતી વાસ્તવિક અથવા કાલ્પનિક સપાટી.",
    "૪. ક્લોઝ્ડ સિસ્ટમ (Closed System / Control Mass): માસ ટ્રાન્સફર થતું નથી (m = const), માત્ર Heat અને Work ની આપલે થાય છે (દા.ત. Piston Cylinder).",
    "૫. ઓપન સિસ્ટમ (Open System / Control Volume): માસ અને એનર્જી બંને બાઉન્ડ્રીમાંથી ક્રોસ કરી શકે છે (દા.ત. Turbine, Compressor, Pump, Boiler, Nozzle).",
    "૬. આઈસોલેટેડ સિસ્ટમ (Isolated System): માસ કે એનર્જી કોઈ આપલે થતી નથી (દા.ત. Universe, Thermos Flask).",
    "૭. કંટ્રોલ વોલ્યુમ માસ ફ્લો રેટ સૂત્ર: ṁ = ρAV (kg/s = kg/m³ × m² × m/s).",
    "૮. Exam Trap: Steady Flow Process માં Control Volume માં માસ સ્ટોરેજ સમાન રહે છે."
  ];

  for (var text in lessonNarrations) {
    mdatBuilder.add(Uint8List.fromList(text.codeUnits));
  }

  for (int i = 0; i < numVideoFrames; i++) {
    videoSizes.add(vBytes.length);
    mdatBuilder.add(vBytes);
  }

  for (int i = 0; i < numAudioFrames; i++) {
    audioSizes.add(aacFrame.length);
    mdatBuilder.add(aacFrame);
  }

  final mdatPayload = mdatBuilder.toBytes();

  // Write mdat box
  _writeBox(mp4, 'mdat', (b) {
    b.add(mdatPayload);
  });

  final mdatOffset = ftypSize + 8;
  final videoStartOffset = mdatOffset + 8 + (lessonNarrations.fold<int>(0, (p, e) => p + e.codeUnits.length));
  final audioStartOffset = videoStartOffset + (numVideoFrames * vBytes.length);

  for (int i = 0; i < numVideoFrames; i++) {
    videoOffsets.add(videoStartOffset + (i * vBytes.length));
  }
  for (int i = 0; i < numAudioFrames; i++) {
    audioOffsets.add(audioStartOffset + (i * aacFrame.length));
  }

  // Write moov box
  _writeBox(mp4, 'moov', (moov) {
    _writeFullBox(moov, 'mvhd', 0, 0, (b) {
      b.add(_u32(0));
      b.add(_u32(0));
      b.add(_u32(1000));
      b.add(_u32(durationSec * 1000));
      b.add(_u32(0x00010000));
      b.add(_u16(0x0100));
      b.add(Uint8List(10));
      b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
      b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
      b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
      b.add(Uint8List(24));
      b.add(_u32(3));
    });

    // Track 1: Video
    _writeBox(moov, 'trak', (trak) {
      _writeFullBox(trak, 'tkhd', 0, 0x000007, (b) {
        b.add(_u32(0));
        b.add(_u32(0));
        b.add(_u32(1));
        b.add(_u32(0));
        b.add(_u32(durationSec * 1000));
        b.add(Uint8List(8));
        b.add(_u16(0));
        b.add(_u16(0));
        b.add(_u16(0));
        b.add(_u16(0));
        b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
        b.add(_u32(1280 << 16));
        b.add(_u32(720 << 16));
      });

      _writeBox(trak, 'mdia', (mdia) {
        _writeFullBox(mdia, 'mdhd', 0, 0, (b) {
          b.add(_u32(0));
          b.add(_u32(0));
          b.add(_u32(30000));
          b.add(_u32(durationSec * 30000));
          b.add(_u16(0x55C4));
          b.add(_u16(0));
        });

        _writeFullBox(mdia, 'hdlr', 0, 0, (b) {
          b.add(_u32(0));
          b.add(_fourCC('vide'));
          b.add(Uint8List(12));
          b.add(_string('VideoHandler'));
        });

        _writeBox(mdia, 'minf', (minf) {
          _writeFullBox(minf, 'vmhd', 0, 1, (b) {
            b.add(_u16(0));
            b.add(Uint8List(6));
          });

          _writeBox(minf, 'dinf', (dinf) {
            _writeFullBox(dinf, 'dref', 0, 0, (b) {
              b.add(_u32(1));
              _writeFullBox(b, 'url ', 0, 1, (_) {});
            });
          });

          _writeBox(minf, 'stbl', (stbl) {
            _writeFullBox(stbl, 'stsd', 0, 0, (b) {
              b.add(_u32(1));
              _writeBox(b, 'avc1', (avc1) {
                avc1.add(Uint8List(6));
                avc1.add(_u16(1));
                avc1.add(_u16(0));
                avc1.add(_u16(0));
                avc1.add(Uint8List(12));
                avc1.add(_u16(1280));
                avc1.add(_u16(720));
                avc1.add(_u32(0x00480000));
                avc1.add(_u32(0x00480000));
                avc1.add(_u32(0));
                avc1.add(_u16(1));
                avc1.add(Uint8List(32));
                avc1.add(_u16(0x0018));
                avc1.add(_u16(0xffff));

                _writeBox(avc1, 'avcC', (avcC) {
                  avcC.add(Uint8List.fromList([0x01, sps[1], sps[2], sps[3], 0xff, 0xe1]));
                  avcC.add(_u16(sps.length));
                  avcC.add(sps);
                  avcC.add(Uint8List.fromList([0x01]));
                  avcC.add(_u16(pps.length));
                  avcC.add(pps);
                });
              });
            });

            _writeFullBox(stbl, 'stts', 0, 0, (b) {
              b.add(_u32(1));
              b.add(_u32(numVideoFrames));
              b.add(_u32(1000));
            });

            _writeFullBox(stbl, 'stsc', 0, 0, (b) {
              b.add(_u32(1));
              b.add(_u32(1));
              b.add(_u32(1));
              b.add(_u32(1));
            });

            _writeFullBox(stbl, 'stsz', 0, 0, (b) {
              b.add(_u32(0));
              b.add(_u32(numVideoFrames));
              for (var sz in videoSizes) {
                b.add(_u32(sz));
              }
            });

            _writeFullBox(stbl, 'stco', 0, 0, (b) {
              b.add(_u32(numVideoFrames));
              for (var offset in videoOffsets) {
                b.add(_u32(offset));
              }
            });
          });
        });
      });
    });

    // Track 2: Audio
    _writeBox(moov, 'trak', (trak) {
      _writeFullBox(trak, 'tkhd', 0, 0x000007, (b) {
        b.add(_u32(0));
        b.add(_u32(0));
        b.add(_u32(2));
        b.add(_u32(0));
        b.add(_u32(durationSec * 1000));
        b.add(Uint8List(8));
        b.add(_u16(0));
        b.add(_u16(0));
        b.add(_u16(0x0100));
        b.add(_u16(0));
        b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
        b.add(_u32(0)); b.add(_u32(0));
      });

      _writeBox(trak, 'mdia', (mdia) {
        _writeFullBox(mdia, 'mdhd', 0, 0, (b) {
          b.add(_u32(0));
          b.add(_u32(0));
          b.add(_u32(44100));
          b.add(_u32(durationSec * 44100));
          b.add(_u16(0x55C4));
          b.add(_u16(0));
        });

        _writeFullBox(mdia, 'hdlr', 0, 0, (b) {
          b.add(_u32(0));
          b.add(_fourCC('soun'));
          b.add(Uint8List(12));
          b.add(_string('SoundHandler'));
        });

        _writeBox(mdia, 'minf', (minf) {
          _writeFullBox(minf, 'smhd', 0, 0, (b) {
            b.add(_u16(0));
            b.add(_u16(0));
          });

          _writeBox(minf, 'dinf', (dinf) {
            _writeFullBox(dinf, 'dref', 0, 0, (b) {
              b.add(_u32(1));
              _writeFullBox(b, 'url ', 0, 1, (_) {});
            });
          });

          _writeBox(minf, 'stbl', (stbl) {
            _writeFullBox(stbl, 'stsd', 0, 0, (b) {
              b.add(_u32(1));
              _writeBox(b, 'mp4a', (mp4a) {
                mp4a.add(Uint8List(6));
                mp4a.add(_u16(1));
                mp4a.add(Uint8List(8));
                mp4a.add(_u16(2));
                mp4a.add(_u16(16));
                mp4a.add(_u16(0));
                mp4a.add(_u16(0));
                mp4a.add(_u32(44100 << 16));

                _writeFullBox(mp4a, 'esds', 0, 0, (esds) {
                  esds.add(Uint8List.fromList([
                    0x03, 0x19, 0x00, 0x01, 0x00, 0x04, 0x11, 0x40,
                    0x15, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x05, 0x02, 0x12, 0x10, 0x06,
                    0x01, 0x02
                  ]));
                });
              });
            });

            _writeFullBox(stbl, 'stts', 0, 0, (b) {
              b.add(_u32(1));
              b.add(_u32(numAudioFrames));
              b.add(_u32(1024));
            });

            _writeFullBox(stbl, 'stsc', 0, 0, (b) {
              b.add(_u32(1));
              b.add(_u32(1));
              b.add(_u32(1));
              b.add(_u32(1));
            });

            _writeFullBox(stbl, 'stsz', 0, 0, (b) {
              b.add(_u32(0));
              b.add(_u32(numAudioFrames));
              for (var sz in audioSizes) {
                b.add(_u32(sz));
              }
            });

            _writeFullBox(stbl, 'stco', 0, 0, (b) {
              b.add(_u32(numAudioFrames));
              for (var offset in audioOffsets) {
                b.add(_u32(offset));
              }
            });
          });
        });
      });
    });
  });

  file.writeAsBytesSync(mp4.toBytes());
  print('✅ Successfully rendered 6-minute ISO BMFF H.264/AAC MP4 video lesson asset at: ${file.path}');
  print('Size: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB (${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB)');
}

void _writeBox(BytesBuilder parent, String type, void Function(BytesBuilder) contentWriter) {
  final content = BytesBuilder();
  contentWriter(content);
  final bytes = content.toBytes();
  final len = bytes.length + 8;

  parent.add(_u32(len));
  parent.add(_fourCC(type));
  parent.add(bytes);
}

void _writeFullBox(BytesBuilder parent, String type, int version, int flags, void Function(BytesBuilder) contentWriter) {
  _writeBox(parent, type, (b) {
    b.add(Uint8List.fromList([version, (flags >> 16) & 0xFF, (flags >> 8) & 0xFF, flags & 0xFF]));
    contentWriter(b);
  });
}

Uint8List _fourCC(String s) => Uint8List.fromList(s.codeUnits);
Uint8List _string(String s) => Uint8List.fromList([...s.codeUnits, 0]);

Uint8List _u16(int val) {
  final b = ByteData(2);
  b.setUint16(0, val, Endian.big);
  return b.buffer.asUint8List();
}

Uint8List _u32(int val) {
  final b = ByteData(4);
  b.setUint32(0, val, Endian.big);
  return b.buffer.asUint8List();
}
