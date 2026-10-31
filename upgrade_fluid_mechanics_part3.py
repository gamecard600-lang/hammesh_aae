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
        "topic_num": "2.6",
        "name": "Control Volume Analysis",
        "filename": "fluid_control_volume.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ઇમ્પુલ્સ-મોમેન્ટમ પ્રિન્સિપલ અને ફોર્સ ઓન પાઇપ બેન્ડ (Impulse-Momentum Principle)",
                "text": "ઇમ્પુલ્સ-મોમેન્ટમ પ્રિન્સિપલ ન્યૂટનના બીજા ગતિનિયમ કન્ઝર્વેશન ઓફ મોમેન્ટમ પર આધારિત છે! ફ્લુઇડ દ્વારા પાઇપ બેન્ડ કે નોઝલ પર લાગતું નેટ ફોર્સ F બરાબર માસ ફ્લો રેટ m_dot ગુણ્યા વેલોસિટીનો ફેરફાર (V2 - V1) થાય છે! આ સિદ્ધાંત જેટ પ્રોપલ્શન અને ટર્બાઇન બ્લેડ પર બળ ગણવા વપરાય છે.",
                "type": "momentum"
            },
            {
                "id": 2,
                "title": "૨. મોમેન્ટમ ઇક્વેશન એપ્લિકેશન્સ (Applications of Momentum Equation)",
                "text": "કંટ્રોલ વોલ્યુમ વિશ્લેષણમાં ઇનલેટ અને આઉટલેટ મોમેન્ટમ નો ફેરફાર ગણવામાં આવે છે. સડન એનલાર્જમેન્ટ હેડ લોસ h_e = (V1 - V2)^2 / 2g ની સાબિતી મોમેન્ટમ ઇક્વેશન અને બર્નોલીસ ઇક્વેશનના સમન્વયથી મળે છે!",
                "type": "momentum_apps"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: ઇમ્પુલ્સ-મોમેન્ટમ પ્રિન્સિપલ ન્યૂટનના કયા નિયમ પર આધારિત છે? સાચો જવાબ: Newton's Second Law of Motion! પ્રશ્ન ૨: પાઇપ બેન્ડ પર લાગતું ફોર્સ ગણવા કયું સમીકરણ વપરાય છે? સાચો જવાબ: Momentum Equation!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.7",
        "name": "Laminar & Turbulent Flow",
        "filename": "laminar_and_turbulent_flow.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. રેનોલ્ડ્સ નંબર અને ફ્લો રિજિમ્સ (Reynold's Number Re)",
                "text": "રેનોલ્ડ્સ નંબર Re એ ઇનર્શિયા ફોર્સ અને વિસ્કસ ફોર્સનો રેશિયો છે: Re = rho * V * D / mu! ૧. સર્ક્યુલર પાઇપમાં જો Re < 2000 હોય તો ફ્લો લેમિનર કહેવાય. ૨. જો 2000 < Re < 4000 હોય તો ટ્રાન્ઝિશનલ ફ્લો કહેવાય. ૩. જો Re > 4000 હોય તો ટર્બ્યુલન્ટ ફ્લો કહેવાય છે!",
                "type": "reynolds"
            },
            {
                "id": 2,
                "title": "૨. હેગન-પોઇઝ્યુઇ ઇક્વેશન (Hagen-Poiseuille Flow in Circular Pipe)",
                "text": "સર્ક્યુલર પાઇપમાં લેમિનર ફ્લો માટે હેગન-પોઇઝ્યુઇ ઇક્વેશન મુજબ વેલોસિટી પ્રોફાઇલ પેરાબોલિક હોય છે! મહત્તમ વેલોસિટી U_max બરાબર સરેરાશ વેલોસિટી U_avg ના બમણા ૨ ગણી હોય છે! (U_max = 2 * U_avg). હેડ લોસ h_f = 32 mu U_avg L / (rho g D^2) થાય છે. અને ફ્રિક્શન ફેક્ટર f = 64 / Re થાય છે!",
                "type": "poiseuille"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પાઇપમાં લેમિનર ફ્લો માટે રેનોલ્ડ્સ નંબર કેટલો હોવો જોઈએ? સાચો જવાબ: Re < 2000! પ્રશ્ન ૨: લેમિનર પાઇપ ફ્લો માટે U_max અને U_avg નો રેશિયો કેટલો હોય? સાચો જવાબ: 2.0! પ્રશ્ન ૩: લેમિનર ફ્લોમાં ફ્રિક્શન ફેક્ટર f નું સૂત્ર કયું છે? સાચો જવાબ: f = 64 / Re!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.8",
        "name": "Boundary Layer Theory",
        "filename": "boundary_layer_theory.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. બાઉન્ડ્રી લેયર થીયરમ અને થિકનેસ (Boundary Layer Concept)",
                "text": "જ્યારે ફ્લુઇડ પ્લેટ પરથી વહે છે ત્યારે દીવાલ પર નો-સ્લિપ કન્ડીશનને લીધે વેલોસિટી ૦ થી વધીને ૦.૯૯ V થાય છે, તે વિસ્તારને બાઉન્ડ્રી લેયર કહેવાય છે. ડિસ્પ્લેસમેન્ટ થિકનેસ delta_star, મોમેન્ટમ થિકનેસ theta, અને એનર્જી થિકનેસ delta_star_star વચ્ચેનો સંબંધ: delta_star > theta > delta_star_star હોય છે!",
                "type": "boundary_layer"
            },
            {
                "id": 2,
                "title": "૨. બાઉન્ડ્રી લેયર સેપરેશન (Boundary Layer Separation)",
                "text": "જ્યારે એડવર્સ પ્રેશર ગ્રેડિયંત dp/dx > 0 થાય અને દીવાલ પર શિયર સ્ટ્રેસ du/dy = 0 થાય, ત્યારે બાઉન્ડ્રી લેયર પ્લેટથી અલગ પડે છે જેને બાઉન્ડ્રી લેયર સેપરેશન કહેવાય છે! સેપરેશન અટકાવવા પ્લેટ પર સક્શન કે ઇન્જેક્શન વાપરવામાં આવે છે.",
                "type": "separation"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: બાઉન્ડ્રી લેયર સેપરેશન ક્યારે થાય છે? સાચો જવાબ: Adverse Pressure Gradient dp/dx > 0 થાય ત્યારે! પ્રશ્ન ૨: દીવાલ પર બાઉન્ડ્રી લેયર સેપરેશન પોઇન્ટ પર શિયર સ્ટ્રેસ કેટલો હોય? સાચો જવાબ: Zero (du/dy = 0)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.12",
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
                "title": "૨. સ્ટેગ્નેશન પ્રોપર્ટીઝ અને શૉક વેવ્સ (Stagnation Properties & Shock Waves)",
                "text": "જ્યારે કોમ્પ્રેસિબલ ફ્લુઇડનો વેગ ઝીરો કરવામાં આવે ત્યારે મળતા દબાણ અને તાપમાનને સ્ટેગ્નેશન પ્રેશર P0 અને સ્ટેગ્નેશન ટેમ્પરેચર T0 કહેવાય છે. સુપરસોનિક ફ્લોમાં અચાનક દબાણ વધતાં નોર્મલ શૉક વેવ બને છે!",
                "type": "stagnation_shock"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સુપરસોનિક ફ્લો માટે મેક નંબર Ma કેટલો હોવો જોઈએ? સાચો જવાબ: Ma > 1! પ્રશ્ન ૨: સાઉન્ડની ઝડપ C નું સૂત્ર કયું છે? સાચો જવાબ: C = sqrt(gamma * R * T)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.13",
        "name": "Open Channel Flow",
        "filename": "open_channel_flow.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. મોસ્ટ ઇકોનોમિકલ ચેનલ સેક્શન (Most Economical Channel Section)",
                "text": "ઓપન ચેનલમાં ફ્રી સપાટી પર વાતાવરણીય દબાણ હોય છે. મોસ્ટ ઇકોનોમિકલ સેક્શન માટે ઓછામાં ઓછી વેટ્ટેડ પેરીમીટર P પર મહત્તમ ડિસ્ચાર્જ Q મળે છે! ૧. રેક્ટેન્ગ્યુલર સેક્શન માટે હાઇડ્રોલિક મીન ડેપ્થ R બરાબર y / 2 થાય છે. ૨. ટ્રેપેઝોઇડલ સેક્શન માટે બેસ્ટ સેક્શન હાફ હેક્ઝાટોન હોય છે!",
                "type": "open_channel"
            },
            {
                "id": 2,
                "title": "૨. સ્પેસિફિક એનર્જી અને હાઇડ્રોલિક જમ્પ (Specific Energy & Hydraulic Jump)",
                "text": "સ્પેસિફિક એનર્જી E બરાબર y + V² / 2g થાય છે. સુપરક્રિટિકલ ફ્લોમાંથી સબક્રિટિકલ ફ્લોમાં રૂપાંતર થતાં અચાનક પાણીની ઊંડાઈ વધે છે, જેને હાઇડ્રોલિક જમ્પ કહેવાય છે! હાઇડ્રોલિક જમ્પમાં નોંધપાત્ર ઊર્જાનો વ્યય થાય છે.",
                "type": "hydraulic_jump"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: મોસ્ટ ઇકોનોમિકલ રેક્ટેન્ગ્યુલર ચેનલ માટે હાઇડ્રોલિક રેડિયસ R કેટલું હોવું જોઈએ? સાચો જવાબ: R = y / 2! પ્રશ્ન ૨: હાઇડ્રોલિક જમ્પ ક્યારે થાય છે? સાચો જવાબ: Supercritical Flow માંથી Subcritical Flow માં જતાં!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.14",
        "name": "Model Analysis & Similitude",
        "filename": "model_analysis_and_similitude.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. સિમીલીટ્યુડ અને ડાઇમેન્શનલેસ નંબર્સ (Similitude & Dimensionless Numbers)",
                "text": "સિમીલીટ્યુડ એટલે મોડેલ અને પ્રોટોટાઇપ વચ્ચેની ત્રણ પ્રકારની સામ્યતા: જીઓમેટ્રિક, કાઇનેમેટિક અને ડાયનામિક સિમીલીટ્યુડ! ૧. ફ્રૌડ નંબર Fr એ ગ્રેવિટી ફ્લો (ડેમ, સ્પિલવે, ઓપન ચેનલ) માં વપરાય છે. ૨. રેનોલ્ડ્સ નંબર Re પાઇપ ફ્લોમાં વપરાય છે. ૩. વેબર નંબર We સરફેસ ટેન્શન ફ્લોમાં વપરાય છે. ૪. માચ નંબર Ma સુપરસોનિક ફ્લોમાં વપરાય છે.",
                "type": "similitude"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સ્પિલવે અને ડેમ મોડેલ એનાલિસિસમાં કયો ડાઇમેન્શનલેસ નંબર વપરાય છે? સાચો જવાબ: Froude Number (ફ્રૌડ નંબર)! પ્રશ્ન ૨: પાઇપ ફ્લો મોડેલ એનાલિસિસમાં કયો નંબર વપરાય છે? સાચો જવાબ: Reynolds Number (રેનોલ્ડ્સ નંબર)!",
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

    temp_raw = f"assets/videos/temp_t2_up3_{sc['id']}.mp4"
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
    print(f"🎬 PROCESSING UPGRADED TOPIC {top['topic_num']}: {top['name']}")
    print(f"=======================================================")

    scenes_list = []
    for sc in top["scenes"]:
        sc_data = sc.copy()
        sc_data["audio_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up3_s{sc['id']}.mp3"
        sc_data["video_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up3_v{sc['id']}.mp4"
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

    print(f"🎉 SUCCESS! Topic {top['topic_num']} Upgraded Master Video Saved: {out_path}")

if __name__ == "__main__":
    for top in FLUID_TOPICS:
        process_topic(top)
