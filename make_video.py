import os
import asyncio
import numpy as np
import cv2
import edge_tts
from moviepy import VideoFileClip, AudioFileClip

# 1. Gujarati Narration Script
SCRIPT_TEXT = """
નમસ્તે મિત્રો, થર્મોડાયનેમિક્સમાં સૌથી પહેલો અને મહત્વનો કન્સેપ્ટ છે - થર્મોડાયનેમિક સિસ્ટમ અને કંટ્રોલ વોલ્યુમ.
સિસ્ટમ એટલે અવકાશમાં પસંદ કરાયેલ નિશ્ચિત માસ અથવા વિસ્તાર જેના પર આપણું વિશ્લેષણ કેન્દ્રિત થાય છે.
સિસ્ટમ સિવાયનો બાકીનો સમગ્ર વિસ્તાર એટલે સરાઉન્ડિંગ્સ, અને આ બંનેને અલગ કરતી સીમા એટલે બાઉન્ડ્રી.
ક્લોઝ્ડ સિસ્ટમમાં માસ ટ્રાન્સફર થતું નથી, માત્ર હીટ અને વર્કની આપ-લે થઈ શકે છે.
ઓપન સિસ્ટમ અથવા કંટ્રોલ વોલ્યુમમાં માસ અને એનર્જી બંને બાઉન્ડ્રીમાંથી પસાર થઈ શકે છે.
આઈસોલેટેડ સિસ્ટમમાં માસ કે એનર્જી કોઈપણ બાબતની આપ-લે થતી નથી.
કંટ્રોલ વોલ્યુમમાં માસ ફ્લો રેટનું સૂત્ર છે: એમ ડાટ બરાબર ડેન્સિટી ગુણ્યા એરિયા ગુણ્યા વેલોસિટી.
"""

AUDIO_FILE = "assets/videos/thermodynamic_systems_narration.mp3"
TEMP_VIDEO_FILE = "assets/videos/temp_visual_video.mp4"
FINAL_OUTPUT_FILE = "assets/videos/thermodynamic_systems.mp4"

async def generate_audio():
    print("🎙️ Generating Gujarati AI Voiceover (gu-IN-NiranjanNeural)...")
    comm = edge_tts.Communicate(SCRIPT_TEXT, "gu-IN-NiranjanNeural")
    await comm.save(AUDIO_FILE)
    print("✅ Audio generated successfully!")

