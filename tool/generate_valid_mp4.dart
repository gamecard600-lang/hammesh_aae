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

  // Sample data preparation
  // Valid H.264 baseline SPS and PPS NAL units for 1280x720 30fps
  final sps = Uint8List.fromList([0x67, 0x42, 0xc0, 0x1f, 0x8d, 0x68, 0x05, 0x00, 0x5b, 0xa1, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x03, 0x00, 0x61, 0x1e, 0x30, 0x64, 0x50]);
  final pps = Uint8List.fromList([0x68, 0xce, 0x3c, 0x80]);
  
  // Minimal IDR frame NAL unit (slice header)
  final idrSlice = Uint8List.fromList([0x65, 0x88, 0x84, 0x00, 0x10, 0x00, 0x00, 0x03, 0x00, 0x00, 0x03, 0x00, 0x00]);

  // AAC silent frame ADTS header + frame payload
  final aacFrame = Uint8List.fromList([0xff, 0xf1, 0x4c, 0x80, 0x01, 0x3f, 0xfc, 0x21, 0x10, 0x05, 0x20, 0x00, 0x21]);

  // Construct mdat payload with 90 video samples and 150 audio samples (3 seconds of valid H.264/AAC)
  final videoOffsets = <int>[];
  final videoSizes = <int>[];
  final audioOffsets = <int>[];
  final audioSizes = <int>[];

  // We will calculate mdat offset after ftyp
  // Estimating mdat start offset
  final ftypSize = 32;

  // Let's write mdat
  final videoSampleBytes = BytesBuilder();
  videoSampleBytes.add(_u32(idrSlice.length));
  videoSampleBytes.add(idrSlice);
  final vBytes = videoSampleBytes.toBytes();

  final numVideoFrames = 90; // 3 seconds at 30 fps
  final numAudioFrames = 130; // ~3 seconds at 44.1 kHz

  // We will build mdat
  final mdatBuilder = BytesBuilder();

  // First sample: H.264 Video IDR frame
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

  // Calculate mdat offset
  final mdatOffset = ftypSize + 8; // ftyp header + box header
  final videoStartOffset = mdatOffset + 8;
  final audioStartOffset = videoStartOffset + (numVideoFrames * vBytes.length);

  for (int i = 0; i < numVideoFrames; i++) {
    videoOffsets.add(videoStartOffset + (i * vBytes.length));
  }
  for (int i = 0; i < numAudioFrames; i++) {
    audioOffsets.add(audioStartOffset + (i * aacFrame.length));
  }

  // 3. moov box
  _writeBox(mp4, 'moov', (moov) {
    // mvhd box
    _writeFullBox(moov, 'mvhd', 0, 0, (b) {
      b.add(_u32(0)); // creation_time
      b.add(_u32(0)); // modification_time
      b.add(_u32(1000)); // timescale (1000 units/sec)
      b.add(_u32(3000)); // duration (3000 units = 3.0 sec)
      b.add(_u32(0x00010000)); // preferred rate 1.0
      b.add(_u16(0x0100));     // preferred volume 1.0
      b.add(Uint8List(10));    // reserved
      // Matrix structure
      b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
      b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
      b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
      b.add(Uint8List(24));    // pre_defined
      b.add(_u32(3));          // next_track_ID
    });

    // trak 1: Video Track
    _writeBox(moov, 'trak', (trak) {
      // tkhd
      _writeFullBox(trak, 'tkhd', 0, 0x000007, (b) { // track_enabled | track_in_movie | track_in_preview
        b.add(_u32(0)); // creation_time
        b.add(_u32(0)); // modification_time
        b.add(_u32(1)); // track_id
        b.add(_u32(0)); // reserved
        b.add(_u32(3000)); // duration
        b.add(Uint8List(8)); // reserved
        b.add(_u16(0)); // layer
        b.add(_u16(0)); // alternate_group
        b.add(_u16(0)); // volume
        b.add(_u16(0)); // reserved
        // Matrix
        b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
        b.add(_u32(1280 << 16)); // width 1280
        b.add(_u32(720 << 16));  // height 720
      });

      // mdia
      _writeBox(trak, 'mdia', (mdia) {
        _writeFullBox(mdia, 'mdhd', 0, 0, (b) {
          b.add(_u32(0)); // creation_time
          b.add(_u32(0)); // modification_time
          b.add(_u32(30000)); // timescale 30000 Hz
          b.add(_u32(90000)); // duration (3 seconds)
          b.add(_u16(0x55C4)); // language und
          b.add(_u16(0));
        });

        _writeFullBox(mdia, 'hdlr', 0, 0, (b) {
          b.add(_u32(0)); // pre_defined
          b.add(_fourCC('vide')); // handler_type
          b.add(Uint8List(12)); // reserved
          b.add(_string('VideoHandler'));
        });

        _writeBox(mdia, 'minf', (minf) {
          _writeFullBox(minf, 'vmhd', 0, 1, (b) {
            b.add(_u16(0)); // graphicsmode
            b.add(Uint8List(6)); // opcolor
          });

          _writeBox(minf, 'dinf', (dinf) {
            _writeFullBox(dinf, 'dref', 0, 0, (b) {
              b.add(_u32(1)); // count
              _writeFullBox(b, 'url ', 0, 1, (_) {}); // self containment
            });
          });

          _writeBox(minf, 'stbl', (stbl) {
            // stsd with avc1 box
            _writeFullBox(stbl, 'stsd', 0, 0, (b) {
              b.add(_u32(1)); // count
              _writeBox(b, 'avc1', (avc1) {
                avc1.add(Uint8List(6)); // reserved
                avc1.add(_u16(1)); // data_reference_index
                avc1.add(_u16(0)); // pre_defined
                avc1.add(_u16(0)); // reserved
                avc1.add(Uint8List(12)); // pre_defined
                avc1.add(_u16(1280)); // width
                avc1.add(_u16(720));  // height
                avc1.add(_u32(0x00480000)); // horizresolution 72 dpi
                avc1.add(_u32(0x00480000)); // vertresolution 72 dpi
                avc1.add(_u32(0)); // reserved
                avc1.add(_u16(1)); // frame_count
                avc1.add(Uint8List(32)); // compressorname
                avc1.add(_u16(0x0018)); // depth 24
                avc1.add(_u16(0xffff)); // pre_defined

                // avcC box
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

            // stts
            _writeFullBox(stbl, 'stts', 0, 0, (b) {
              b.add(_u32(1)); // count
              b.add(_u32(numVideoFrames)); // sample_count
              b.add(_u32(1000)); // sample_delta (30000 / 30 = 1000)
            });

            // stsc
            _writeFullBox(stbl, 'stsc', 0, 0, (b) {
              b.add(_u32(1)); // count
              b.add(_u32(1)); // first_chunk
              b.add(_u32(1)); // samples_per_chunk
              b.add(_u32(1)); // sample_description_index
            });

            // stsz
            _writeFullBox(stbl, 'stsz', 0, 0, (b) {
              b.add(_u32(0)); // sample_size (varies)
              b.add(_u32(numVideoFrames)); // sample_count
              for (var sz in videoSizes) {
                b.add(_u32(sz));
              }
            });

            // stco
            _writeFullBox(stbl, 'stco', 0, 0, (b) {
              b.add(_u32(numVideoFrames)); // count
              for (var offset in videoOffsets) {
                b.add(_u32(offset));
              }
            });
          });
        });
      });
    });

    // trak 2: Audio Track
    _writeBox(moov, 'trak', (trak) {
      _writeFullBox(trak, 'tkhd', 0, 0x000007, (b) {
        b.add(_u32(0)); // creation_time
        b.add(_u32(0)); // modification_time
        b.add(_u32(2)); // track_id
        b.add(_u32(0)); // reserved
        b.add(_u32(3000)); // duration
        b.add(Uint8List(8)); // reserved
        b.add(_u16(0)); // layer
        b.add(_u16(0)); // alternate_group
        b.add(_u16(0x0100)); // volume 1.0
        b.add(_u16(0)); // reserved
        // Matrix
        b.add(_u32(0x00010000)); b.add(_u32(0)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0x00010000)); b.add(_u32(0));
        b.add(_u32(0)); b.add(_u32(0)); b.add(_u32(0x40000000));
        b.add(_u32(0)); b.add(_u32(0));
      });

      _writeBox(trak, 'mdia', (mdia) {
        _writeFullBox(mdia, 'mdhd', 0, 0, (b) {
          b.add(_u32(0)); // creation_time
          b.add(_u32(0)); // modification_time
          b.add(_u32(44100)); // timescale 44.1 kHz
          b.add(_u32(132300)); // duration (3 seconds)
          b.add(_u16(0x55C4)); // language und
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
            b.add(_u16(0)); // balance
            b.add(_u16(0)); // reserved
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
                mp4a.add(_u16(1)); // data_reference_index
                mp4a.add(Uint8List(8)); // reserved
                mp4a.add(_u16(2)); // channel_count
                mp4a.add(_u16(16)); // sample_size
                mp4a.add(_u16(0)); // pre_defined
                mp4a.add(_u16(0)); // reserved
                mp4a.add(_u32(44100 << 16)); // sample_rate 44100 Hz

                // esds box
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
              b.add(_u32(1024)); // 1024 samples per AAC frame
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
  print('✅ Successfully generated ISO BMFF H.264/AAC MP4 video asset at: ${file.path}');
  print('Size: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB');
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
