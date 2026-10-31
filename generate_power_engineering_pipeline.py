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

POWER_TOPICS = [
    {
        "topic_num": "3.1",
        "name": "Air Compressors",
        "filename": "air_compressors.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. પાવર પ્લાન્ટ સ્ટોરી – એર કોમ્પ્રેસરનો પરિચય (Reciprocating Air Compressor)",
                "text": "ગેરેજ અને ફેક્ટરીમાં ન્યુમેટિક ટૂલ્સ ચલાવવા માટે ઊંચા દબાણવાળી હવાની જરૂર પડે છે! રેસિપ્રોકેટીંગ એર કોમ્પ્રેસરમાં પિસ્ટન સિલિન્ડરમાં ખસે છે. સક્શન સ્ટ્રોક દરમિયાન હવા અંદર આવે છે, કમ્પ્રેશન સ્ટ્રોકમાં દબાણ અને તાપમાન વધે છે, અને ડિસ્ચાર્જ વાલ્વમાંથી હાઇ પ્રેશર એર બહાર નીકળે છે.",
                "type": "compressor_intro"
            },
            {
                "id": 2,
                "title": "૨. P-V ડાયાગ્રામ અને વૉર્ક ડન સૂત્ર (P-V Diagram & Work Done)",
                "text": "કોમ્પ્રેસર માટે P-V ડાયાગ્રામ પર વર્ક ઇનપુટ W નો મોટો ભાગ રોકાય છે. પોલિટ્રોપિક કમ્પ્રેશન માટે વર્કનું સૂત્ર છે: W = (n / (n-1)) * P1 * V1 * [(P2/P1)^((n-1)/n) - 1]. આઇસોથર્મલ કમ્પ્રેશન (n = 1) માં સૌથી ઓછું વર્ક ઇનપુટ જોઈએ છે!",
                "type": "pv_diagram_work"
            },
            {
                "id": 3,
                "title": "૩. આઇસોથર્મલ એફિશિયન્સી અને મલ્ટીસ્ટેજ કમ્પ્રેશન (Isothermal Efficiency & Intercooling)",
                "text": "આઇસોથર્મલ એફિશિયન્સી બરાબર આઇસોથર્મલ વર્ક ભાગ્યા એક્ચ્યુઅલ ઇન્ડિકેટેડ વર્ક થાય છે. મલ્ટીસ્ટેજ કમ્પ્રેશનમાં બે સ્ટેજ વચ્ચે ઇન્ટરકૂલર મૂકી હવા ઠંડી કરવામાં આવે છે, જેનાથી વર્ક ઇનપુટ ઘટે છે! પરફેક્ટ ઇન્ટરકૂલિંગ માટે ઇન્ટરમીડિયેટ પ્રેશર P_x બરાબર અંડરરૂટ P1 ગુણ્યા P2 થાય છે!",
                "type": "intercooling"
            },
            {
                "id": 4,
                "title": "૪. વોલ્યુમેટ્રિક એફિશિયન્સી સૂત્ર (Volumetric Efficiency eta_v)",
                "text": "ક્લિયરન્સ વોલ્યુમ V_c ને લીધે કોમ્પ્રેસરની વોલ્યુમેટ્રિક એફિશિયન્સી ઘટે છે! સૂત્ર: eta_v = 1 + C - C * (P2/P1)^(1/n). જ્યાં C એ ક્લિયરન્સ રેશિયો V_c / V_s છે. પ્રેશર રેશિયો P2/P1 વધતાં વોલ્યુમેટ્રિક એફિશિયન્સી ઘટે છે!",
                "type": "volumetric_eff"
            },
            {
                "id": 5,
                "title": "૫. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: એર કોમ્પ્રેસરમાં લઘુત્તમ વર્ક ઇનપુટ કઈ પ્રોસેસમાં જોઈએ? સાચો જવાબ: Isothermal Process! પ્રશ્ન ૨: બે સ્ટેજ કમ્પ્રેશનમાં પરફેક્ટ ઇન્ટરકૂલિંગ માટે ઇન્ટરમીડિયેટ પ્રેશર P_x કેટલું હોવું જોઈએ? સાચો જવાબ: P_x = sqrt(P1 * P2)! પ્રશ્ન ૩: પ્રેશર રેશિયો વધતાં Volumetric Efficiency માં શો ફેરફાર થાય છે? સાચો જવાબ: Volumetric Efficiency ઘટે છે!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.2",
        "name": "Vapor Power Cycles",
        "filename": "vapor_power_cycles.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. થર્મલ પાવર પ્લાન્ટ અને રેન્કિન સાયકલ (Rankine Cycle)",
                "text": "થર્મલ પાવર પ્લાન્ટમાં વરાળ દ્વારા વીજળી ઉત્પન્ન કરવા માટે રેન્કિન સાયકલ વપરાય છે! તેના ૪ મુખ્ય ઘટકો છે: ૧. બોઇલર (અચળ દબાણે ઉષ્મા ઉમેરો), ૨. સ્ટીમ ટર્બાઇન (આઇસેન્ટ્રોપિક વિસ્તરણ અને વર્ક આઉટપુટ), ૩. કન્ડેન્સર (અચળ દબાણે ઉષ્મા બહાર ફેંકવી), અને ૪. ફીડ પમ્પ (આઇસેન્ટ્રોપિક પમ્પિંગ).",
                "type": "rankine_intro"
            },
            {
                "id": 2,
                "title": "૨. T-s અને P-v ડાયાગ્રામ પર રેન્કિન એફિશિયન્સી (Rankine Efficiency Formula)",
                "text": "રેન્કિન સાયકલ એફિશિયન્સી eta_Rankine = (W_turbine - W_pump) / Q_in = (h1 - h2) / (h1 - h4) થાય છે. સ્ટીમ સુપરહીટ કરવાથી રેન્કિન એફિશિયન્સી અને વર્ક આઉટપુટ બંને વધે છે, તથા ટર્બાઇન એક્ઝિટ પર સ્ટીમની ડ્રાયનેસ ફ્રેક્શન પણ વધે છે!",
                "type": "rankine_ts_diagram"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: રેન્કિન સાયકલમાં આઇસેન્ટ્રોપિક વિસ્તરણ કયા ઘટકમાં થાય છે? સાચો જવાબ: Steam Turbine! પ્રશ્ન ૨: સ્ટીમ સુપરહીટ કરવાથી Rankine Efficiency પર શું અસર થાય છે? સાચો જવાબ: Efficiency વધે છે!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.3",
        "name": "Regeneration",
        "filename": "regeneration.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. રિજનરેટિવ ફીડવોટર હીટીંગ (Regenerative Feedwater Heating)",
                "text": "રેન્કિન સાયકલમાં ટર્બાઇનમાંથી થોડી વરાળ બ્લીડ કરીને બહાર કાઢી ફીડવોટર ગરમ કરવામાં આવે છે, જેને રિજનરેશન કહેવાય છે. આનાથી મીન ટેમ્પરેચર ઓફ હીટ એડિશન T_m1 વધે છે, જેના લીધે સાયકલ એફિશિયન્સી વધે છે અને કન્ડેન્સર લોસ ઘટે છે!",
                "type": "regeneration_intro"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: રેન્કિન સાયકલમાં Regeneration કરવાથી Efficiency પર શો ફેરફાર થાય છે? સાચો જવાબ: Efficiency વધે છે (T_m1 વધવાને લીધે)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.4",
        "name": "Compressor Classification",
        "filename": "compressor_classification.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. પોઝિટિવ ડિસ્પ્લેસમેન્ટ વિ. ડાયનામિક કોમ્પ્રેસર (Compressor Types)",
                "text": "કોમ્પ્રેસરના ૨ વર્ગો: ૧. પોઝિટિવ ડિસ્પ્લેસમેન્ટ: રેસિપ્રોકેટીંગ, રૂટ્સ બ્લોઅર, વેન કોમ્પ્રેસર (હાઇ પ્રેશર, લો માસ ફ્લો રેટ). ૨. ડાયનામિક કોમ્પ્રેસર: સેન્ટ્રીફ્યુગલ અને એક્સિયલ ફ્લો કોમ્પ્રેસર (હાઇ માસ ફ્લો રેટ, લો પ્રેશર રેશિયો per stage).",
                "type": "comp_class"
            },
            {
                "id": 2,
                "title": "૨. સેન્ટ્રીફ્યુગલ વિ. એક્સિયલ ફ્લો કોમ્પ્રેસર (Centrifugal vs Axial Flow)",
                "text": "એરક્રાફ્ટ જેટ એન્જિનમાં એક્સિયલ ફ્લો કોમ્પ્રેસર વપરાય છે કારણ કે તેમાં હવા અક્ષિય દિશામાં સળંગ વહે છે. સેન્ટ્રીફ્યુગલ કોમ્પ્રેસરમાં રેડિયલ ફ્લો થાય છે. સર્જિંગ અને ચોકિંગ એ સેન્ટ્રીફ્યુગલ કોમ્પ્રેસરની અસ્થિરતા અનસ્ટેબિલીટી દર્શાવતી ઘટનાઓ છે!",
                "type": "centrifugal_axial"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: એરક્રાફ્ટ જેટ એન્જિનમાં કયું કોમ્પ્રેસર વપરાય છે? સાચો જવાબ: Axial Flow Compressor! પ્રશ્ન ૨: Surging અને Choking ની ઘટના કયા કોમ્પ્રેસરમાં જોવા મળે છે? સાચો જવાબ: Centrifugal Compressor!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.5",
        "name": "Gas Compressors",
        "filename": "gas_compressors.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. કમ્પ્રેશન પ્રોસેસ સરખામણી (Isothermal, Polytropic, Isentropic)",
                "text": "P-V ડાયાગ્રામ પર કમ્પ્રેશન લાઇનો: ૧. આઇસોથર્મલ પ્રોસેસ PV = C (n = 1) સૌથી ઓછું વર્ક લે છે. ૨. પોલિટ્રોપિક પ્રોસેસ PV^n = C. ૩. આઇસેન્ટ્રોપિક પ્રોસેસ PV^gamma = C (gamma = 1.4) સૌથી વધુ વર્ક ઇનપુટ લે છે. તેથી આઇસોથર્મલ પ્રોસેસ સૌથી વધુ આદર્શ ગણાય છે!",
                "type": "gas_comp_processes"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: કઈ કમ્પ્રેશન પ્રોસેસમાં લઘુત્તમ વર્ક ઇનપુટની જરૂર પડે છે? સાચો જવાબ: Isothermal Process!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.6",
        "name": "Gas Power Cycles",
        "filename": "gas_power_cycles.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ઓટ્ટો સાયકલ અને ડિઝલ સાયકલ (Otto & Diesel Cycle)",
                "text": "૧. ઓટ્ટો સાયકલ (પેટ્રોલ એન્જિન): ૨ આઇસેન્ટ્રોપિક + ૨ કોન્સ્ટન્ટ વોલ્યુમ પ્રોસેસ. એફિશિયન્સી eta_Otto = 1 - 1 / r^(gamma-1). ૨. ડિઝલ સાયકલ (ડિઝલ એન્જિન): ૨ આઇસેન્ટ્રોપિક + ૧ કોન્સ્ટન્ટ પ્રેશર હીટ એડિશન + ૧ કોન્સ્ટન્ટ વોલ્યુમ હીટ રિજેક્શન!",
                "type": "otto_diesel"
            },
            {
                "id": 2,
                "title": "૨. બ્રેટન સાયકલ અને એર સ્ટાન્ડર્ડ સરખામણી (Brayton Cycle & Comparison)",
                "text": "બ્રેટન સાયકલ એ ગેસ ટર્બાઇન પ્લાન્ટ માટે વપરાય છે. તેમાં ૨ આઇસેન્ટ્રોપિક અને ૨ અચળ દબાણ કોન્સ્ટન્ટ પ્રેશર પ્રોસેસ હોય છે. સમાન કમ્પ્રેશન રેશિયો r અને હીટ ઇનપુટ માટે એફિશિયન્સી ક્રમ: eta_Otto > eta_Dual > eta_Diesel!",
                "type": "brayton_comparison"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પેટ્રોલ એન્જિન કઈ સાયકલ પર કામ કરે છે? સાચો જવાબ: Otto Cycle! પ્રશ્ન ૨: ગેસ ટર્બાઇન કઈ સાયકલ પર કામ કરે છે? સાચો જવાબ: Brayton Cycle! પ્રશ્ન ૩: સમાન કમ્પ્રેશન રેશિયો માટે કઈ સાયકલની એફિશિયન્સી સૌથી વધુ હોય? સાચો જવાબ: Otto Cycle!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.7",
        "name": "Reheat",
        "filename": "reheat.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. રીહીટ સાયકલનો સિદ્ધાંત અને ફાયદા (Reheat Rankine Cycle)",
                "text": "રીહીટ સાયકલમાં હાઇ પ્રેશર ટર્બાઇનમાંથી નીકળતી વરાળને ફરી બોઇલરમાં મોકલી ગરમ કરીને લો પ્રેશર ટર્બાઇનમાં મોકલવામાં આવે છે. રીહીટ કરવાથી ટર્બાઇનનું વર્ક આઉટપુટ W_net વધે છે અને એક્ઝોસ્ટ સ્ટીમની ડ્રાયનેસ ફ્રેક્શન chi વધે છે, જેથી બ્લેડનું ઇરોઝન અટકે છે!",
                "type": "reheat_intro"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સ્ટીમ પાવર પ્લાન્ટમાં Reheating કરવાનો મુખ્ય ફાયદાત્મક હેતુ કયો છે? સાચો જવાબ: Exhaust Steam ની Dryness Fraction વધારવી અને Blade Erosion અટકાવવું!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.8",
        "name": "Thermal Efficiency Concepts",
        "filename": "thermal_efficiency_concepts.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. પાવર પ્લાન્ટ એફિશિયન્સી ઓવરઓલ ગણતરી (Overall Thermal Efficiency)",
                "text": "ઓવરઓલ એફિશિયન્સી eta_overall બરાબર બોઇલર એફિશિયન્સી ગુણ્યા થર્મલ એફિશિયન્સી ગુણ્યા મિકેનિકલ એફિશિયન્સી ગુણ્યા જનરેટર એફિશિયન્સી થાય છે! હીટ રેટ (Heat Rate) = 3600 / eta_overall (kJ/kWh) થાય છે.",
                "type": "thermal_eff_concepts"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પાવર પ્લાન્ટની Overall Efficiency નું સૂત્ર કયું છે? સાચો જવાબ: eta_overall = eta_boiler * eta_thermal * eta_mechanical * eta_generator!",
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

    temp_raw = f"assets/videos/temp_t3_s{sc['id']}.mp4"
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
    for top in POWER_TOPICS:
        process_topic(top)
