import os
import asyncio
import subprocess
import numpy as np
import cv2
from PIL import Image, ImageDraw, ImageFont
import edge_tts
from moviepy import VideoFileClip, AudioFileClip, concatenate_videoclips

FONT_PATH = "C:/Windows/Fonts/Nirmala.ttc"

def get_font(size):
    try:
        return ImageFont.truetype(FONT_PATH, size)
    except Exception:
        return ImageFont.load_default()

def get_audio_duration(path):
    clip = AudioFileClip(path)
    dur = clip.duration
    clip.close()
    return dur

FLUID_TOPICS = [
    {
        "topic_num": "2.10",
        "topic_idx": 9,
        "name": "Hydraulic Turbines",
        "filename": "hydraulic_turbines.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. હાઇડ્રોલિક ટર્બાઇન્સનું વર્ગીકરણ (Turbine Classification)",
                "text": "ટર્બાઇન હાઇડ્રોલિક ઉર્જાનું મિકેનિકલ ઉર્જામાં રૂપાંતર કરે છે! ૧. પેલ્ટન વ્હીલ: હાઇ હેડ, લો ડિસ્ચાર્જ ઇમ્પલ્સ ટર્બાઇન. ૨. ફ્રાન્સિસ ટર્બાઇન: મીડિયમ હેડ, મીડિયમ ડિસ્ચાર્જ મિશ્ર રિએક્શન ટર્બાઇન. ૩. કપ્લાન ટર્બાઇન: લો હેડ, હાઇ ડિસ્ચાર્જ એક્સિયલ રિએક્શન ટર્બાઇન!",
                "type": "turbines_classification"
            },
            {
                "id": 2,
                "title": "૨. સ્પેસિફિક સ્પીડ સૂત્ર (Specific Speed N_s = N sqrt(P) / H^(5/4))",
                "text": "ટર્બાઇનની સ્પેસિફિક સ્પીડ N_s બરાબર N ગુણ્યા અંડરરૂટ P ભાગ્યા H ની ૫/૪ ઘાત થાય છે! પેલ્ટન વ્હીલ માટે N_s ઓછી (10-35), ફ્રાન્સિસ માટે મીડિયમ (60-300), અને કપ્લાન માટે સૌથી વધુ N_s (300-1000) હોય છે.",
                "type": "specific_speed_turbines"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: લો હેડ અને હાઇ ડિસ્ચાર્જ માટે કયું ટર્બાઇન વપરાય છે? સાચો જવાબ: Kaplan Turbine! પ્રશ્ન ૨: ટર્બાઇનની Specific Speed નું સૂત્ર કયું છે? સાચો જવાબ: N_s = N * sqrt(P) / H^(5/4)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.11",
        "topic_idx": 10,
        "name": "Centrifugal & Reciprocating Pumps",
        "filename": "centrifugal_and_reciprocating_pumps.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. સેન્ટ્રીફ્યુગલ પંપ અને પ્રાઇમિંગ (Centrifugal Pump & Priming)",
                "text": "સેન્ટ્રીફ્યુગલ પંપ મિકેનિકલ ઉર્જાનું હાઇડ્રોલિક પ્રેશર ઉર્જામાં રૂપાંતર કરે છે. તે ફોર્સ્ડ વર્ટેક્સ મોશન પર કામ કરે છે. ચાલુ કરતા પહેલાં સક્શન પાઇપમાંથી હવા કાઢી પાણી ભરવાની ક્રિયાને પ્રાઇમિંગ કહેવાય છે! પ્રાઇમિંગ વગર પંપ ચાલુ કરવાથી હવાના લીધે પંપ પ્રેશર બનાવી શકતો નથી.",
                "type": "centrifugal_pump"
            },
            {
                "id": 2,
                "title": "૨. રેસિપ્રોકેટીંગ પંપ અને એર વેસેલ્સ (Reciprocating Pump & Air Vessels)",
                "text": "રેસિપ્રોકેટીંગ પંપ એ પોઝિટિવ ડિસ્પ્લેસમેન્ટ પંપ છે. તેમાં પિસ્ટન સિલિન્ડરમાં ખસે છે. સળંગ સતત પ્રવાહ મેળવવા અને ફ્રિક્શન લોસ ઘટાડવા સક્શન અને ડિલિવરી પાઇપ પર એર વેસેલ લગાડવામાં આવે છે!",
                "type": "reciprocating_pump"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સેન્ટ્રીફ્યુગલ પંપ કયા સિદ્ધાંત પર કામ કરે છે? સાચો જવાબ: Forced Vortex Motion! પ્રશ્ન ૨: પંપમાં ચાલુ કરતા પહેલા હવા કાઢવાની પ્રક્રિયાને શું કહેવાય? સાચો જવાબ: Priming!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.12",
        "topic_idx": 11,
        "name": "Compressible Flow",
        "filename": "compressible_flow.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. મેક નંબર અને ફ્લો રિજિમ્સ (Mach Number & Flow Regimes)",
                "text": "મેક નંબર Ma બરાબર પ્રવાહનો વેગ V ભાગ્યા સાઉન્ડની ઝડપ C થાય છે! ૧. Ma < 1 હોય તો સબસોનિક ફ્લો, ૨. Ma = 1 હોય તો સોનિક ફ્લો, ૩. Ma > 1 હોય તો સુપરસોનિક ફ્લો, અને ૪. Ma > 5 હોય તો હાઇપરસોનિક ફ્લો કહેવાય છે!",
                "type": "mach_number"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સુપરસોનિક ફ્લો માટે મેક નંબર Ma કેટલો હોવો જોઈએ? સાચો જવાબ: Ma > 1!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.13",
        "topic_idx": 12,
        "name": "Open Channel Flow",
        "filename": "open_channel_flow.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. મોસ્ટ ઇકોનોમિકલ ચેનલ સેક્શન (Most Economical Section)",
                "text": "ઓપન ચેનલમાં ફ્રી સપાટી પર વાતાવરણીય દબાણ હોય છે. મોસ્ટ ઇકોનોમિકલ સેક્શન માટે ઓછામાં ઓછી વેટ્ટેડ પેરીમીટર P પર મહત્તમ ડિસ્ચાર્જ Q મળે છે! રેક્ટેન્ગ્યુલર સેક્શન માટે હાઇડ્રોલિક મીન ડેપ્થ m બરાબર y / 2 થાય છે.",
                "type": "open_channel"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: મોસ્ટ ઇકોનોમિકલ રેક્ટેન્ગ્યુલર ચેનલ માટે હાઇડ્રોલિક રેડિયસ R કેટલું હોવું જોઈએ? સાચો જવાબ: R = y / 2 (અડધી ઊંડાઈ)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.14",
        "topic_idx": 13,
        "name": "Model Analysis & Similitude",
        "filename": "model_analysis_and_similitude.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ડાઇમેન્શનલેસ નંબર્સ (Froude, Reynolds, Weber Numbers)",
                "text": "સિમીલીટ્યુડ એટલે મોડેલ અને પ્રોટોટાઇપ વચ્ચેની સામ્યતા! ૧. ફ્રૌડ નંબર Fr એ ગ્રેવિટી ફ્લો (ડેમ, સ્પિલવે) માં વપરાય છે. ૨. રેનોલ્ડ્સ નંબર Re પાઇપ ફ્લોમાં વપરાય છે. ૩. વેબર નંબર We સરફેસ ટેન્શન ફ્લોમાં વપરાય છે. ૪. માચ નંબર Ma કોમ્પ્રેસિબલ ફ્લોમાં વપરાય છે.",
                "type": "dimensionless_numbers"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સ્પિલવે અને ઓપન ચેનલ મોડેલ એનાલિસિસમાં કયો ડાઇમેન્શનલેસ નંબર વપરાય છે? સાચો જવાબ: Froude Number (ફ્રૌડ નંબર)!",
                "type": "mcq_elimination"
            }
        ]
    }
]

