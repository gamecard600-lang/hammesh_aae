import os
import asyncio
import subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import edge_tts
from moviepy import VideoFileClip, AudioFileClip, ImageClip, concatenate_videoclips

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

POWER_IC_TOPICS = [
    # --- SUBJECT 3: POWER ENGINEERING ---
    {
        "topic_num": "3.1",
        "name": "Air Compressors & Classification",
        "filename": "air_compressors.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. એર કોમ્પ્રેસરનો સિદ્ધાંત અને વર્ગીકરણ (Air Compressors)",
                "text": "એર કોમ્પ્રેસર એ હવાની દબાણ ઉર્જા વધારવા માટેનું સાધન છે. તેના બે મુખ્ય પ્રકારો છે: ૧. પોઝિટિવ ડિસ્પ્લેસમેન્ટ (રેસિપ્રોકેટીંગ અને રોટરી કોમ્પ્રેસર - રૂટ્સ બ્લોઅર, વેન, સ્ક્રૂ કોમ્પ્રેસર). ૨. ડાયનામિક કોમ્પ્રેસર (સેન્ટ્રીફ્યુગલ અને એક્સિયલ ફ્લો કોમ્પ્રેસર).",
                "type": "compressor_intro"
            },
            {
                "id": 2,
                "title": "૨. વર્ક ઇનપુટ અને વોલ્યુમેટ્રિક એફિશિયન્સી (Work & Volumetric Efficiency)",
                "text": "રેસિપ્રોકેટીંગ કોમ્પ્રેસરમાં આઇસોથર્મલ વર્ક સૌથી ઓછું હોય છે, તેથી આઇસોથર્મલ એફિશિયન્સી સૌથી વધુ ઇચ્છનીય છે! વોલ્યુમેટ્રિક એફિશિયન્સી eta_v બરાબર ૧ વત્તા C માઇનસ C ઇન બ્રેકેટ (P2 / P1)^(1/n) થાય છે, જ્યાં C એ ક્લિયરન્સ રેશિયો છે. પ્રેશર રેશિયો P2/P1 વધતાં વોલ્યુમેટ્રિક એફિશિયન્સી ઘટે છે!",
                "type": "volumetric_efficiency"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: કોમ્પ્રેસરમાં વર્ક ઇનપુટ ન્યૂનતમ રાખવા માટે કઈ પ્રોસેસ સૌથી આદર્શ છે? સાચો જવાબ: Isothermal Process! પ્રશ્ન ૨: ક્લિયરન્સ રેશિયો C વધતાં Volumetric Efficiency માં શો ફેરફાર થાય છે? સાચો જવાબ: Volumetric Efficiency ઘટે છે!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.2",
        "name": "Vapor Power Cycles (Rankine Cycle & Reheat)",
        "filename": "vapor_power_cycles.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. રેન્કિન સાયકલ અને સુધારાઓ (Rankine Cycle, Reheat & Regeneration)",
                "text": "સ્ટીમ પાવર પ્લાન્ટ રેન્કિન સાયકલ પર કામ કરે છે! તેમાં બોઇલર, સ્ટીમ ટર્બાઇન, કન્ડેન્સર અને ફીડ પંપ ૪ મુખ્ય ઘટકો છે. સ્ટીમ ટર્બાઇનના આઉટલેટ પર વેટનેસ ઓછી કરવા રીહીટીંગ કરવામાં આવે છે. અને થર્મલ એફિશિયન્સી વધારવા રીજનરેટીવ ફીડ વોટર હીટિંગ કરવામાં આવે છે!",
                "type": "rankine_cycle"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: થર્મલ પાવર પ્લાન્ટ કઈ સાયકલ પર કામ કરે છે? સાચો જવાબ: Rankine Cycle! પ્રશ્ન ૨: ટર્બાઇનમાં વરાળનું મોઇશ્ચર ઘટાડી ડ્રાઇનેસ ફ્રેક્શન વધારવા શું કરાય છે? સાચો જવાબ: Reheating!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "3.3",
        "name": "Gas Power Cycles (Brayton Cycle)",
        "filename": "gas_power_cycles.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. બ્રેટન સાયકલ અને ગેસ ટર્બાઇન (Brayton / Joule Cycle)",
                "text": "ગેસ ટર્બાઇન પાવર પ્લાન્ટ બ્રેટન સાયકલ પર કામ કરે છે! તેમાં બે આઇસેન્ટ્રોપિક અને બે અચળ દબાણ ઇસોબારિક પ્રોસેસ હોય છે. બ્રેટન સાયકલની એફિશિયન્સી eta બરાબર ૧ માઇનસ ૧ ભાગ્યા (r_p)^((gamma - 1)/gamma) થાય છે, જ્યાં r_p એ પ્રેશર રેશિયો છે.",
                "type": "brayton_cycle"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: ગેસ ટર્બાઇન પાવર પ્લાન્ટ કઈ આદર્શ સાયકલ પર કામ કરે છે? સાચો જવાબ: Brayton Cycle (Joule Cycle)!",
                "type": "mcq_elimination"
            }
        ]
    },

    # --- SUBJECT 4: I.C. ENGINES ---
    {
        "topic_num": "4.1",
        "name": "Air Standard Cycles (Otto, Diesel, Dual)",
        "filename": "air_standard_cycles.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ઓટો, ડીઝલ અને ડ્યુઅલ સાયકલ (Otto, Diesel & Dual Cycles)",
                "text": "૧. ઓટો સાયકલ: અચળ કદે (Constant Volume) કમ્બશ્ચન થાય છે, જે પેટ્રોલ એન્જિનમાં વપરાય છે. ૨. ડીઝલ સાયકલ: અચળ દબાણે (Constant Pressure) કમ્બશ્ચન થાય છે, જે ડીઝલ એન્જિનમાં વપરાય છે. ૩. ડ્યુઅલ સાયકલ: અંશતઃ અચળ કદ અને અંશતઃ અચળ દબાણે કમ્બશ્ચન થાય છે.",
                "type": "air_cycles"
            },
            {
                "id": 2,
                "title": "૨. એફિશિયન્સી સરખામણી અને કોમ્પ્રેસન રેશિયો (Compression Ratio r)",
                "text": "સમાન કોમ્પ્રેસન રેશિયો r અને હીટ ઇનપુટ માટે એફિશિયન્સી: ઓટો સાયકલ > ડ્યુઅલ સાયકલ > ડીઝલ સાયકલ! પરંતુ સમાન મહત્તમ દબાણ Peak Pressure માટે: ડીઝલ સાયકલ > ડ્યુઅલ સાયકલ > ઓટો સાયકલ! પેટ્રોલ એન્જિન માટે r = 6 થી 10 અને ડીઝલ એન્જિન માટે r = 14 થી 22 હોય છે.",
                "type": "cycle_comparison"
            },
            {
                "id": 3,
                "title": "૩. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: સમાન કમ્પ્રેશન રેશિયો r માટે કઈ સાયકલની એફિશિયન્સી સૌથી વધુ હોય છે? સાચો જવાબ: Otto Cycle! પ્રશ્ન ડીઝલ એન્જિનમાં કમ્પ્રેશન રેશિયો કેટલો હોય છે? સાચો જવાબ: 14 થી 22!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "4.2",
        "name": "Combustion Process & Knocking",
        "filename": "ic_engine_combustion_knocking.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. કમ્બશ્ચન અને નોકિંગ (Combustion, Knocking & Detonation)",
                "text": "પેટ્રોલ એન્જિન (SI) માં નોકિંગ સ્વયંસ્ફુરિત અનિયંત્રિત કમ્બશ્ચન ઓટો-ઇગ્નીશનને લીધે થાય છે. ડીઝલ એન્જિન (CI) માં નોકિંગ લાંબા ઇગ્નીશન ડીલે ignition delay ને લીધે થાય છે. પેટ્રોલ ઇંધણની નોકિંગ પ્રતિરોધક ક્ષમતા ઓક્ટેન નંબર વડે, અને ડીઝલની સિટેન નંબર વડે દર્શાવાય છે!",
                "type": "knocking_octane"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પેટ્રોલ ઇંધણની એન્ટી-નોક ક્વોલિટી કયા નંબર વડે દર્શાવાય છે? સાચો જવાબ: Octane Number! પ્રશ્ન ૨: ડીઝલ ઇંધણની ઇગ્નીશન ક્વોલિટી દર્શાવવા શું વપરાય છે? સાચો જવાબ: Cetane Number!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "4.3",
        "name": "Fuel Systems & CRDI",
        "filename": "fuel_systems_and_crdi.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. કાર્બ્યુરેટર, ફ્યુઅલ ઇન્જેક્ટર અને CRDI (Fuel Injection & CRDI)",
                "text": "પેટ્રોલ એન્જિનમાં હવા અને પેટ્રોલનું મિશ્રણ બનાવવાનું કામ કાર્બ્યુરેટર કરે છે. ડીઝલ એન્જિનમાં ફ્યુઅલ ઇન્જેક્શન પંપ અને ઇન્જેક્ટર દ્વારા હાઈ પ્રેશરે ડીઝલ સ્પ્રે થાય છે. આધુનિક ડીઝલ એન્જિનોમાં CRDI એટલે કે ક્રોસ રેલ ડાયરેક્ટ ઇન્જેક્શન ટેકનોલોજી વપરાય છે!",
                "type": "crdi_system"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: પેટ્રોલ એન્જિનમાં હવા અને ઇંધણનું મિશ્રણ કોણ બનાવે છે? સાચો જવાબ: Carburetor! પ્રશ્ન ૨: CRDI નો ફુલ ફોર્મ શું છે? સાચો જવાબ: Common Rail Direct Injection!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "4.4",
        "name": "Engine Systems & Emissions",
        "filename": "engine_systems_emissions.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. ઇગ્નીશન, લુબ્રિકેશન અને BS-VI એમિશન નોર્મ્સ (Engine Systems & Emissions)",
                "text": "પેટ્રોલ એન્જિનમાં સ્પાર્ક પ્લગ દ્વારા સ્પાર્ક ઇગ્નીશન થાય છે, જ્યારે ડીઝલ એન્જિનમાં કમ્પ્રેશન ઇગ્નીશન થાય છે. એમિશન કંટ્રોલ માટે કેટેલિટિક કન્વર્ટર અને EGR ઇગ્ઝોસ્ટ ગેસ રિસર્ક્યુલેશન વપરાય છે, જે નોક્સ વાયુઓનું પ્રમાણ ઘટાડે છે. ભારત ૬ BS-VI નોર્મ્સ પ્રદૂષણ અટકાવે છે.",
                "type": "emissions"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: ડીઝલ એન્જિનમાં ઇગ્નીશન કેવી રીતે થાય છે? સાચો જવાબ: Compression Ignition (ઉચ્ચ તાપમાને સ્વયંસ્ફુરિત)! પ્રશ્ન ૨: ઇગ્ઝોસ્ટમાં NOx વાયુઓનું પ્રમાણ ઘટાડવા શું વપરાય છે? સાચો જવાબ: EGR (Exhaust Gas Recirculation)!",
                "type": "mcq_elimination"
            }
        ]
    },
    {
        "topic_num": "4.5",
        "name": "Construction Equipment & Heavy Machinery",
        "filename": "construction_heavy_equipment.mp4",
        "scenes": [
            {
                "id": 1,
                "title": "૧. કન્સ્ટ્રક્શન મશીનરી (Excavators, Bulldozers, Cranes)",
                "text": "ભારે બાંધકામ અને અર્થમુવિંગ કામગીરી માટે ડીઝલ એન્જિન આધારિત હેવી મશીનરી વપરાય છે: ૧. બુલડોઝર: માટી ખસેડવા અને લેવલ કરવા. ૨. એકસ્કેવેટર: ઊંડો ખાડો ખોદવા. ૩. ગ્રેડર: રસ્તાની સપાટી સમતલ કરવા. ૪. સ્ક્રેપર: માટી ખોદીને ટ્રાન્સપોર્ટ કરવા.",
                "type": "heavy_machinery"
            },
            {
                "id": 2,
                "title": "૨. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
                "text": "પ્રશ્ન ૧: રસ્તાની સપાટી સમતલ અને ફિનિશ કરવા માટે કયું મશીન વપરાય છે? સાચો જવાબ: Motor Grader!",
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

    return np.array(img)

def render_scene(sc, audio_path, video_path):
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    # Fast ImageClip based rendering for MoviePy
    frame_np = create_pil_frame(sc, 0, 1280, 720)
    v_clip = ImageClip(frame_np).with_duration(duration)
    a_clip = AudioFileClip(audio_path)

    final = v_clip.with_audio(a_clip)
    final.write_videofile(
        video_path,
        codec="libx264",
        audio_codec="aac",
        fps=15,
        preset="ultrafast"
    )

    v_clip.close()
    a_clip.close()
    final.close()

    print(f"  ✅ Scene {sc['id']} Complete!")

def process_topic(top):
    print(f"\n=======================================================")
    print(f"🎬 PROCESSING TOPIC {top['topic_num']}: {top['name']}")
    print(f"=======================================================")

    scenes_list = []
    for sc in top["scenes"]:
        sc_data = sc.copy()
        sc_data["audio_file"] = f"assets/videos/pic_{top['topic_num'].replace('.', '_')}_s{sc['id']}.mp3"
        sc_data["video_file"] = f"assets/videos/pic_{top['topic_num'].replace('.', '_')}_v{sc['id']}.mp4"
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
    for top in POWER_IC_TOPICS:
        process_topic(top)
