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
        "title": "૧. પાવર પ્લાન્ટ સ્ટોરી – સેકન્ડ લૉ અને થર્મલ રિઝર્વોયર",
        "text": "પાવર પ્લાન્ટના કૂલિંગ ટાવર પાસે ઉભા રહીને જુનિયર એન્જિનિયર આરવે પૂછ્યું: 'સર, બોઇલરમાંથી મળેલી બધી જ ગરમીનું ટર્બાઇનમાં શા માટે વર્કમાં રૂપાંતર નથી થતું? થોડી ગરમી કૂલિંગ ટાવરમાં બહાર કેમ ફેંકવી પડે છે?' સિનિયર મહેતા સાહેબે સમજાવ્યું: 'આરવ, આ જ છે સેકન્ડ લૉ ઓફ થર્મોડાયનેમિક્સ! થર્મલ એનર્જી રિઝર્વોયર બે પ્રકારના હોય છે: ઊંચા તાપમાન T_H વાળો સોર્સ અને નીચા તાપમાન T_L વાળો સિંક. રિઝર્વોયરની હીટ કેપેસિટી અનંત હોય છે, તેથી તેમાં ગરમી આપવા કે લેવાથી તાપમાન બદલાતું નથી.'",
        "audio_file": "assets/videos/t1_4_up_1.mp3",
        "video_file": "assets/videos/t1_4_std_scene_1.mp4",
        "type": "second_law_intro"
    },
    {
        "id": 2,
        "title": "૨. કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટ અને હીટ એન્જિન (Kelvin-Planck Statement)",
        "audio_file": "assets/videos/t1_4_up_2.mp3",
        "video_file": "assets/videos/t1_4_std_scene_2.mp4",
        "text": "મહેતા સાહેબે હીટ એન્જિનનો ડાયાગ્રામ દોરીને કહ્યું: 'કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટ જણાવે છે કે: એક જ થર્મલ રિઝર્વોયરમાંથી ઉષ્મા શોષીને તેનું સંપૂર્ણ ૧૦૦ ટકા કાર્યમાં રૂપાંતર કરે અને ક્યાંય હીટ રિજેક્ટ ન કરે, એવું સાયકલિક હીટ એન્જિન બનાવવું અશક્ય છે! કોઈપણ હીટ એન્જિન ચલાવવા માટે નીચા તાપમાનવાળા સિંકમાં ગરમી કૂલિંગ ટાવર કે કન્ડેન્સર દ્વારા રિજેક્ટ કરવી જ પડે! તેથી હીટ એન્જિનની એફિશિયન્સી ક્યારેય ૧૦૦ ટકા થઈ શકે નહીં.'",
        "type": "kelvin_planck"
    },
    {
        "id": 3,
        "title": "૩. ક્લોઝિયસ સ્ટેટમેન્ટ – રેફ્રિજરેટર અને હીટ પંપ (Clausius Statement)",
        "audio_file": "assets/videos/t1_4_up_3.mp3",
        "video_file": "assets/videos/t1_4_std_scene_3.mp4",
        "text": "આરવે પૂછ્યું: 'સર, તો ઘરનું ફ્રિજ ઠંડી જગ્યામાંથી ગરમી બહાર કેવી રીતે કાઢે છે?' મહેતા સાહેબે કહ્યું: 'તેના માટે ક્લોઝિયસ સ્ટેટમેન્ટ છે! બહારથી કોઈપણ વર્ક ઇનપુટ આપ્યા વગર, આપમેળે નીચા તાપમાનવાળા પદાર્થમાંથી ઊંચા તાપમાનવાળા પદાર્થ તરફ ઉષ્મા વહેવડાવવી અશક્ય છે! રેફ્રિજરેટર અને હીટ પંપને ચલાવવા માટે આપણે બહારથી કમ્પ્રેશર દ્વારા ઇલેક્ટ્રિકલ વર્ક ઇનપુટ W આપવું જ પડે છે.'",
        "type": "clausius"
    },
    {
        "id": 4,
        "title": "૪. પીએમએમ-૨ (Perpetual Motion Machine of Second Kind - PMM-2)",
        "audio_file": "assets/videos/t1_4_up_4.mp3",
        "video_file": "assets/videos/t1_4_std_scene_4.mp4",
        "text": "પીએમએમ-૨ એટલે એવી કાલ્પનિક અશક્ય મશીન જે માત્ર એક જ રિઝર્વોયર સાથે જોડાયેલી હોય અને ૧૦૦ ટકા એફિશિયન્સીથી કામ કરે! એટલે કે કોઈપણ ગરમી બહાર ફેંક્યા વગર બધી જ ઉષ્માનું નેટ વર્કમાં રૂપાંતર કરે. આવું મશીન કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટનો ભંગ કરે છે અને તેને બનાવવું સંપૂર્ણ અશક્ય છે!",
        "type": "pmm2_concept"
    },
    {
        "id": 5,
        "title": "૫. રેફ્રિજરેટર વિ. હીટ પંપ COP સંબંધ (COP_HP = COP_ref + 1)",
        "audio_file": "assets/videos/t1_4_up_5.mp3",
        "video_file": "assets/videos/t1_4_std_scene_5.mp4",
        "text": "રેફ્રિજરેટરની સીઓપી એટલે ડિઝાયર્ડ કૂલિંગ ઇફેક્ટ Q_L ભાગ્યા વર્ક ઇનપુટ W. જ્યારે હીટ પંપની સીઓપી એટલે હીટિંગ ઇફેક્ટ Q_H ભાગ્યા વર્ક ઇનપુટ W. પરીક્ષાનું ગોલ્ડન સૂત્ર: સમાન તાપમાન મર્યાદા વચ્ચે હીટ પંપની સીઓપી એ રેફ્રિજરેટરની સીઓપી કરતાં હંમેશા એક જેટલી વધુ હોય છે! એટલે કે COP ઓફ Heat Pump બરાબર COP ઓફ Refrigerator વત્તા ૧!",
        "type": "cop_relation"
    },
    {
        "id": 6,
        "title": "૬. પરીક્ષામાં થતી ગૂંચવણો અને એક્ઝામ ટ્રેપ્સ (Exam Traps)",
        "audio_file": "assets/videos/t1_4_up_6.mp3",
        "video_file": "assets/videos/t1_4_std_scene_6.mp4",
        "text": "પરીક્ષામાં માર્ક્સ અપાવતા ૩ મુખ્ય ગોલ્ડન ટ્રેપ્સ: ૧. કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટ એ હીટ એન્જિનને લાગુ પડે છે, જ્યારે ક્લોઝિયસ સ્ટેટમેન્ટ એ રેફ્રિજરેટર અને હીટ પંપને લાગુ પડે છે. ૨. જો કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટનો ભંગ થાય તો ક્લોઝિયસ સ્ટેટમેન્ટનો પણ ભંગ થાય જ છે, એટલે કે બંને સ્ટેટમેન્ટ સમકક્ષ Equivalence છે! ૩. હીટ પંપની સીઓપી કાયમ ૧ કરતાં વધુ હોય છે, COP_HP > 1!",
        "type": "exam_traps"
    },
    {
        "id": 7,
        "title": "૭. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_4_up_7.mp3",
        "video_file": "assets/videos/t1_4_std_scene_7.mp4",
        "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટ કયા મશીનને લાગુ પડે છે? સાચો જવાબ: Heat Engine! પ્રશ્ન ૨: ૧૦૦ ટકા એફિશિયન્સીવાળી PMM-2 મશીન કયા નિયમનો ભંગ કરે છે? સાચો જવાબ: Second Law of Thermodynamics! અને પ્રશ્ન ૩: સમાન કન્ડીશનમાં Heat Pump અને Refrigerator ની COP વચ્ચેનો સાચો સંબંધ કયો છે? સાચો જવાબ: COP_HP = COP_ref + 1!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/kelvin_planck_and_clausius.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.4 Upgrade Gujarati Audio Narration...")
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

    if stype == "second_law_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "SECOND LAW OF THERMODYNAMICS & RESERVOIRS", font=f_large, fill=(255, 215, 0))

        draw.rectangle([200, 210, 1080, 320], fill=(120, 40, 40), outline=(255, 215, 0), width=3)
        draw.text((230, 245), "🔥 SOURCE (સોર્સ) - High Temperature Reservoir (T_H)", font=f_title, fill=(255, 255, 255))

        draw.rectangle([200, 460, 1080, 570], fill=(30, 70, 120), outline=(0, 255, 255), width=3)
        draw.text((230, 495), "❄️ SINK (સિંક) - Low Temperature Reservoir (T_L)", font=f_title, fill=(255, 255, 255))

        draw.text((100, 600), "• Infinite Heat Capacity: ગરમી લેવા કે આપવાથી તાપમાન બદલાતું નથી.", font=f_body, fill=(200, 255, 200))

    elif stype == "kelvin_planck":
        draw.rectangle([80, 120, 1200, 650], fill=(22, 32, 50), outline=(255, 215, 0), width=3)
        draw.text((120, 150), "KELVIN-PLANCK STATEMENT (HEAT ENGINES)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 220, 1160, 400], fill=(35, 25, 75), outline=(0, 255, 255), width=2)
        draw.text((150, 250), "• એક જ થર્મલ રિઝર્વોયરમાંથી Q ઇનપુટ લઈને ૧૦૦% W માં રૂપાંતર કરવું અશક્ય!", font=f_title, fill=(255, 255, 255))
        draw.text((150, 310), "• Thermal Efficiency eta < 100%   ===>   Q_reject > 0 જરૂરી છે!", font=f_large, fill=(50, 255, 50))

        draw.text((120, 460), "• Heat Engine હંમેશા ૨ રિઝર્વોયર (Source T_H & Sink T_L) વચ્ચે કામ કરે છે.", font=f_body, fill=(200, 255, 200))
        draw.text((120, 520), "• eta = W / Q_in = (Q_H - Q_L) / Q_H = 1 - (Q_L / Q_H)", font=f_body, fill=(255, 215, 0))

    elif stype == "clausius":
        draw.text((50, 85), "CLAUSIUS STATEMENT (REFRIGERATOR & HEAT PUMP)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 630], fill=(20, 30, 45), outline=(0, 255, 255), width=3)
        draw.text((150, 180), "• બહારથી Work Input (W_in) આપ્યા વગર,", font=f_title, fill=(255, 255, 255))
        draw.text((150, 230), "  નીચા તાપમાન T_L થી ઊંચા તાપમાન T_H તરફ ગરમી વહાવવી અશક્ય છે!", font=f_title, fill=(255, 100, 100))

        draw.rectangle([150, 310, 1130, 580], fill=(30, 50, 75), outline=(255, 215, 0), width=2)
        draw.text((180, 340), "❄️ Refrigerator: ઠંડી જગ્યામાંથી ગરમી બહાર કાઢી તાપમાન T_L જાળવી રાખે છે.", font=f_body, fill=(255, 255, 255))
        draw.text((180, 400), "🔥 Heat Pump: ગરમ જગ્યામાં બહારથી ગરમી ઉમેરી તાપમાન T_H જાળવી રાખે છે.", font=f_body, fill=(255, 255, 255))
        draw.text((180, 460), "• બંને માટે કમ્પ્રેશર વર્ક ઇનપુટ W_in > 0 જરૂરી છે!", font=f_title, fill=(50, 255, 50))

    elif stype == "pmm2_concept":
        draw.text((50, 85), "PERPETUAL MOTION MACHINE OF SECOND KIND (PMM-2)", font=f_large, fill=(255, 100, 100))

        draw.rectangle([120, 140, 1160, 640], fill=(45, 18, 18), outline=(255, 80, 80), width=3)
        draw.text((150, 180), "❌ IMPOSSIBLE MACHINE (૧૦૦% એફિશિયન્ટ મશીન અશક્ય)", font=f_large, fill=(255, 80, 80))

        draw.text((150, 270), "• માત્ર એક જ રિઝર્વોયર સાથે જોડાયેલી રહે અને eta = 100% થી કામ કરે!", font=f_title, fill=(255, 255, 255))
        draw.text((150, 340), "• કોઈ જ હીટ રિજેક્ટ કર્યા વગર બધી ઉષ્માનું કાર્યમાં રૂપાંતર કરે!", font=f_title, fill=(255, 255, 255))

        draw.text((150, 450), "🔥 EXAM TRAP: PMM-2 થર્મોડાયનેમિક્સના Kelvin-Planck / Second Law નો ભંગ કરે છે!", font=f_large, fill=(255, 215, 0))

    elif stype == "cop_relation":
        draw.text((50, 85), "REFRIGERATOR & HEAT PUMP COP RELATIONSHIP", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 300], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 180), "• COP_ref = Q_L / W_in = T_L / (T_H - T_L)", font=f_title, fill=(255, 255, 255))
        draw.text((150, 230), "• COP_HP  = Q_H / W_in = T_H / (T_H - T_L)", font=f_title, fill=(255, 255, 255))

        # GOLDEN COP FORMULA CARD
        draw.rectangle([120, 340, 1160, 620], fill=(20, 50, 30), outline=(50, 255, 50), width=4)
        draw.text((150, 380), "🔥 TOP GSSSB EXAM FORMULA:", font=f_title, fill=(255, 215, 0))
        draw.text((150, 450), "COP_HP = COP_ref + 1", font=f_large, fill=(50, 255, 50))
        draw.text((150, 520), "• સમાન તાપમાન મર્યાદામાં Heat Pump ની COP હંમેશા Refrigerator કરતાં 1 વધુ હોય!", font=f_body, fill=(255, 255, 255))

    elif stype == "exam_traps":
        draw.rectangle([60, 110, 1200, 660], fill=(22, 32, 50), outline=(255, 100, 100), width=3)
        draw.text((180, 140), "GSSSB EXAM TRAPS & CONFUSIONS", font=f_large, fill=(255, 215, 0))

        draw.text((90, 210), "૧. Kelvin-Planck Statement = Heat Engines ને લાગુ પડે છે", font=f_body, fill=(255, 255, 255))
        draw.text((90, 270), "૨. Clausius Statement = Refrigerator & Heat Pump ને લાગુ પડે છે", font=f_body, fill=(255, 255, 0))
        draw.text((90, 330), "૩. Equivalence: Kelvin-Planck ભંગ થાય તો Clausius નો ભંગ થાય જ છે!", font=f_body, fill=(0, 255, 255))
        draw.text((90, 390), "૪. Heat Pump COP કાયમ ૧ કરતાં વધુ (COP_HP > 1) હોય છે!", font=f_body, fill=(50, 255, 50))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: કેલ્વિન-પ્લાન્ક સ્ટેટમેન્ટ કયા મશીનને લાગુ પડે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: Heat Engine (હીટ એન્જિન)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: ૧૦૦% એફિશિયન્સીવાળી PMM-2 મશીન કયા નિયમનો ભંગ કરે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: Second Law of Thermodynamics!", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: સમાન કન્ડીશનમાં Heat Pump અને Refrigerator ની COP વચ્ચેનો સંબંધ?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. COP_HP = COP_ref - 1", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. COP_HP = COP_ref + 1   (સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.4 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_4_s{sc['id']}.mp4"
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
    print("🎬 Merging all 7 Scenes for Topic 1.4 into Final Master Asset...")
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

    print(f"🎉 SUCCESS! Topic 1.4 Upgraded Master Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
