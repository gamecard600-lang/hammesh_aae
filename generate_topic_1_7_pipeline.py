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

SCENES = [
    {
        "id": 1,
        "title": "૧. પ્યોર સબ્સ્ટન્સ વ્યાખ્યા (Pure Substance Concept)",
        "text": "પ્યોર સબ્સ્ટન્સ એટલે એવો પદાર્થ જેનું રાસાયણિક બંધારણ કેમિકલ કમ્પોઝિશન આખા વિસ્તારમાં એકસમાન અને નિશ્ચિત હોય! પદાર્થ ભલે ઘન, પ્રવાહી કે વાયુ સ્વરૂપમાં બદલાય, પણ રાસાયણિક બંધારણ બદલાતું નથી. શુદ્ધ પાણી, નાઇટ્રોજન, અને પ્રવાહી-ગેસ ફેઝમાં રહેલી હવા એ પ્યોર સબ્સ્ટન્સના ઉદાહરણો છે.",
        "audio_file": "assets/videos/t1_7_scene_1.mp3",
        "video_file": "assets/videos/t1_7_std_scene_1.mp4",
        "type": "pure_substance"
    },
    {
        "id": 2,
        "title": "૨. આદર્શ વાયુના નિયમો (Ideal Gas Laws & PV = mRT)",
        "audio_file": "assets/videos/t1_7_scene_2.mp3",
        "video_file": "assets/videos/t1_7_std_scene_2.mp4",
        "text": "આદર્શ વાયુ આદર્શ ગેસ ઇક્વેશન પી વી બરાબર એમ આર ટી નું પાલન કરે છે. બોયલ્સના નિયમ મુજબ અચળ તાપમાને દબાણ એ કદના વ્યસ્ત પ્રમાણમાં હોય છે. ચાર્લ્સના નિયમ મુજબ અચળ દબાણે કદ એ તાપમાનના સમપ્રમાણમાં હોય છે. અને ગેલ્યુસેકના નિયમ મુજબ અચળ કદે દબાણ એ તાપમાનના સમપ્રમાણમાં હોય છે.",
        "type": "gas_laws"
    },
    {
        "id": 3,
        "title": "૩. કેરેક્ટરિસ્ટિક ગેસ કોન્સ્ટન્ટ અને સ્પેસિફિક હીટ સંબંધ (cp - cv = R)",
        "audio_file": "assets/videos/t1_7_scene_3.mp3",
        "video_file": "assets/videos/t1_7_std_scene_3.mp4",
        "text": "ગેસ કોન્સ્ટન્ટ આર બરાબર યુનિવર્સલ ગેસ કોન્સ્ટન્ટ આર યુ ભાગ્યા મોલેક્યુલર વેટ એમ થાય છે. હવા માટે આર ની કિંમત ૦.૨૮૭ કિલોજૂલ પ્રતિ કિલોગ્રામ કેલ્વિન છે. સ્પેસિફિક હીટ સંબંધ: સી પી માઇનસ સી વી બરાબર આર થાય છે. અને ગેમા બરાબર સી પી ભાગ્યા સી વી થાય છે. હવા માટે ગેમા ની કિંમત ૧.૪ હોય છે.",
        "type": "gas_constant"
    },
    {
        "id": 4,
        "title": "૪. કોમ્પ્રેસિબિલીટી ફેક્ટર (Compressibility Factor Z)",
        "audio_file": "assets/videos/t1_7_scene_4.mp3",
        "video_file": "assets/videos/t1_7_std_scene_4.mp4",
        "text": "કોમ્પ્રેસિબિલીટી ફેક્ટર ઝેડ એ વાસ્તવિક ગેસનું આદર્શ વાયુ વર્તણૂકથી વિચલન દર્શાવે છે. તેનું સૂત્ર ઝેડ બરાબર પી વી ભાગ્યા આર ટી છે. આદર્શ વાયુ આઇડિયલ ગેસ માટે કોમ્પ્રેસિબિલીટી ફેક્ટર ઝેડ ની કિંમત કાયમ ૧ હોય છે!",
        "type": "compressibility"
    },
    {
        "id": 5,
        "title": "૫. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_7_scene_5.mp3",
        "video_file": "assets/videos/t1_7_std_scene_5.mp4",
        "text": "ચાલો હવે પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: હવા માટે કેરેક્ટરિસ્ટિક ગેસ કોન્સ્ટન્ટ R ની કિંમત કેટલી હોય છે? સાચો જવાબ: 0.287 kJ/kg K! પ્રશ્ન ૨: સ્પેસિફિક હીટ વચ્ચેનો સાચો સંબંધ કયો છે? સાચો જવાબ: cp - cv = R! અને પ્રશ્ન ૩: Ideal Gas માટે Compressibility Factor Z ની કિંમત કેટલી હોય છે? સાચો જવાબ: Z = 1!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/pure_substances_and_gases.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.7 Gujarati Audio Narration...")
    os.makedirs("assets/videos", exist_ok=True)
    for sc in SCENES:
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

    if stype == "pure_substance":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "PURE SUBSTANCE (પ્યોર સબ્સ્ટન્સની વ્યાખ્યા)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 210, 1140, 350], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 240), "• Fixed & Uniform Chemical Composition Throughout", font=f_title, fill=(50, 255, 50))
        draw.text((150, 295), "• પદાર્થની અવસ્થા (Solid, Liquid, Gas) બદલાય છતાં બંધારણ એકસમાન રહે છે.", font=f_title, fill=(255, 255, 255))

        draw.text((120, 400), "• Examples: Pure Water (H2O), Pure Nitrogen (N2)", font=f_body, fill=(200, 255, 200))
        draw.text((120, 460), "• Liquid-Gas Air Mixture (પ્રવાહી-ગેસ ફેઝમાં રહેલી શુદ્ધ હવા)", font=f_body, fill=(200, 255, 200))

    elif stype == "gas_laws":
        draw.text((50, 85), "IDEAL GAS LAWS & CHARACTERISTIC GAS EQUATION", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 280], fill=(35, 25, 75), outline=(0, 255, 255), width=3)
        draw.text((360, 175), "P * V = m * R * T  (or P * v = R * T)", font=f_large, fill=(255, 255, 255))

        draw.rectangle([120, 310, 1160, 630], fill=(20, 30, 45), outline=(255, 215, 0), width=2)
        draw.text((150, 340), "૧. Boyle's Law:      P proportional to 1/V  (at T = Constant)", font=f_body, fill=(255, 255, 255))
        draw.text((150, 400), "૨. Charles' Law:    V proportional to T    (at P = Constant)", font=f_body, fill=(255, 255, 255))
        draw.text((150, 460), "૩. Gay-Lussac Law:  P proportional to T    (at V = Constant)", font=f_body, fill=(255, 255, 255))
        draw.text((150, 520), "• Avogadro's Law:   V proportional to n    (at P & T Constant)", font=f_body, fill=(200, 255, 200))

    elif stype == "gas_constant":
        draw.text((50, 85), "GAS CONSTANTS & SPECIFIC HEAT RELATIONSHIPS", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 320], fill=(25, 45, 65), outline=(255, 215, 0), width=3)
        draw.text((150, 175), "• Characteristic Gas Constant: R = R_u / M", font=f_title, fill=(255, 255, 255))
        draw.text((150, 235), "🔥 For Air: R = 0.287 kJ/kg K  (R_u = 8.314 kJ/kmol K)", font=f_title, fill=(50, 255, 50))

        draw.rectangle([120, 350, 1160, 630], fill=(20, 35, 55), outline=(0, 255, 255), width=2)
        draw.text((150, 390), "• Mayer's Relation:   cp - cv = R", font=f_title, fill=(255, 215, 0))
        draw.text((150, 450), "• Adiabatic Index:    gamma = cp / cv   (For Air: gamma = 1.4)", font=f_title, fill=(200, 255, 200))
        draw.text((150, 510), "• Air Values: cp = 1.005 kJ/kg K,  cv = 0.718 kJ/kg K", font=f_body, fill=(255, 255, 255))

    elif stype == "compressibility":
        draw.text((50, 85), "COMPRESSIBILITY FACTOR Z (DEVIATION FROM IDEAL GAS)", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 320], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((280, 180), "Z = P * V / (m * R * T) = v_actual / v_ideal", font=f_large, fill=(255, 255, 255))

        draw.rectangle([120, 350, 1160, 630], fill=(20, 50, 30), outline=(50, 255, 50), width=4)
        draw.text((150, 390), "🔥 TOP GSSSB EXAM CONCEPT:", font=f_title, fill=(255, 215, 0))
        draw.text((150, 460), "• Ideal Gas (આદર્શ વાયુ) માટે Compressibility Factor Z = 1!", font=f_large, fill=(50, 255, 50))
        draw.text((150, 530), "• Real Gas (વાસ્તવિક વાયુ) માટે Z નો ક્રિટિકલ પોઈન્ટ પર અંદાજીત કિંમત 0.27 હોય છે.", font=f_body, fill=(255, 255, 255))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: હવા માટે કેરેક્ટરિસ્ટિક ગેસ કોન્સ્ટન્ટ R ની કિંમત કેટલી હોય છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: R = 0.287 kJ/kg K (અને R_u = 8.314 kJ/kmol K)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: સ્પેસિફિક હીટ cp, cv અને R વચ્ચેનો સાચો સંબંધ કયો છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: cp - cv = R", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: Ideal Gas માટે Compressibility Factor Z ની કિંમત કેટલી હોય છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. Z = 0", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. Z = 1   (સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.7 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_7_s{sc['id']}.mp4"
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

def merge_all_scenes():
    print("🎬 Merging all 5 Scenes for Topic 1.7 into Final Asset...")
    clips = []
    for sc in SCENES:
        clips.append(VideoFileClip(sc["video_file"]))

    final_video = concatenate_videoclips(clips)
    final_video.write_videofile(
        OUTPUT_VIDEO_PATH,
        codec="libx264",
        audio_codec="aac",
        fps=15,
        preset="ultrafast"
    )

    for c in clips:
        c.close()
    final_video.close()

    for sc in SCENES:
        if os.path.exists(sc["video_file"]):
            os.remove(sc["video_file"])

    print(f"🎉 SUCCESS! Topic 1.7 Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