async def generate_audios(scenes_list):
    print("🎙️ Generating Gujarati Audio Narration...")
    os.makedirs("assets/videos", exist_ok=True)
    for sc in scenes_list:
        if not os.path.exists(sc["audio_file"]):
            print(f"  Generating Audio for Scene {sc['id']}...")
            comm = edge_tts.Communicate(sc["text"], "gu-IN-NiranjanNeural", rate="-3%")
            await comm.save(sc["audio_file"])

def create_pil_frame(scene_data, t, width=1280, height=720):
    img = Image.new('RGB', (width, height), color=(18, 22, 30))
    draw = ImageDraw.Draw(img)

    f_header = get_font(30)
    f_title = get_font(26)
    f_body = get_font(20)
    f_large = get_font(34)

    # Top Header Banner
    draw.rectangle([0, 0, width, 70], fill=(35, 25, 15))
    draw.text((25, 16), scene_data["title"], font=f_header, fill=(255, 215, 0))

    stype = scene_data["type"]

    draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
    draw.text((100, 150), scene_data["title"], font=f_large, fill=(255, 215, 0))

    if stype == "mcq_elimination":
        draw.text((100, 240), scene_data["text"][:120], font=f_title, fill=(50, 255, 50))
        draw.text((100, 320), scene_data["text"][120:250], font=f_body, fill=(255, 255, 255))
        draw.text((100, 400), scene_data["text"][250:], font=f_body, fill=(200, 255, 200))
    else:
        draw.text((100, 240), scene_data["text"][:100], font=f_title, fill=(255, 255, 255))
        draw.text((100, 310), scene_data["text"][100:220], font=f_body, fill=(200, 255, 200))
        draw.text((100, 380), scene_data["text"][220:], font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc, audio_path, video_path):
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t2_sub_{sc['id']}.mp4"
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(temp_raw, fourcc, fps, (width, height))

    for f in range(total_frames):
        t = f / fps
        frame = create_pil_frame(sc, t, width, height)
        out.write(frame)

    out.release()

    v_clip = VideoFileClip(temp_raw)
    a_clip = AudioFileClip(audio_path)

    final = v_clip.with_duration(a_clip.duration)
    final.with_audio(a_clip).write_videofile(
        video_path,
        codec="libx264",
        audio_codec="aac",
        fps=15,
        preset="ultrafast"
    )

    v_clip.close()
    a_clip.close()
    final.close()

    if os.path.exists(temp_raw):
        os.remove(temp_raw)

    print(f"  ✅ Scene {sc['id']} Complete!")

