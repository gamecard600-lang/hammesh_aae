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
        "topic_num": "2.4",
        "name": "Units & Dimensions",
        "filename": "units_and_dimensions.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ફંડામેન્ટલ યુનિટ્સ અને ડાઇમેન્શનલ એનાલિસિસ (Fundamental Units)",
                "text": "ડાઇમેન્શનલ એનાલિસિસમાં ફંડામેન્ટલ રાશિઓ માસ M, લેન્થ L, અને ટાઇમ T છે. ફોર્સનું ડાઇમેન્શનલ સૂત્ર M L T^-2 છે. પ્રેશર અને મોડ્યુલસ ઓફ ઇલાસ્ટિસીટીનું ડાઇમેન્શન M L^-1 T^-2 છે. ડાયનામિક વિસ્કોસિટીનું ડાઇમેન્શન M L^-1 T^-1 છે, અને કાઇનેમેટિક વિસ્કોસિટીનું L^2 T^-1 છે.",
                "type": "dimensions"
            },
            {
                "id": 2,
                "title": "૨. બકિંગહામ પાઈ થિયરમ (Buckingham Pi Theorem)",
                "text": "બકિંગહામ પાઈ થિયરમ મુજબ જો n વેરીએબલ્સ m ફંડામેન્ટલ ડાઇમેન્શન્સ ધરાવતા હોય, તો n minus m જેટલા ડાઇમેન્શનલેસ પાઈ ટર્મ્સ બને છે! રાઈલે મેથડ અને પાઈ થિયરમ વડે ફ્લુઇડ ફ્લો મોડેલ્સના સૂત્રો મેળવવામાં આવે છે.",
                "type": "buckingham_pi"
            },
            {
                "id": 3,
                "title": "૩. ડાઇમેન્શનલેસ નંબર્સ (Froude, Reynolds, Weber, Mach Numbers)",
                "text": "ફ્લુઇડ મિકેનિક્સના ૫ મુખ્ય ડાઇમેન્શનલેસ નંબર્સ: ૧. રેનોલ્ડ્સ નંબર Re = Inertia Force / Viscous Force. ૨. ફ્રૌડ નંબર Fr = sqrt(Inertia / Gravity Force) [ઓપન ચેનલ અને સ્પિલવે]. ૩. વેબર નંબર We = Inertia / Surface Tension Force. ૪. માચ નંબર Ma = Inertia / Elastic Force.",
                "type": "dimensionless_all"
            },
            {
                "id": 4,
                "title": "૪. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: ડાયનામિક વિસ્કોસિટીનું ડાઇમેન્શનલ સૂત્ર કયું છે? સાચો જવાબ: M L^-1 T^-1! પ્રશ્ન ૨: કાઇનેમેટિક વિસ્કોસિટીનું ડાઇમેન્શન કયું છે? સાચો જવાબ: L^2 T^-1! પ્રશ્ન ૩: n વેરીએબલ અને m ડાઇમેન્શન હોય તો કેટલા Pi ટર્મ બને? સાચો જવાબ: n - m!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.5",
        "name": "Flow Through Pipes",
        "filename": "flow_through_pipes.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ડાર્સી-વેઇસબેચ ઇક્વેશન અને મેજર લોસ (Darcy-Weisbach Equation)",
                "text": "પાઇપમાં ઘર્ષણને લીધે થતા મેજર હેડ લોસનું સૂત્ર ડાર્સી-વેઇસબેચ ઇક્વેશન છે: h_f = 4 f L V^2 / 2g D! જ્યાં f ને ફ્રિક્શન ફેક્ટર કહેવાય છે. સી ચેઝીસ ફોર્મ્યુલા V = C sqrt(m i) વડે પણ હેડ લોસ માપી શકાય છે.",
                "type": "darcy_weisbach"
            },
            {
                "id": 2,
                "title": "૨. માઇનર લોસીસ (Minor Losses in Pipes)",
                "text": "પાઇપમાં અચાનક પહોળા થવાથી સડન એન્લાર્જમેન્ટ લોસ h_e = (V1 - V2)^2 / 2g થાય છે. અચાનક સાંકડા થવાથી સડન કોન્ટ્રેક્શન લોસ h_c = 0.5 V^2 / 2g થાય છે. પાઇપ ઇનલેટ લોસ 0.5 V^2 / 2g અને આઉટલેટ લોસ V^2 / 2g થાય છે.",
                "type": "minor_losses"
            },
            {
                "id": 3,
                "title": "૩. HGL અને TEL લાઇન્સ (Hydraulic Gradient Line & Total Energy Line)",
                "text": "હાઇડ્રોલિક ગ્રેડિઅન્ટ લાઇન HGL એ P / rho g + z દર્શાવે છે, જ્યારે ટોટલ એનર્જી લાઇન TEL એ HGL કરતાં કાઇનેટિક હેડ V^2 / 2g જેટલી કાયમ ઉપર હોય છે! ડુપુઇટ ઇક્વેશન વડે સીરિઝ પાઇપ માટે ઇક્વિવેલેન્ટ લંબાઈ L_e ગણાય છે.",
                "type": "hgl_tel_lines"
            },
            {
                "id": 4,
                "title": "૪. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પાઇપમાં ઘર્ષણને લીધે થતા હેડ લોસનું ડાર્સી સૂત્ર કયું છે? સાચો જવાબ: h_f = 4fLV^2 / 2gD! પ્રશ્ન ૨: TEL એ HGL લાઇન કરતાં કેટલી ઊંચી હોય છે? સાચો જવાબ: V^2 / 2g જેટલી!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.9",
        "name": "Flow Measurement Devices",
        "filename": "flow_measurement_devices.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. વેન્ચ્યુરીમીટર અને ડિસ્ચાર્જ સૂત્ર (Venturimeter & Discharge Q)",
                "text": "વેન્ચ્યુરીમીટર એ પાઇપમાં ડિસ્ચાર્જ Q માપવા માટેનું સૌથી સચોટ સાધન છે. તેમાં કન્વર્જિંગ કોન, થ્રોટ, અને ડાઇવર્જિંગ કોન હોય છે. ડાઇવર્જિંગ કોનનો એન્ગલ ૫ થી ૭ ડિગ્રી ઓછો રાખવામાં આવે છે જેથી ફ્લો સેપરેશન અટકી જાય! ડિસ્ચાર્જ Q = C_d * A1 A2 / sqrt(A1² - A2²) * sqrt(2g h) થાય છે.",
                "type": "venturimeter"
            },
            {
                "id": 2,
                "title": "૨. ઓરિફિસમીટર અને પિટોટ ટ્યુબ (Orificemeter & Pitot Tube)",
                "text": "ઓરિફિસમીટર એ વેન્ચ્યુરીમીટર કરતાં સસ્તું પણ વધુ લોસવાળું સાધન છે. પિટોટ ટ્યુબ એ પાઇપમાં કોઈ ચોક્કસ બિંદુએ લોકલ વેલોસિટી V માપવા વપરાય છે! પિટોટ ટ્યુબ સ્ટેગ્નેશન પ્રેશર પર કામ કરે છે અને V = C_v sqrt(2g h) દર્શાવે છે.",
                "type": "pitot_tube"
            },
            {
                "id": 3,
                "title": "૩. નોચ અને વીઅર (Triangular V-Notch & Rectangular Notch)",
                "text": "ઓપન ચેનલમાં ડિસ્ચાર્જ માપવા નોચ અને વીઅર વપરાય છે. રેક્ટેન્ગ્યુલર નોચ માટે ડિસ્ચાર્જ Q પ્રોપોશનલ ટુ H^(3/2) થાય છે, જ્યારે ટ્રાયએન્ગ્યુલર V-નોચ માટે Q પ્રોપોશનલ ટુ H^(5/2) થાય છે! ઓછી માત્રામાં ડિસ્ચાર્જ માપવા V-નોચ સૌથી વધુ સચોટ છે.",
                "type": "notches_deep"
            },
            {
                "id": 4,
                "title": "૪. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પાઇપમાં લોકલ વેલોસિટી માપવા કયું સાધન વપરાય છે? સાચો જવાબ: Pitot Tube! પ્રશ્ન ૨: V-નોચમાં ડિસ્ચાર્જ Q કોના સમપ્રમાણમાં હોય છે? સાચો જવાબ: H^(5/2) ના! પ્રશ્ન ૩: વેન્ચ્યુરીમીટરમાં ડાઇવર્જિંગ એન્ગલ કેટલો રાખવામાં આવે છે? સાચો જવાબ: 5 થી 7 ડિગ્રી!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.10",
        "name": "Hydraulic Turbines",
        "filename": "hydraulic_turbines.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. હાઇડ્રોલિક ટર્બાઇન્સનું વર્ગીકરણ (Turbines Classification)",
                "text": "ટર્બાઇન હાઇડ્રોલિક એનર્જીનું મિકેનિકલ વર્કમાં રૂપાંતર કરે છે. ૧. પેલ્ટન વ્હીલ: હાઇ હેડ (200m+), લો ડિસ્ચાર્જ ઇમ્પલ્સ ટર્બાઇન. ૨. ફ્રાન્સિસ ટર્બાઇન: મીડિયમ હેડ (30m-200m), મિશ્ર રિએક્શન ટર્બાઇન. ૩. કપ્લાન ટર્બાઇન: લો હેડ (<30m), હાઇ ડિસ્ચાર્જ એક્સિયલ રિએક્શન ટર્બાઇન!",
                "type": "turbines_classification"
            },
            {
                "id": 2,
                "title": "૨. સ્પેસિફિક સ્પીડ સૂત્ર (Specific Speed N_s = N sqrt(P) / H^(5/4))",
                "text": "ટર્બાઇનની સ્પેસિફિક સ્પીડ N_s = N sqrt(P) / H^(5/4) થાય છે! પેલ્ટન વ્હીલ માટે N_s ઓછી (10-35), ફ્રાન્સિસ માટે મીડિયમ (60-300), અને કપ્લાન માટે સૌથી વધુ N_s (300-1000) હોય છે. ડ્રાફ્ટ ટ્યુબ રિએક્શન ટર્બાઇનના એક્ઝિટ પર પ્રેશર હેડ વધારવા વપરાય છે.",
                "type": "specific_speed_turbines"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: લો હેડ અને હાઇ ડિસ્ચાર્જ માટે કયું ટર્બાઇન વપરાય છે? સાચો જવાબ: Kaplan Turbine! પ્રશ્ન ૨: ટર્બાઇનની Specific Speed નું સૂત્ર કયું છે? સાચો જવાબ: N_s = N * sqrt(P) / H^(5/4)! પ્રશ્ન ૩: પેલ્ટન વ્હીલ કયા પ્રકારનું ટર્બાઇન છે? સાચો જવાબ: Impulse Turbine!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "2.11",
        "name": "Centrifugal & Reciprocating Pumps",
        "filename": "centrifugal_and_reciprocating_pumps.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. સેન્ટ્રીફ્યુગલ પંપ અને પ્રાઇમિંગ (Centrifugal Pump & Priming)",
                "text": "સેન્ટ્રીફ્યુગલ પંપ ફોર્સ્ડ વર્ટેક્સ મોશન પર કામ કરે છે. તે પાણીને મધ્યમાંથી ખેંચીને બહાર ફેંકે છે. પંપ ચાલુ કરતા પહેલાં સક્શન પાઇપમાંથી હવા કાઢી પાણી ભરવાની ક્રિયાને પ્રાઇમિંગ કહેવાય છે! પ્રાઇમિંગ વગર પંપ ચાલુ કરવાથી કાઇનેટિક હેડ ઘટી જાય છે અને પાણી ચડતું નથી.",
                "type": "centrifugal_pump"
            },
            {
                "id": 2,
                "title": "૨. રેસિપ્રોકેટીંગ પંપ અને એર વેસેલ્સ (Reciprocating Pump & Air Vessels)",
                "text": "રેસિપ્રોકેટીંગ પંપ પોઝિટિવ ડિસ્પ્લેસમેન્ટ પંપ છે. તેમાં પિસ્ટન સિલિન્ડરમાં ખસે છે. સળંગ સતત પ્રવાહ મેળવવા અને ફ્રિક્શન લોસ ઘટાડવા સક્શન અને ડિલિવરી પાઇપ પર એર વેસેલ લગાડવામાં આવે છે! એર વેસેલ વાપરવાથી ૮૪.૮ ટકા જેટલી પાવર બચત થાય છે.",
                "type": "reciprocating_pump"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સેન્ટ્રીફ્યુગલ પંપ કયા સિદ્ધાંત પર કામ કરે છે? સાચો જવાબ: Forced Vortex Motion! પ્રશ્ન ૨: પંપમાં ચાલુ કરતા પહેલા હવા કાઢવાની પ્રક્રિયાને શું કહેવાય? સાચો જવાબ: Priming! પ્રશ્ન ૩: રેસિપ્રોકેટીંગ પંપમાં પ્રવાહ સતત મેળવવા શું વપરાય? સાચો જવાબ: Air Vessel!",
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

    temp_raw = f"assets/videos/temp_t2_up2_{sc['id']}.mp4"
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
        sc_data["audio_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up2_s{sc['id']}.mp3"
        sc_data["video_file"] = f"assets/videos/t{top['topic_num'].replace('.', '_')}_up2_v{sc['id']}.mp4"
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
