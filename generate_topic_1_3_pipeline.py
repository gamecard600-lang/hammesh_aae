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
        "title": "૧. ફર્સ્ટ લૉ ઓફ થર્મોડાયનેમિક્સ (First Law of Thermodynamics)",
        "text": "થર્મોડાયનેમિક્સનો પ્રથમ નિયમ એટલે ઊર્જા સંરક્ષણનો નિયમ! તે જણાવે છે કે ઊર્જાનો ક્યારેય વિનાશ થતો નથી કે તેને નવેસરથી બનાવી શકાતી નથી. ઊર્જા માત્ર એક સ્વરૂપમાંથી બીજા સ્વરૂપમાં રૂપાંતરિત થાય છે. કોઈપણ સાયકલ માટે ક્યુ બરાબર ડબ્લ્યુ થાય છે. અને પ્રક્રિયા માટે સૂત્ર છે: ક્યુ બરાબર ડેલ્ટા યુ વત્તા ડબ્લ્યુ. જ્યાં ક્યુ એટલે આપેલી ઉષ્મા, ડેલ્ટા યુ એટલે ઇન્ટરનલ એનર્જીનો ફેરફાર, અને ડબલ્યુ એટલે થયેલું કાર્ય.",
        "audio_file": "assets/videos/t1_3_scene_1.mp3",
        "video_file": "assets/videos/t1_3_std_scene_1.mp4",
        "type": "first_law_intro"
    },
    {
        "id": 2,
        "title": "૨. જ્યુલ્સ એક્સપેરિમેન્ટ અને ઇન્ટરનલ એનર્જી (Internal Energy U)",
        "audio_file": "assets/videos/t1_3_scene_2.mp3",
        "video_file": "assets/videos/t1_2_std_scene_2.mp4",
        "text": "જ્યુલ્સના પ્રયોગ દ્વારા સાબિત થયું કે યાંત્રિક કાર્ય વર્કનું ઉષ્મા હીટમાં સંપૂર્ણ રૂપાંતર શક્ય છે. અહીં ઇન્ટરનલ એનર્જી યુ એ સિસ્ટમની આણ્વિક સ્થિતિ દર્શાવતો પોઇન્ટ ફંક્શન છે. આદર્શ વાયુ માટે જૂલ્સના નિયમ મુજબ ઇન્ટરનલ એનર્જી માત્ર અને માત્ર તાપમાન પર જ આધાર રાખે છે. એટલે કે યુ બરાબર ફંક્શન ઓફ કેપિટલ ટી!",
        "type": "joule_internal_energy"
    },
    {
        "id": 3,
        "title": "૩. એન્થાલ્પીનો ખ્યાલ (Enthalpy H = U + PV)",
        "audio_file": "assets/videos/t1_3_scene_3.mp3",
        "video_file": "assets/videos/t1_3_std_scene_3.mp4",
        "text": "એન્થાલ્પી એટલે સિસ્ટમની કુલ ઉષ્મા ઉર્જાનો જથ્થો! તેનું સૂત્ર છે: કેપિટલ એચ બરાબર યુ વત્તા પી વી. જ્યાં યુ એટલે ઇન્ટરનલ એનર્જી, અને પી વી એટલે ફ્લો એનર્જી. અચળ દબાણે આપેલી ઉષ્મા એ એન્થાલ્પી ફેરફાર ડેલ્ટા એચ બરાબર થાય છે. એન્થાલ્પી પણ સ્ટેટ ફંક્શન અને પોઇન્ટ ફંક્શન છે, અને તેનો એસઆઈ એકમ કિલોજૂલ છે.",
        "type": "enthalpy_concept"
    },
    {
        "id": 4,
        "title": "૪. પીએમએમ-૧ (Perpetual Motion Machine of First Kind - PMM-1)",
        "audio_file": "assets/videos/t1_3_scene_4.mp3",
        "video_file": "assets/videos/t1_3_std_scene_4.mp4",
        "text": "પીએમએમ-૧ એટલે એવી કાલ્પનિક અશક્ય મશીન જે કોઈપણ ઊર્જા કે હીટ ઇનપુટ લીધા વગર સતત કાર્ય આઉટપુટ આપતી રહે! અથવા કોઈપણ કાર્ય લાયા વગર આપમેળે ઉષ્મા ઉત્પન્ન કરે. આવું મશીન બનાવવું અશક્ય છે કારણ કે તે ફર્સ્ટ લૉ ઓફ થર્મોડાયનેમિક્સનો ભંગ કરે છે!",
        "type": "pmm1_concept"
    },
    {
        "id": 5,
        "title": "૫. સ્ટેડી ફ્લો એનર્જી ઇક્વેશન (SFEE Applications)",
        "audio_file": "assets/videos/t1_3_scene_5.mp3",
        "video_file": "assets/videos/t1_3_std_scene_5.mp4",
        "text": "ઓપન સિસ્ટમ માટે સ્ટેડી ફ્લો એનર્જી ઇક્વેશન એચ ૧ વત્તા વી ૧ સ્કવેર બાય ટુ વત્તા જી ઝેડ ૧ વત્તા ક્યુ બરાબર એચ ૨ વત્તા વી ૨ સ્કવેર બાય ટુ વત્તા જી ઝેડ ૨ વત્તા ડબલ્યુ થાય છે. ૧. નોઝલ માટે એક્ઝિટ વેલોસિટી વી ૨ બરાબર અંડરરૂટ ટુ ગુણ્યા એચ ૧ માઇનસ એચ ૨. ૨. ટર્બાઇન માટે વર્ક આઉટપુટ ડબલ્યુ બરાબર એચ ૧ માઇનસ એચ ૨. અને ૩. બોઇલર માટે હીટ ઇનપુટ ક્યુ બરાબર એચ ૨ માઇનસ એચ ૧ થાય છે.",
        "type": "sfee_apps"
    },
    {
        "id": 6,
        "title": "૬. પરીક્ષાના કિલર ગોલ્ડન ટ્રેપ્સ (Path vs Point Functions)",
        "audio_file": "assets/videos/t1_3_scene_6.mp3",
        "video_file": "assets/videos/t1_3_std_scene_6.mp4",
        "text": "પરીક્ષાની સૌથી મોટી ગોલ્ડન ટ્રેપ: હીટ ક્યુ અને વર્ક ડબલ્યુ એ પાથ ફંક્શન અને ઇનએક્ઝેક્ટ ડિફરન્શિયલ છે! જ્યારે ઇન્ટરનલ એનર્જી યુ અને એન્થાલ્પી એચ એ પોઇન્ટ ફંક્શન અને એક્ઝેક્ટ ડિફરન્શિયલ છે! અચળ કદ પ્રોસેસમાં હીટ ટ્રાન્સફર ઇન્ટરનલ એનર્જી ડેલ્ટા યુ બરાબર થાય છે, જ્યારે અચળ દબાણ પ્રોસેસમાં હીટ ટ્રાન્સફર એન્થાલ્પી ડેલ્ટા એચ બરાબર થાય છે!",
        "type": "exam_traps"
    },
    {
        "id": 7,
        "title": "૭. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_3_scene_7.mp3",
        "video_file": "assets/videos/t1_3_std_scene_7.mp4",
        "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: આદર્શ વાયુની ઇન્ટરનલ એનર્જી કોના પર આધાર રાખે છે? સાચો જવાબ: માત્ર તાપમાન પર! પ્રશ્ન ૨: ઊર્જા આપ્યા વગર સતત કાર્ય આપતી મશીન પીએમએમ-૧ કયા નિયમનો ભંગ કરે છે? સાચો જવાબ: ફર્સ્ટ લૉ ઓફ થર્મોડાયનેમિક્સ! અને પ્રશ્ન ૩: નોઝલમાંથી નીકળતા ફ્લુઇડની વેલોસિટીનું સૂત્ર કયું છે? સાચો જવાબ: વી ૨ બરાબર અંડરરૂટ ટુ ઇન બ્રેકેટ એચ ૧ માઇનસ એચ ૨!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/first_law_energy_enthalpy.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.3 Gujarati Audio Narration...")
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

    if stype == "first_law_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "FIRST LAW OF THERMODYNAMICS (ઉર્જા સંરક્ષણનો નિયમ)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 210, 1140, 350], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 240), "For a Cycle:   oint delta_Q = oint delta_W   (Net Heat = Net Work)", font=f_title, fill=(50, 255, 50))
        draw.text((150, 295), "For a Process: Q = delta_U + W  ===>  delta_U = Q - W", font=f_title, fill=(0, 255, 255))

        draw.text((120, 400), "• Q = સિસ્ટમને આપેલી કે બહાર નીકળતી ઉષ્મા (Heat Transfer)", font=f_body, fill=(255, 255, 255))
        draw.text((120, 460), "• delta_U = ઇન્ટરનલ એનર્જીનો ફેરફાર (Change in Internal Energy)", font=f_body, fill=(200, 255, 200))
        draw.text((120, 520), "• W = સિસ્ટમ દ્વારા કે સિસ્ટમ પર થયેલું કાર્ય (Work Done)", font=f_body, fill=(200, 255, 200))

    elif stype == "joule_internal_energy":
        draw.rectangle([80, 120, 1200, 650], fill=(22, 32, 50), outline=(255, 215, 0), width=3)
        draw.text((120, 150), "JOULE'S EXPERIMENT & INTERNAL ENERGY (U)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 220, 1160, 360], fill=(40, 20, 60), outline=(0, 255, 255), width=2)
        draw.text((150, 250), "🔥 Joule's Law for Ideal Gas:", font=f_title, fill=(255, 215, 0))
        draw.text((150, 300), "Ideal Gas ની Internal Energy (U) માત્ર તાપમાન (T) પર આધાર રાખે છે!", font=f_title, fill=(50, 255, 50))
        draw.text((150, 350), "U = f(T)   ===>   delta_U = m * c_v * (T2 - T1)", font=f_large, fill=(255, 255, 255))

        draw.text((120, 450), "• Internal Energy (U) એ Point Function અને State Function છે.", font=f_body, fill=(255, 255, 255))
        draw.text((120, 510), "• Exact Differential (dU) ધરાવે છે. SI એકમ: kJ", font=f_body, fill=(200, 255, 200))

    elif stype == "enthalpy_concept":
        draw.text((50, 85), "એન્થાલ્પીનો ખ્યાલ (Enthalpy H = U + PV)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 300], fill=(35, 25, 75), outline=(0, 255, 255), width=3)
        draw.text((360, 180), "H = U + P * V   (kJ)", font=f_large, fill=(255, 255, 255))
        draw.text((220, 240), "Enthalpy = Internal Energy (U) + Flow Energy (PV)", font=f_title, fill=(50, 255, 50))

        draw.rectangle([120, 330, 1160, 630], fill=(20, 30, 45), outline=(255, 215, 0), width=2)
        draw.text((150, 370), "• Constant Pressure Process (અચળ દબાણ): Q_p = delta_H", font=f_title, fill=(0, 255, 255))
        draw.text((150, 430), "• Ideal Gas માટે Enthalpy:  delta_H = m * c_p * (T2 - T1)", font=f_title, fill=(200, 255, 200))
        draw.text((150, 490), "• Enthalpy પણ Point Function અને State Function છે.", font=f_body, fill=(255, 255, 255))

    elif stype == "pmm1_concept":
        draw.text((50, 85), "PERPETUAL MOTION MACHINE OF FIRST KIND (PMM-1)", font=f_large, fill=(255, 100, 100))

        draw.rectangle([120, 140, 1160, 640], fill=(45, 18, 18), outline=(255, 80, 80), width=3)
        draw.text((150, 180), "❌ IMPOSSIBLE MACHINE (અશક્ય કાલ્પનિક મશીન)", font=f_large, fill=(255, 80, 80))

        draw.text((150, 270), "• ક્યારેય કોઈ ઊર્જા કે હીટ ઇનપુટ લીધા વગર સતત વર્ક આઉટપુટ આપતી મશીન!", font=f_title, fill=(255, 255, 255))
        draw.text((150, 340), "• અથવા કોઈપણ કાર્ય લાયા વગર આપમેળે ઉષ્મા ઉત્પન્ન કરતી મશીન!", font=f_title, fill=(255, 255, 255))

        draw.text((150, 450), "🔥 EXAM TRAP: PMM-1 થર્મોડાયનેમિક્સના First Law નો ભંગ કરે છે!", font=f_large, fill=(255, 215, 0))

    elif stype == "sfee_apps":
        draw.text((50, 85), "STEADY FLOW ENERGY EQUATION (SFEE) APPLICATIONS", font=f_large, fill=(0, 255, 255))

        draw.rectangle([50, 130, 1230, 660], fill=(20, 30, 45), outline=(0, 255, 255), width=2)
        draw.text((70, 150), "DEVICE                                 SFEE SIMPLIFIED EQUATION", font=f_title, fill=(0, 255, 255))
        draw.line([70, 190, 1210, 190], fill=(150, 150, 150), width=2)

        draw.text((70, 220), "૧. Nozzle (એક્ઝિટ વેલોસિટી)", font=f_body, fill=(255, 255, 255))
        draw.text((550, 220), "V2 = sqrt(2 * (h1 - h2))  [m/s]", font=f_title, fill=(50, 255, 50))

        draw.text((70, 290), "૨. Turbine (વર્ક આઉટપુટ)", font=f_body, fill=(255, 255, 255))
        draw.text((550, 290), "W_out = h1 - h2   [kJ/kg]", font=f_title, fill=(50, 255, 50))

        draw.text((70, 360), "૩. Compressor (વર્ક ઇનપુટ)", font=f_body, fill=(255, 255, 255))
        draw.text((550, 360), "W_in = h2 - h1    [kJ/kg]", font=f_title, fill=(200, 255, 200))

        draw.text((70, 430), "૪. Boiler (હીટ ઇનપુટ)", font=f_body, fill=(255, 255, 255))
        draw.text((550, 430), "Q_in = h2 - h1    [kJ/kg]", font=f_title, fill=(200, 255, 200))

        draw.text((70, 510), "૫. Throttling Valve (એન્થાલ્પી અચળ)", font=f_body, fill=(255, 255, 255))
        draw.text((550, 510), "h1 = h2   (Isenthalpic Process)", font=f_title, fill=(255, 215, 0))

    elif stype == "exam_traps":
        draw.rectangle([60, 110, 1200, 660], fill=(22, 32, 50), outline=(255, 100, 100), width=3)
        draw.text((180, 140), "GSSSB EXAM TRAPS & CONFUSIONS", font=f_large, fill=(255, 215, 0))

        draw.text((90, 210), "૧. Heat (Q) અને Work (W) = Path Functions & Inexact Differentials (delta_Q, delta_W)", font=f_body, fill=(255, 255, 255))
        draw.text((90, 270), "૨. Internal Energy (U) અને Enthalpy (H) = Point Functions & Exact Differentials (dU, dH)", font=f_body, fill=(50, 255, 50))
        draw.text((90, 330), "૩. Constant Volume Process (Isochoric):  Q_v = delta_U", font=f_body, fill=(255, 255, 0))
        draw.text((90, 390), "૪. Constant Pressure Process (Isobaric): Q_p = delta_H", font=f_body, fill=(0, 255, 255))
        draw.text((90, 450), "૫. Free Expansion Process: Work Done W = 0, Heat Q = 0  ===> delta_U = 0!", font=f_body, fill=(255, 150, 150))
        draw.text((90, 510), "૬. Ideal Gas ની Internal Energy માત્ર તાપમાન (T) પર જ આધાર રાખે છે (Joule's Law)", font=f_body, fill=(200, 255, 200))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: આદર્શ વાયુની Internal Energy (U) કોના પર આધાર રાખે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: માત્ર તાપમાન પર! (Temperature Only - Joule's Law)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: ઊર્જા આપ્યા વગર સતત કાર્ય આપતી મશીન PMM-1 કયા નિયમનો ભંગ કરે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: First Law of Thermodynamics!", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: Nozzle માંથી નીકળતા ફ્લુઇડની Exit Velocity V2 નું સૂત્ર કયું છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. V2 = sqrt(h1 - h2)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. V2 = sqrt(2 * (h1 - h2))   (સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.3 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_3_s{sc['id']}.mp4"
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
    print("🎬 Merging all 7 Scenes for Topic 1.3 into Final Asset...")
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

    print(f"🎉 SUCCESS! Topic 1.3 Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