def create_animated_video(duration_sec):
    print("🎥 Rendering Animated Visual Lesson Frames (1280x720 30fps)...")
    width, height = 1280, 720
    fps = 30
    total_frames = int(duration_sec * fps)

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(TEMP_VIDEO_FILE, fourcc, fps, (width, height))

    for frame_idx in range(total_frames):
        t = frame_idx / fps
        # Create dark engineering background
        img = np.zeros((height, width, 3), dtype=np.uint8)
        img[:] = (20, 15, 10) # Dark Slate Navy

        # Draw header
        cv2.rectangle(img, (0, 0), (width, 80), (45, 30, 20), -1)
        cv2.putText(img, "Thermodynamic Systems & Control Volume", (40, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.2, (255, 215, 0), 3)

        scene = int((t / duration_sec) * 5)

        if scene == 0:
            # Scene 1: System, Surroundings, Boundary
            cv2.rectangle(img, (200, 160), (1080, 620), (50, 40, 30), 2)
            cv2.putText(img, "SURROUNDINGS", (230, 200), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (180, 180, 180), 2)

            # System Box with pulse animation
            pulse = int(5 * np.sin(t * 4))
            cv2.rectangle(img, (400 - pulse, 260 - pulse), (880 + pulse, 520 + pulse), (180, 100, 30), -1)
            cv2.rectangle(img, (400 - pulse, 260 - pulse), (880 + pulse, 520 + pulse), (0, 255, 255), 3)
            cv2.putText(img, "THERMODYNAMIC SYSTEM", (430, 380), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2)
            cv2.putText(img, "Fixed Mass / Region in Space", (460, 420), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (200, 255, 200), 2)
            cv2.putText(img, "<-- BOUNDARY -->", (510, 560), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)

        elif scene == 1:
            # Scene 2: Closed System (Control Mass)
            cv2.putText(img, "1. CLOSED SYSTEM (Control Mass)", (80, 140), cv2.FONT_HERSHEY_SIMPLEX, 1.1, (0, 255, 255), 3)

            # Piston cylinder drawing
            cv2.rectangle(img, (400, 240), (880, 520), (60, 60, 60), 4)
            piston_pos = int(600 + 40 * np.sin(t * 3))
            cv2.rectangle(img, (piston_pos, 244), (piston_pos + 40, 516), (200, 100, 50), -1)

            cv2.putText(img, "MASS TRANSFER = NO (m = Constant)", (200, 590), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (50, 255, 50), 2)
            cv2.putText(img, "ENERGY TRANSFER = YES (Heat Q & Work W)", (200, 640), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 200, 50), 2)

        elif scene == 2:
            # Scene 3: Open System (Control Volume)
            cv2.putText(img, "2. OPEN SYSTEM (Control Volume)", (80, 140), cv2.FONT_HERSHEY_SIMPLEX, 1.1, (255, 215, 0), 3)

            # Control volume shape with mass inflow/outflow arrows
            cv2.rectangle(img, (450, 240), (830, 500), (30, 100, 180), -1)
            cv2.rectangle(img, (450, 240), (830, 500), (0, 255, 255), 3)
            cv2.putText(img, "CONTROL VOLUME", (490, 360), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2)
            cv2.putText(img, "(Turbine / Compressor / Pump)", (470, 400), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (200, 255, 255), 2)

            # Flow arrows
            flow_offset = int((t * 200) % 150)
            cv2.arrowedLine(img, (200 + flow_offset, 370), (440, 370), (0, 255, 0), 5, tipLength=0.2)
            cv2.putText(img, "m_in (Mass In)", (200, 340), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            cv2.arrowedLine(img, (840, 370), (1080 + flow_offset % 50, 370), (0, 255, 0), 5, tipLength=0.2)
            cv2.putText(img, "m_out (Mass Out)", (860, 340), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            cv2.putText(img, "MASS & ENERGY CROSS BOUNDARY", (320, 600), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (50, 255, 255), 2)

        elif scene == 3:
            # Scene 4: Mass Flow Rate Formula m_dot = rho * A * V
            cv2.putText(img, "MASS FLOW RATE EQUATION", (80, 140), cv2.FONT_HERSHEY_SIMPLEX, 1.1, (0, 255, 255), 3)

            # Formula Box
            cv2.rectangle(img, (250, 200), (1030, 360), (40, 30, 80), -1)
            cv2.rectangle(img, (250, 200), (1030, 360), (255, 215, 0), 3)
            cv2.putText(img, "m_dot = rho * A * V", (380, 300), cv2.FONT_HERSHEY_SIMPLEX, 1.8, (255, 255, 255), 4)

            cv2.putText(img, "m_dot = Mass Flow Rate (kg/s)", (300, 430), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (200, 255, 200), 2)
            cv2.putText(img, "rho = Fluid Density (kg/m3)", (300, 480), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (200, 255, 200), 2)
            cv2.putText(img, "A = Cross-Sectional Area (m2)", (300, 530), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (200, 255, 200), 2)
            cv2.putText(img, "V = Fluid Velocity (m/s)", (300, 580), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (200, 255, 200), 2)

        else:
            # Scene 5: High Yield Exam Trap & Summary
            cv2.rectangle(img, (150, 160), (1130, 600), (20, 40, 60), -1)
            cv2.rectangle(img, (150, 160), (1130, 600), (255, 100, 100), 3)
            cv2.putText(img, "EXAM SUMMARY & HIGH YIELD TRAP", (220, 220), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 215, 0), 3)

            cv2.putText(img, "1. Closed System (Control Mass) = No Mass Transfer", (200, 300), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
            cv2.putText(img, "2. Open System (Control Volume) = Mass & Energy Transfer", (200, 360), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
            cv2.putText(img, "3. Isolated System = Neither Mass nor Energy Transfer", (200, 420), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
            cv2.putText(img, "4. Steady Flow CV: Storage inside CV remains constant", (200, 480), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
            cv2.putText(img, "5. Formula: m_dot = rho * A * V (kg/s)", (200, 540), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 100), 2)

        out.write(img)

    out.release()
    print("✅ Video frames successfully rendered!")

def combine_audio_and_video():
    print("🎬 Combining Video + Gujarati Audio with H.264/AAC encoding...")
    video_clip = VideoFileClip(TEMP_VIDEO_FILE)
    audio_clip = AudioFileClip(AUDIO_FILE)

    # Set audio to video and loop/trim video to audio length
    final_clip = video_clip.with_duration(audio_clip.duration)
    final_clip = final_clip.with_audio(audio_clip)

    final_clip.write_videofile(
        FINAL_OUTPUT_FILE,
        codec="libx264",
        audio_codec="aac",
        fps=30,
        preset="fast"
    )

    video_clip.close()
    audio_clip.close()
    final_clip.close()

    # Clean up temp video file
    if os.path.exists(TEMP_VIDEO_FILE):
        os.remove(TEMP_VIDEO_FILE)

    print(f"🎉 Final 100% Valid H.264/AAC Video Saved: {FINAL_OUTPUT_FILE}")

if __name__ == "__main__":
    asyncio.run(generate_audio())
    audio_dur = AudioFileClip(AUDIO_FILE).duration
    print(f"Audio duration: {audio_dur:.2f} seconds")
    create_animated_video(audio_dur)
    combine_audio_and_video()