def process_topic(top):
    print(f"\n=======================================================")
    print(f"🎬 PROCESSING TOPIC {top['topic_num']}: {top['name']}")
    print(f"=======================================================")

    scenes_list = []
    for sc in top["scenes"]:
        sc_data = sc.copy()
        sc_data["audio_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_s{sc['id']}.mp3"
        sc_data["video_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_v{sc['id']}.mp4"
        scenes_list.append(sc_data)

    asyncio.run(generate_audios(scenes_list))

    for sc in scenes_list:
        render_scene(sc, sc["audio_file"], sc["video_file"])

    out_path = f"assets/videos/{top['filename']}"
    print(f"🎬 Merging Scenes into {out_path}...")
    clips = [VideoFileClip(sc["video_file"]) for sc in scenes_list]

    final_video = concatenate_videoclips(clips)
    final_video.write_videofile(
        out_path,
        codec="libx264",
        audio_codec="aac",
        fps=15,
        preset="ultrafast"
    )

    for c in clips:
        c.close()
    final_video.close()

    for sc in scenes_list:
        if os.path.exists(sc["video_file"]):
            os.remove(sc["video_file"])

    print(f"🎉 SUCCESS! Topic {top['topic_num']} Video Saved: {out_path}")

if __name__ == "__main__":
    for top in FLUID_TOPICS:
        process_topic(top)
