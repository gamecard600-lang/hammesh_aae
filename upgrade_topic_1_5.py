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
        "title": "૧. પાવર પ્લાન્ટ સ્ટોરી – એન્ટ્રોપીનો ખ્યાલ (Concept of Entropy)",
        "text": "પાવર પ્લાન્ટમાં ટર્બાઇનમાં સ્ટીમ વિસ્તરણ પામતી જોઈને જુનિયર આરવે પૂછ્યું: 'સર, વરાળ જ્યારે કાર્ય આપે છે ત્યારે અંદર શું ફેરફાર થાય છે?' સિનિયર મહેતા સાહેબે સમજાવ્યું: 'આરવ, એન્ટ્રોપી એ સિસ્ટમની આણ્વિક અસ્તવ્યસ્તતા એટલે કે Molecular Disorder નું માપન છે! ઘન બરફ સોલિડમાં અણુઓ લાઇનસર ગોઠવાયેલા હોવાથી એન્ટ્રોપી સૌથી ઓછી હોય છે, પાણી પ્રવાહીમાં થોડી વધુ, અને વરાળ ગેસમાં અણુઓ ચારેય તરફ રખડતા હોવાથી એન્ટ્રોપી સૌથી વધુ હોય છે! એન્ટ્રોપી dS = (dQ / T) rev થાય છે.'",
        "audio_file": "assets/videos/t1_5_up_1.mp3",
        "video_file": "assets/videos/t1_5_std_scene_1.mp4",
        "type": "entropy_intro"
    },
    {
        "id": 2,
        "title": "૨. ક્લોઝિયસ ઇનિક્વાલિટી (Clausius Inequality)",
        "audio_file": "assets/videos/t1_5_up_2.mp3",
        "video_file": "assets/videos/t1_5_std_scene_2.mp4",
        "text": "ક્લોઝિયસ ઇનિક્વાલિટી એ કોઈપણ થર્મોડાયનેમિક સાયકલ માટે લાઇન ઇન્ટિગ્રલ dQ / T ની કિંમત દર્શાવે છે: ૧. જો સાયકલિક ઇન્ટિગ્રલ dQ / T = 0 થાય, તો સાયકલ Reversible છે. ૨. જો ઇન્ટિગ્રલ less than 0 એટલે કે નેગેટિવ થાય, તો સાયકલ Irreversible એટલે કે વાસ્તવિક છે. અને ૩. જો ઇન્ટિગ્રલ greater than 0 થાય, તો આવી સાયકલ બનાવવી સંપૂર્ણ અશક્ય છે!",
        "type": "clausius_inequality"
    },
    {
        "id": 3,
        "title": "૩. પ્રિન્સિપલ ઓફ એન્ટ્રોપી ઇન્ક્રીઝ (Increase of Entropy Principle)",
        "audio_file": "assets/videos/t1_5_up_3.mp3",
        "video_file": "assets/videos/t1_5_std_scene_3.mp4",
        "text": "બ્રહ્માંડ માટે પ્રિન્સિપલ ઓફ એન્ટ્રોપી ઇન્ક્રીઝ જણાવે છે કે: આપણા સમગ્ર યુનિવર્સની કુલ એન્ટ્રોપી delta_S_univ હંમેશા વધે છે અથવા અચળ રહે છે! રિવર્સિબલ પ્રોસેસમાં યુનિવર્સની એન્ટ્રોપી અચળ રહે છે, જ્યારે તમામ કુદરતી અને વાસ્તવિક ઇરરિવર્સિબલ પ્રોસેસમાં યુનિવર્સની એન્ટ્રોપી સતત વધતી રહે છે! બ્રહ્માંડની એન્ટ્રોપી ક્યારેય ઘટી શકતી નથી.",
        "type": "entropy_increase"
    },
    {
        "id": 4,
        "title": "૪. આઇસેન્ટ્રોપિક પ્રોસેસ (Isentropic Process - dS = 0)",
        "audio_file": "assets/videos/t1_5_up_4.mp3",
        "video_file": "assets/videos/t1_5_std_scene_4.mp4",
        "text": "આઇસેન્ટ્રોપિક પ્રોસેસ એટલે એવી પ્રોસેસ જેમાં એન્ટ્રોપી અચળ રહે છે. એટલે કે dS = 0! રિવર્સિબલ એડિયાબેટિક પ્રોસેસમાં હીટ ટ્રાન્સફર Q = 0 અને ફ્રિક્સન 0 હોવાથી તે હંમેશા આઇસેન્ટ્રોપિક હોય છે. પરંતુ યાદ રાખજો: દરેક આઇસેન્ટ્રોપિક પ્રોસેસ રિવર્સિબલ એડિયાબેટિક હોવી જરૂરી નથી!",
        "type": "isentropic"
    },
    {
        "id": 5,
        "title": "૫. ટેમ્પરેચર-એન્ટ્રોપી ડાયાગ્રામ (T-s Diagram & Heat Transfer)",
        "audio_file": "assets/videos/t1_5_up_5.mp3",
        "video_file": "assets/videos/t1_5_std_scene_5.mp4",
        "text": "T-s ડાયાગ્રામ પર રિવર્સિબલ પ્રોસેસ હેઠળનો એરિયા હીટ ટ્રાન્સફર Q દર્શાવે છે! Q = Integral T * ds. તાપમાન અચળ હોય તેવી આઇસોથર્મલ પ્રોસેસ T-s ડાયાગ્રામ પર આડી લાઇન દર્શાવે છે, જ્યારે એન્ટ્રોપી અચળ હોય તેવી આઇસેન્ટ્રોપિક પ્રોસેસ T-s ડાયાગ્રામ પર ઊભી લાઇન દર્શાવે છે!",
        "type": "ts_diagram"
    },
    {
        "id": 6,
        "title": "૬. પરીક્ષાની કિલર ગોલ્ડન ટ્રેપ્સ (Exam Traps)",
        "audio_file": "assets/videos/t1_5_up_6.mp3",
        "video_file": "assets/videos/t1_5_std_scene_6.mp4",
        "text": "પરીક્ષા માટે ૩ કિલર ગોલ્ડન ટ્રેપ્સ: ૧. એન્ટ્રોપી એ પોઇન્ટ ફંક્શન અને પ્રોપર્ટી છે. ૨. સિસ્ટમની એન્ટ્રોપી ઘટી શકે છે (જો ગરમી બહાર કાઢવામાં આવે), પરંતુ યુનિવર્સની કુલ એન્ટ્રોપી ક્યારેય ઘટી શકતી નથી! ૩. થ્રોટલિંગ પ્રોસેસમાં એન્ટ્રોપી વધે છે કારણ કે તે ઇરરિવર્સિબલ પ્રોસેસ છે.",
        "type": "exam_traps"
    },
    {
        "id": 7,
        "title": "૭. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_5_up_7.mp3",
        "video_file": "assets/videos/t1_5_std_scene_7.mp4",
        "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: સાયકલિક ઇન્ટિગ્રલ dQ / T < 0 હોય તો સાયકલ કેવી કહેવાય? સાચો જવાબ: Irreversible Cycle! પ્રશ્ન ૨: Reversible Adiabatic પ્રોસેસમાં કઈ પ્રોપર્ટી અચળ રહે છે? સાચો જવાબ: Entropy! અને પ્રશ્ન ૩: વાસ્તવિક પ્રક્રિયાઓમાં Universe ની Entropy માં શો ફેરફાર થાય છે? સાચો જવાબ: હંમેશા વધે છે (Always Increases)!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/entropy_and_clausius_inequality.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.5 Upgrade Gujarati Audio Narration...")
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

    if stype == "entropy_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "CONCEPT OF ENTROPY (S) - MOLECULAR DISORDER", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 210, 1140, 350], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 240), "dS = (delta_Q / T)_rev    [SI Unit: kJ/K]", font=f_large, fill=(50, 255, 50))
        draw.text((150, 295), "Entropy = Measure of Molecular Randomness / Disorder", font=f_title, fill=(255, 255, 255))

        draw.text((120, 400), "• Solid (ઘન) ---> Entropy S શૂન્યની નજીક (અણુઓ ગોઠવાયેલા)", font=f_body, fill=(200, 255, 200))
        draw.text((120, 460), "• Liquid (પ્રવાહી) ---> Entropy મધ્યમ", font=f_body, fill=(200, 255, 200))
        draw.text((120, 520), "• Gas (વાયુ) ---> Entropy S સૌથી વધુ! (અણુઓ મુક્ત ગતિ કરે)", font=f_body, fill=(255, 215, 0))

    elif stype == "clausius_inequality":
        draw.rectangle([80, 120, 1200, 650], fill=(22, 32, 50), outline=(255, 215, 0), width=3)
        draw.text((120, 150), "CLAUSIUS INEQUALITY (oint delta_Q / T <= 0)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 220, 1160, 580], fill=(25, 45, 65), outline=(0, 255, 255), width=2)
        draw.text((150, 250), "૧. oint (delta_Q / T) = 0   ===>  Reversible Cycle (સાચો સાયકલ)", font=f_title, fill=(50, 255, 50))
        draw.text((150, 330), "૨. oint (delta_Q / T) < 0   ===>  Irreversible Cycle (વાસ્તવિક સાયકલ)", font=f_title, fill=(0, 255, 255))
        draw.text((150, 410), "૩. oint (delta_Q / T) > 0   ===>  Impossible Cycle! (અશક્ય સાયકલ)", font=f_title, fill=(255, 100, 100))

    elif stype == "entropy_increase":
        draw.text((50, 85), "PRINCIPLE OF INCREASE OF ENTROPY (delta_S_univ >= 0)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 300], fill=(35, 25, 75), outline=(0, 255, 255), width=3)
        draw.text((180, 180), "delta_S_univ = delta_S_system + delta_S_surroundings >= 0", font=f_title, fill=(255, 255, 255))
        draw.text((180, 240), "• બ્રહ્માંડની એન્ટ્રોપી ક્યારેય ઘટી શકતી નથી! (Entropy Never Decreases)", font=f_title, fill=(50, 255, 50))

        draw.rectangle([120, 330, 1160, 630], fill=(20, 30, 45), outline=(255, 215, 0), width=2)
        draw.text((150, 370), "• Reversible Process:     delta_S_univ = 0  (અચળ)", font=f_title, fill=(200, 255, 200))
        draw.text((150, 440), "• Irreversible Process:   delta_S_univ > 0  (વધે છે!)", font=f_title, fill=(255, 100, 100))

    elif stype == "isentropic":
        draw.text((50, 85), "ISENTROPIC PROCESS (dS = 0 - CONSTANT ENTROPY)", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 640], fill=(25, 45, 65), outline=(255, 215, 0), width=3)
        draw.text((150, 180), "🔥 REVERSIBLE ADIABATIC PROCESS = ISENTROPIC", font=f_large, fill=(50, 255, 50))

        draw.text((150, 270), "• Reversible Adiabatic પ્રોસેસમાં ઉષ્મા આપ-લે Q = 0 અને Friction = 0 હોવાથી", font=f_title, fill=(255, 255, 255))
        draw.text((150, 320), "  Entropy કાયમ અચળ રહે છે (S1 = S2).", font=f_title, fill=(200, 255, 200))

        draw.text((150, 420), "💡 EXAM TRAP: દરેક Reversible Adiabatic પ્રોસેસ Isentropic હોય છે,", font=f_title, fill=(255, 215, 0))
        draw.text((150, 470), "   પરંતુ દરેક Isentropic પ્રોસેસ Reversible Adiabatic હોવી જરૂરી નથી!", font=f_body, fill=(255, 100, 100))

    elif stype == "ts_diagram":
        draw.text((50, 85), "TEMPERATURE-ENTROPY (T-s) DIAGRAM & HEAT TRANSFER", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 320], fill=(35, 25, 75), outline=(0, 255, 255), width=3)
        draw.text((150, 180), "Q_rev = Integral T * ds   ===> Area under T-s curve = Heat Transfer!", font=f_title, fill=(50, 255, 50))

        draw.text((150, 380), "• Isothermal Process: T-s ડાયાગ્રામ પર આડી રેખા (Horizontal Line)", font=f_title, fill=(255, 255, 255))
        draw.text((150, 450), "• Isentropic Process:  T-s ડાયાગ્રામ પર ઊભી રેખા (Vertical Line)", font=f_title, fill=(0, 255, 255))

    elif stype == "exam_traps":
        draw.rectangle([60, 110, 1200, 660], fill=(22, 32, 50), outline=(255, 100, 100), width=3)
        draw.text((180, 140), "GSSSB EXAM TRAPS & CONFUSIONS", font=f_large, fill=(255, 215, 0))

        draw.text((90, 210), "૧. Entropy એ Point Function અને Property છે", font=f_body, fill=(255, 255, 255))
        draw.text((90, 270), "૨. System ની એન્ટ્રોપી ઘટી શકે (ગરમી બહાર જતાં), પણ Universe ની એન્ટ્રોપી કાયમ વધે!", font=f_body, fill=(255, 255, 0))
        draw.text((90, 330), "૩. Throttling Process ઇરરિવર્સિબલ હોવાથી તેમાં એન્ટ્રોપી વધે છે!", font=f_body, fill=(0, 255, 255))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: oint (delta_Q / T) < 0 હોય તો સાયકલ કેવી કહેવાય?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: Irreversible Cycle (ઇરરિવર્સિબલ સાયકલ)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: Reversible Adiabatic પ્રોસેસમાં કઈ પ્રોપર્ટી અચળ રહે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: Entropy (એન્ટ્રોપી)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: વાસ્તવિક પ્રક્રિયાઓમાં Universe ની Entropy માં શો ફેરફાર થાય છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. શૂન્ય થાય છે", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. હંમેશા વધે છે! (Always Increases - સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.5 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_5_s{sc['id']}.mp4"
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
    print("🎬 Merging all 7 Scenes for Topic 1.5 into Final Master Asset...")
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

    print(f"🎉 SUCCESS! Topic 1.5 Upgraded Master Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
