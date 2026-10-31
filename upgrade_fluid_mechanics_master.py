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
        "topic_num": "2.2",
        "name": "Fluid Statics",
        "filename": "fluid_statics.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. પાસ્કલ્સ લૉ અને હાઇડ્રોલિક જેક (Pascal's Law & Hydraulic Press)",
                "text": "પાસ્કલ્સ લૉ જણાવે છે કે: સ્થિર ફ્લુઇડમાં કોઈપણ બિંદુએ દબાણની તીવ્રતા તમામ દિશાઓમાં સમાન હોય છે! Px = Py = Pz! હાઇડ્રોલિક જેક, હાઇડ્રોલિક પ્રેસ અને કાર બ્રેક સિસ્ટમ પાસ્કલ્સ લૉ પર કામ કરે છે. નાના પિસ્ટન પર ઓછું બળ આપીને મોટા પિસ્ટન પર વિશાળ વજન ઊંચકી શકાય છે.",
                "type": "pascal_law"
            },
            {
                "id": 2,
                "title": "૨. હાઇડ્રોસ્ટેટિક લૉ અને પ્રેશર હેડ (Hydrostatic Law & Pressure Head)",
                "text": "હાઇડ્રોસ્ટેટિક લૉ મુજબ ઊંડાઈ z વધતાં દબાણ વધે છે: dp / dz = rho * g! પ્રેશર P = rho * g * h થાય છે. જ્યાં h ને પ્રેશર હેડ કહેવાય છે. ડેમની દીવાલ પર નીચે જતાં દબાણ વધતું હોવાથી ડેમની નીચેની દીવાલ હંમેશા વધુ પહોળી બનાવવામાં આવે છે!",
                "type": "hydrostatic_law"
            },
            {
                "id": 3,
                "title": "૩. દબાણ માપવાના સાધનો (Piezometer & U-Tube Manometer)",
                "text": "દબાણ માપવા માટે: ૧. પિઝોમીટર વડે માત્ર મધ્યમ પોઝિટિવ લિક્વિડ પ્રેશર માપી શકાય છે, તે વાયુ કે નેગેટિવ વેક્યુમ પ્રેશર માપી શકતું નથી! ૨. યુ-ટ્યુબ મેનોમીટરમાં મરક્યુરી વાપરીને હાઇ પ્રેશર અને વેક્યુમ પ્રેશર માપી શકાય છે. ૩. ડિફરન્શિયલ મેનોમીટર વડે બે પાઇપલાઇન વચ્ચેનો દબાણ ફેરફાર માપવામાં આવે છે.",
                "type": "manometers_deep"
            },
            {
                "id": 4,
                "title": "૪. સબમર્જ્ડ સપાટી પર લાગતું હાઇડ્રોસ્ટેટિક બળ (Total Pressure & Center of Pressure)",
                "text": "ફ્લુઇડમાં ડૂબેલી સપાટી પર લાગતું ટોટલ પ્રેશર ફોર્સ F = rho * g * A * x_bar થાય છે. સેન્ટર ઓફ પ્રેશર h_star નું સૂત્ર h_star = x_bar + (I_G * sin^2 theta) / (A * x_bar) થાય છે. પરીક્ષાનો ગોલ્ડન પોઇન્ટ: સેન્ટર ઓફ પ્રેશર h_star એ હંમેશા સેન્ટર ઓફ ગ્રેવિટી x_bar ની નીચે જ હોય છે!",
                "type": "center_of_pressure"
            },
            {
                "id": 5,
                "title": "૫. બોયન્સી અને આર્કિમિડીઝ પ્રિન્સિપલ (Buoyancy & Archimedes Principle)",
                "text": "આર્કિમિડીઝ પ્રિન્સિપલ મુજબ ફ્લુઇડમાં ડૂબેલી વસ્તુ પર ઉપરની દિશામાં લાગતું વર્ટિકલ બોયન્ટ ફોર્સ F_B એ વસ્તુ દ્વારા વિસ્થાપિત થયેલા ફ્લુઇડના વજન જેટલું હોય છે! બોયન્ટ ફોર્સ કાયમ સેન્ટર ઓફ બોયન્સી B પર કામ કરે છે, જે વિસ્થાપિત ફ્લુઇડનું સેન્ટ્રોઇડ છે.",
                "type": "archimedes"
            },
            {
                "id": 6,
                "title": "૬. મેટા સેન્ટ્રિક હાઇટ અને શિપ સ્ટેબિલિટી (Metacentric Height GM)",
                "text": "ફ્લોટિંગ બોડી માટે મેટા સેન્ટ્રિક હાઇટ GM = (I / V_displaced) - BG થાય છે. શિપની સ્ટેબિલિટીની શરતો: ૧. સ્ટેબલ ઇક્વિલિબ્રિયમ: GM > 0 (M એ G ની ઉપર હોય). ૨. ન્યુટ્રલ ઇક્વિલિબ્રિયમ: GM = 0 (M અને G એક જ બિંદુ પર હોય). ૩. અનસ્ટેબલ ઇક્વિલિબ્રિયમ: GM < 0 (M એ G ની નીચે હોય)!",
                "type": "metacentre_stability"
            },
            {
                "id": 7,
                "title": "૭. પરીક્ષામાં થતી ગૂંચવણો (GSSSB Exam Traps)",
                "text": "પરીક્ષાની ૩ કિલર ગોલ્ડન ટ્રેપ્સ: ૧. વર્ટિકલ સપાટી માટે સેન્ટર ઓફ પ્રેશર h_star = (2/3) h (ઉપરથી ૨/૩ ઊંડાઈએ). ૨. પિઝોમીટર ગેસનું દબાણ માપી શકતું નથી. ૩. પેસેન્જર શિપ માટે મેટા સેન્ટ્રિક હાઇટ GM 0.5 થી 1.0 મીટર અને કોમર્શિયલ શિપ માટે 0.3 થી 0.75 મીટર રાખવામાં આવે છે.",
                "type": "exam_traps"
            },
            {
                "id": 8,
                "title": "૮. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: સ્થિર ફ્લુઇડમાં તમામ દિશામાં દબાણ સમાન હોવાનો નિયમ કયો છે? સાચો જવાબ: Pascal's Law! પ્રશ્ન ૨: ફ્લોટિંગ શિપ સ્ટેબલ રહે તે માટે મેટા સેન્ટર M ક્યાં હોવું જોઈએ? સાચો જવાબ: Center of Gravity G ની ઉપર! પ્રશ્ન ૩: પિઝોમીટર વડે કયું દબાણ માપી શકાતું નથી? સાચો જવાબ: Gas & Vacuum Pressure!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.3",
        "name": "Fluid Kinematics & Dynamics",
        "filename": "fluid_kinematics_and_dynamics.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ફ્લુઇડ ફ્લો ના પ્રકારો (Types of Fluid Flow)",
                "text": "ફ્લુઇડ વહનના પ્રકારો: ૧. સ્ટેડી ફ્લો: સમય સાથે ફ્લુઇડ પ્રોપર્ટી બદલાતી નથી. ૨. યુનિફોર્મ ફ્લો: સ્થાન સાથે વેલોસિટી બદલાતી નથી. ૩. લેમિનર ફ્લો: ફ્લુઇડ સ્તરોમાં સમાંતર વહે છે. ૪. ટર્બ્યુલન્ટ ફ્લો: ફ્લુઇડ ઝિગઝેગ અસ્તવ્યસ્ત વહે છે. ૫. રોટેશનલ અને આઇરોટેશનલ ફ્લો.",
                "type": "flow_types"
            },
            {
                "id": 2,
                "title": "૨. સ્ટ્રીમલાઇન, પાથલાઇન અને સ્ટ્રીકલાઇન (Streamline, Pathline & Streakline)",
                "text": "૧. સ્ટ્રીમલાઇન: કાલ્પનિક લાઇન જેના કોઈપણ બિંદુએ દોરેલો સ્પર્શક ટેન્જન્ટ તે બિંદુએ વેલોસિટી દર્શાવે છે. બે સ્ટ્રીમલાઇન ક્યારેય એકબીજાને છેદે નહીં! ૨. પાથલાઇન: એક જ ફ્લુઇડ કણ દ્વારા કાપાયેલો વાસ્તવિક રસ્તો. ૩. સ્ટ્રીકલાઇન: એક જ બિંદુમાંથી પસાર થતા તમામ કણોનું લોકસ. સ્ટેડી ફ્લોમાં આ ત્રણેય લાઇનો એક જ બની જાય છે!",
                "type": "flow_lines"
            },
            {
                "id": 3,
                "title": "૩. કન્ટીન્યુટી ઇક્વેશન (Continuity Equation - Conservation of Mass)",
                "text": "કન્ટીન્યુટી ઇક્વેશન માસ કન્ઝર્વેશન પર આધારિત છે: rho1 * A1 * V1 = rho2 * A2 * V2! ઇનકોમ્પ્રેસિબલ ફ્લુઇડ (rho = const) માટે: A1 * V1 = A2 * V2 અચળ રહે છે! એટલે કે પાઇપનું આડછેદ A ઘટે તો પ્રવાહનો વેગ V વધે છે.",
                "type": "continuity_eq"
            },
            {
                "id": 4,
                "title": "૪. યુલેર્સ અને બર્નોલીસ ઇક્વેશન (Euler's & Bernoulli's Equation)",
                "text": "યુલેર્સ ઇક્વેશન dp / rho + V dV + g dz = 0 નું ઇન્ટિગ્રેશન કરતાં બર્નોલીસ ઇક્વેશન મળે છે: P / (rho * g) + V² / 2g + z = Constant! બર્નોલીસ ઇક્વેશન એ ઊર્જા સંરક્ષણ એનર્જી કન્ઝર્વેશન પર આધારિત છે. આમાં P / rho g પ્રેશર હેડ, V² / 2g કાઇનેટિક હેડ, અને z પોટેન્શિયલ હેડ છે.",
                "type": "bernoulli_deep"
            },
            {
                "id": 5,
                "title": "૫. બર્નોલીસ સમીકરણની ધારણાઓ (Bernoulli's Assumptions)",
                "text": "પરીક્ષામાં વારંવાર પૂછાતી બર્નોલીસ સમીકરણની ૫ ધારણાઓ: ૧. ફ્લુઇડ આદર્શ એટલે કે નોન-વિસ્કસ હોવું જોઈએ. ૨. ફ્લુઇડ ઇનકોમ્પ્રેસિબલ (rho = const) હોવું જોઈએ. ૩. ફ્લો સ્ટેડી હોવો જોઈએ. ૪. ફ્લો આઇરોટેશનલ હોવો જોઈએ. ૫. પ્રવાહ એક જ સ્ટ્રીમલાઇન પર હોવો જોઈએ!",
                "type": "bernoulli_assumptions"
            },
            {
                "id": 6,
                "title": "૬. વેલોસિટી પોટેન્શિયલ અને સ્ટ્રીમ ફંક્શન (phi and psi Functions)",
                "text": "૧. વેલોસિટી પોટેન્શિયલ ફંક્શન phi: માત્ર આઇરોટેશનલ ફ્લો માટે જ અસ્તિત્વ ધરાવે છે. u = - dphi/dx. ૨. સ્ટ્રીમ ફંક્શન psi: ટૂડી ઇનકોમ્પ્રેસિબલ ફ્લો માટે અસ્તિત્વ ધરાવે છે. ક્રોસ પ્રોડક્ટ dphi/dx = dpsi/dy એ કોચી-રીમેન ઇક્વેશન દર્શાવે છે!",
                "type": "potential_stream_functions"
            },
            {
                "id": 7,
                "title": "૭. પરીક્ષાના કિલર ગોલ્ડન ટ્રેપ્સ (Exam Traps)",
                "text": "ગોલ્ડન એક્ઝામ ટ્રેપ્સ: ૧. કન્ટીન્યુટી ઇક્વેશન માસ સંરક્ષણ પર, જ્યારે બર્નોલીસ ઇક્વેશન એનર્જી સંરક્ષણ પર આધારિત છે! ૨. રિયલ વાસ્તવિક ફ્લુઇડ માટે બર્નોલીસ ઇક્વેશન: P1/rho g + V1²/2g + z1 = P2/rho g + V2²/2g + z2 + h_L (જ્યાં h_L એ હેડ લોસ છે).",
                "type": "exam_traps"
            },
            {
                "id": 8,
                "title": "૮. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: કન્ટીન્યુટી ઇક્વેશન કયા સંરક્ષણ નિયમ પર આધારિત છે? સાચો જવાબ: Conservation of Mass! પ્રશ્ન ૨: બર્નોલીસ ઇક્વેશન કયા નિયમ પર આધારિત છે? સાચો જવાબ: Conservation of Energy! પ્રશ્ન ૩: બે સ્ટ્રીમલાઇન એકબીજાને છેદી શકે? સાચો જવાબ: ક્યારેય નહીં!",
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

    temp_raw = f"assets/videos/temp_t2_up_{sc['id']}.mp4"
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
        sc_data["audio_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up_s{sc['id']}.mp3"
        sc_data["video_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up_v{sc['id']}.mp4"
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
