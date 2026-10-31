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
        "title": "૧. કાર્નોટ સાયકલ અને રિવર્સિબલ હીટ એન્જિન (Carnot Cycle)",
        "text": "કાર્નોટ સાયકલ એ આદર્શ રિવર્સિબલ સાયકલ છે જેમાં બે આઇસોથર્મલ અને બે આઇસેન્ટ્રોપિક પ્રોસેસ હોય છે. કાર્નોટ એન્જિનની એફિશિયન્સીનું સૂત્ર ઈટા બરાબર ૧ માઇનસ ટી એલ ભાગ્યા ટી એચ થાય છે. જ્યાં ટી એચ અને ટી એલ તાપમાન કાયમ કેલ્વિન એબ્સોલ્યુટ સ્કેલમાં હોવા જોઈએ!",
        "audio_file": "assets/videos/t1_8_scene_1.mp3",
        "video_file": "assets/videos/t1_8_std_scene_1.mp4",
        "type": "carnot_intro"
    },
    {
        "id": 2,
        "title": "૨. કાર્નોટ થિયરમ (Carnot Theorem)",
        "audio_file": "assets/videos/t1_8_scene_2.mp3",
        "video_file": "assets/videos/t1_8_std_scene_2.mp4",
        "text": "કાર્નોટ થિયરમ જણાવે છે કે: બે સમાન તાપમાન મર્યાદા ટી એચ અને ટી એલ વચ્ચે કામ કરતા કોઈપણ રિવર્સિબલ એન્જિનની એફિશિયન્સી કાયમ સરખી જ હોય છે! તે વર્કિંગ ફ્લુઇડ પર આધાર રાખતી નથી. અને કોઈપણ ઇરરિવર્સિબલ એન્જિનની એફિશિયન્સી કાર્નોટ એન્જિન કરતાં ક્યારેય વધુ હોઈ શકે નહીં!",
        "type": "carnot_theorem"
    },
    {
        "id": 3,
        "title": "૩. સીઓપી અને રેફ્રિજરેશન ગણતરીઓ (COP Calculations)",
        "audio_file": "assets/videos/t1_8_scene_3.mp3",
        "video_file": "assets/videos/t1_8_std_scene_3.mp4",
        "text": "કાર્નોટ રેફ્રિજરેટરની સીઓપી બરાબર ટી એલ ભાગ્યા ટી એચ માઇનસ ટી એલ. જ્યારે કાર્નોટ હીટ પંપની સીઓપી બરાબર ટી એચ ભાગ્યા ટી એચ માઇનસ ટી એલ. પરીક્ષાનું સુવર્ણ સૂત્ર: સીઓપી હીટ પંપ બરાબર સીઓપી રેફ્રિજરેટર વત્તા ૧!",
        "type": "cop_formulas"
    },
    {
        "id": 4,
        "title": "૪. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_8_scene_4.mp3",
        "video_file": "assets/videos/t1_8_std_scene_4.mp4",
        "text": "ચાલો હવે પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: સમાન તાપમાન લિમિટ વચ્ચે કામ કરતા રિવર્સિબલ એન્જિનની એફિશિયન્સી કોના પર આધાર રાખે છે? સાચો જવાબ: માત્ર ટેમ્પરેચર લિમિટ્સ TH અને TL પર! પ્રશ્ન ૨: કાર્નોટ એન્જિનની એફિશિયન્સીનું સૂત્ર કયું છે? સાચો જવાબ: eta = 1 - (TL / TH)! અને પ્રશ્ન ૩: COP of Heat Pump અને COP of Refrigerator વચ્ચેનો સંબંધ? સાચો જવાબ: COP_HP = COP_ref + 1!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/second_law_heat_engines_cop.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.8 Gujarati Audio Narration...")
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

    if stype == "carnot_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "CARNOT CYCLE & REVERSIBLE ENGINE EFFICIENCY", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 210, 1140, 350], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 240), "eta_Carnot = 1 - (T_L / T_H) = (T_H - T_L) / T_H", font=f_large, fill=(50, 255, 50))
        draw.text((150, 295), "⚠️ CRITICAL EXAM TRAP: Temperatures T_H and T_L MUST be in Kelvin (K)!", font=f_title, fill=(255, 100, 100))

        draw.text((120, 400), "• Carnot Cycle = 2 Reversible Isothermal + 2 Reversible Isentropic Processes", font=f_body, fill=(200, 255, 200))
        draw.text((120, 460), "• Maximum Possible Efficiency for any Heat Engine operating between T_H & T_L.", font=f_body, fill=(255, 255, 255))

    elif stype == "carnot_theorem":
        draw.text((50, 85), "CARNOT THEOREM & PRINCIPLES", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 630], fill=(20, 30, 45), outline=(0, 255, 255), width=3)
        draw.text((150, 180), "૧. Reversible Engine Efficiency is INDEPENDENT of Working Fluid!", font=f_title, fill=(50, 255, 50))
        draw.text((150, 240), "   માત્ર અને માત્ર ગરમ T_H અને ઠંડા T_L રિઝર્વોયરના તાપમાન પર જ આધાર રાખે છે.", font=f_body, fill=(255, 255, 255))

        draw.text((150, 320), "૨. સમાન T_H અને T_L વચ્ચે કામ કરતી તમામ Reversible Engines ની એફિશિયન્સી સરખી હોય!", font=f_title, fill=(0, 255, 255))

        draw.text((150, 420), "૩. નોન-રિવર્સિબલ (Irreversible) એન્જિનની એફિશિયન્સી કાર્નોટ કરતાં ક્યારેય વધુ ન હોઈ શકે:", font=f_title, fill=(200, 255, 200))
        draw.text((150, 480), "   eta_irrev < eta_Carnot", font=f_large, fill=(255, 215, 0))

    elif stype == "cop_formulas":
        draw.text((50, 85), "COP OF CARNOT REFRIGERATOR & HEAT PUMP", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 320], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 175), "• COP_ref = T_L / (T_H - T_L)  [Refrigerator]", font=f_title, fill=(255, 255, 255))
        draw.text((150, 235), "• COP_HP  = T_H / (T_H - T_L)  [Heat Pump]", font=f_title, fill=(255, 255, 255))

        draw.rectangle([120, 350, 1160, 620], fill=(20, 50, 30), outline=(50, 255, 50), width=4)
        draw.text((150, 390), "🔥 GOLDEN COP RELATIONSHIP:", font=f_title, fill=(255, 215, 0))
        draw.text((150, 460), "COP_HP = COP_ref + 1", font=f_large, fill=(50, 255, 50))
        draw.text((150, 530), "• Heat Pump ની COP કાયમ 1 કરતાં વધુ (COP_HP > 1) હોય છે!", font=f_body, fill=(255, 255, 255))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: Reversible Engine ની એફિશિયન્સી કોના પર આધાર રાખે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: માત્ર Temperature Limits TH અને TL પર!", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: Carnot Engine ની એફિશિયન્સીનું સાચું સૂત્ર કયું છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: eta = 1 - (TL / TH)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: COP of Heat Pump અને COP of Refrigerator વચ્ચેનો સાચો સંબંધ કયો છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. COP_HP = COP_ref - 1", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. COP_HP = COP_ref + 1   (સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.8 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_8_s{sc['id']}.mp4"
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
    print("🎬 Merging all 4 Scenes for Topic 1.8 into Final Asset...")
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

    print(f"🎉 SUCCESS! Topic 1.8 Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
