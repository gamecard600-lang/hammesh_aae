import os
import asyncio
import subprocess
import numpy as np
import cv2
from PIL import Image, ImageDraw, ImageFont
import edge_tts
from moviepy import VideoFileClip, AudioFileClip, concatenate_videoclips

# Font Configuration
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
        "title": "૧. પાવર પ્લાન્ટ સ્ટોરી – ઝીરોથ લૉ (Zeroth Law of Thermodynamics)",
        "text": "પાવર પ્લાન્ટમાં સ્ટીમ ટર્બાઇન બેરિંગનું તાપમાન માપતી વખતે જુનિયર એન્જિનિયર આરવે પૂછ્યું: 'સર, થર્મોમીટર પોતે ગરમ થઈને બેરિંગનું તાપમાન સાચું કેવી રીતે બતાવે?' સિનિયર મહેતા સાહેબે સમજાવ્યું: 'આરવ, આ જ છે થર્મોડાયનેમિક્સનો Zeroth Law! જો બે સિસ્ટમ A અને B કોઈ ત્રીજી સિસ્ટમ C એટલે કે થર્મોમીટર સાથે અલગ-અલગ થર્મલ સંતુલન એટલે કે Thermal Equilibrium માં હોય, તો તે બંને સિસ્ટમ A અને B પણ એકબીજા સાથે થર્મલ સંતુલનમાં જ હશે!'",
        "audio_file": "assets/videos/t1_2_scene_1.mp3",
        "video_file": "assets/videos/t1_2_std_scene_1.mp4",
        "type": "zeroth_law_intro"
    },
    {
        "id": 2,
        "title": "૨. તાપમાન માપનનો વિજ્ઞાનિક પાયો (Basis of Thermometry)",
        "audio_file": "assets/videos/t1_2_scene_2.mp3",
        "video_file": "assets/videos/t1_2_std_scene_2.mp4",
        "text": "પરીક્ષાનો સૌથી હાઈ-યીલ્ડ પ્રશ્ન: થર્મોડાયનેમિક્સનો કયો નિયમ તાપમાનના માપન એટલે કે Temperature Measurement માટેનો વિજ્ઞાનિક પાયો પૂરો પાડે છે? સાચો જવાબ છે: ઝીરોથ લૉ ઓફ થર્મોડાયનેમિક્સ! ઈસવીસન ૧૯૩૧ માં R. H. Fowler દ્વારા આ નિયમ ફર્સ્ટ લૉ અને સેકન્ડ લૉ પછી શોધાવા છતાં તેને Zeroth Law નામ આપવામાં આવ્યું, કારણ કે તે તાપમાનની મૂળભૂત વ્યાખ્યા દર્શાવે છે.",
        "type": "thermometry_basis"
    },
    {
        "id": 3,
        "title": "૩. થર્મોમીટર્સ અને તેની થર્મોમેટ્રિક પ્રોપર્ટીઝ (Thermometric Properties)",
        "audio_file": "assets/videos/t1_2_scene_3.mp3",
        "video_file": "assets/videos/t1_2_std_scene_3.mp4",
        "text": "તાપમાન માપવા માટે જુદા જુદા થર્મોમીટર્સમાં ચોક્કસ ગુણધર્મો વપરાય છે: ૧. લિક્વિડ-ઇન-ગ્લાસ થર્મોમીટરમાં મરક્યુરી કોલમની લંબાઈ L બદલાય છે. ૨. કોન્સ્ટન્ટ વોલ્યુમ ગેસ થર્મોમીટરમાં ગેસનું દબાણ P બદલાય છે. ૩. કોન્સ્ટન્ટ પ્રેશર ગેસ થર્મોમીટરમાં ગેસનું કદ V બદલાય છે. ૪. પ્લેટિનમ રેઝિસ્ટન્સ થર્મોમીટરમાં ઇલેક્ટ્રિકલ રેઝિસ્ટન્સ R બદલાય છે. ૫. થર્મોકપલમાં સિબેક ઇફેક્ટ દ્વારા ઇએમએફ એટલે કે વોલ્ટેજ E બદલાય છે. અને ૬. પાઇરોમીટર વડે ભઠ્ઠી કે સૂર્યનું ખૂબ ઊંચું તાપમાન થર્મલ રેડિયેશન દ્વારા માપવામાં આવે છે.",
        "type": "thermometer_types"
    },
    {
        "id": 4,
        "title": "૪. એબ્સોલ્યુટ ઝીરો ટેમ્પરેચર (Absolute Zero Temperature - 0 K)",
        "audio_file": "assets/videos/t1_2_scene_4.mp3",
        "video_file": "assets/videos/t1_2_std_scene_4.mp4",
        "text": "એબ્સોલ્યુટ ઝીરો ટેમ્પરેચર એટલે શૂન્ય કેલ્વિન અથવા માઇનસ ૨૭૩.૧૫ ડિગ્રી સેલ્સિયસ! આ તાપમાને પહોંચતાં જ વાયુના તમામ અણુઓની મોલેક્યુલર કાઇનેટિક એનર્જી શૂન્ય થઈ જાય છે અને તેમની આણ્વિક ગતિ સંપૂર્ણપણે અટકી જાય છે! પરીક્ષામાં અણુઓની કાઇનેટિક એનર્જી શૂન્ય થવાનો આ પ્રશ્ન વારંવાર પૂછાય છે.",
        "type": "absolute_zero"
    },
    {
        "id": 5,
        "title": "૫. વોટર નો ટ્રીપલ પોઈન્ટ (Triple Point of Water - 273.16 K)",
        "audio_file": "assets/videos/t1_2_scene_5.mp3",
        "video_file": "assets/videos/t1_2_std_scene_5.mp4",
        "text": "વોટરનો ટ્રીપલ પોઈન્ટ એટલે એવી ખાસ અવસ્થા જ્યાં બરફ એટલે કે સોલિડ, પાણી એટલે કે લિક્વિડ, અને વરાળ એટલે કે વરાળ ત્રણેય એકસાથે થર્મોડાયનેમિક સંતુલનમાં અસ્તિત્વ ધરાવે છે! તેનું તાપમાન છે ૨૭૩.૧૬ કેલ્વિન અથવા ૦.૦૧ ડિગ્રી સેલ્સિયસ, અને દબાણ છે ૦.૬૧૧૬૫ કિલોપાસ્કલ અથવા ૪.૫૮ મિલીમીટર ઓફ મરક્યુરી.",
        "type": "triple_point"
    },
    {
        "id": 6,
        "title": "૬. ટેમ્પરેચર સ્કેલ્સ અને કિલર એક્ઝામ ટ્રેપ (-40 deg C = -40 deg F)",
        "audio_file": "assets/videos/t1_2_scene_6.mp3",
        "video_file": "assets/videos/t1_2_std_scene_6.mp4",
        "text": "તાપમાન કન્વર્ઝનના મુખ્ય સૂત્રો: કેલ્વિન બરાબર ડિગ્રી સેલ્સિયસ વત્તા ૨૭૩.૧૫. સેલ્સિયસ અને ફેરનહીટ વચ્ચેનું સૂત્ર છે: C / 5 બરાબર F minus 32 / 9. હવે પરીક્ષાની સૌથી મોટી કિલર ટ્રેપ: કયા તાપમાને સેલ્સિયસ અને ફેરનહીટ બંને સ્કેલ એકસરખું રીડિંગ આપે? યાદ રાખી લો: માઇનસ ૪૦ ડિગ્રી! માઇનસ ૪૦ ડિગ્રી સેલ્સિયસ બરાબર માઇનસ ૪૦ ડિગ્રી ફેરનહીટ થાય છે!",
        "type": "temp_scales"
    },
    {
        "id": 7,
        "title": "૭. થર્ડ લૉ ઓફ થર્મોડાયનેમિક્સ (Third Law - Nernst Statement)",
        "audio_file": "assets/videos/t1_2_scene_7.mp3",
        "video_file": "assets/videos/t1_2_std_scene_7.mp4",
        "text": "થર્ડ લૉ ઓફ થર્મોડાયનેમિક્સ જણાવે છે કે: કોઈપણ પદ્ધતિ દ્વારા, ભલે તે ગમે તેટલી આદર્શ હોય, પરિમિત કામગીરીમાં એટલે કે Finite Operations માં કોઈપણ સિસ્ટમના તાપમાનને Absolute Zero શૂન્ય કેલ્વિન સુધી ઘટાડવું અશક્ય છે. શૂન્ય કેલ્વિન પર ક્રિસ્ટલાઇન પદાર્થની એન્ટ્રોપી પણ શૂન્ય થાય છે.",
        "type": "third_law"
    },
    {
        "id": 8,
        "title": "૮. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_2_scene_8.mp3",
        "video_file": "assets/videos/t1_2_std_scene_8.mp4",
        "text": "ચાલો હવે એપના વાસ્તવિક પ્રશ્નો ઉકેલીએ: પ્રશ્ન ૧: ટેમ્પરેચર માપન માટે કયો નિયમ વિજ્ઞાનિક પાયો પૂરો પાડે છે? સાચો જવાબ છે: ઝીરોથ લૉ. પ્રશ્ન ૨: એબ્સોલ્યુટ ઝીરો ટેમ્પરેચર પર વાયુની કઈ લાક્ષણિકતા જોવા મળે છે? સાચો જવાબ છે: અણુઓની કાઇનેટિક એનર્જી શૂન્ય થાય છે! અને પ્રશ્ન ૩: પરિમિત ઓપરેશનમાં સિસ્ટમના તાપમાનને Absolute Zero સુધી ઘટાડવું અશક્ય છે. આ કયો નિયમ છે? સાચો જવાબ છે: થર્ડ લૉ ઓફ થર્મોડાયનેમિક્સ!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/zeroth_law_and_temperature.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.2 Gujarati Audio Narration...")
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

    if stype == "zeroth_law_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "ZEROTH LAW OF THERMODYNAMICS (થર્મોડાયનેમિક્સનો ઝીરોથ લૉ)", font=f_large, fill=(255, 215, 0))

        # Thermal Equilibrium Diagram
        draw.rectangle([120, 220, 360, 380], fill=(40, 70, 110), outline=(255, 255, 255), width=3)
        draw.text((180, 280), "SYSTEM A\n (તાંબુ)", font=f_title, fill=(255, 255, 255))

        draw.rectangle([840, 220, 1080, 380], fill=(40, 70, 110), outline=(255, 255, 255), width=3)
        draw.text((900, 280), "SYSTEM B\n (સ્ટીલ)", font=f_title, fill=(255, 255, 255))

        pulse = int(4 * np.sin(t * 4))
        draw.rectangle([480 - pulse, 380 - pulse, 720 + pulse, 540 + pulse], fill=(120, 40, 40), outline=(0, 255, 255), width=3)
        draw.text((510, 430), "SYSTEM C\n(થર્મોમીટર)", font=f_title, fill=(255, 255, 255))

        draw.text((120, 580), "જો T_A = T_C અને T_B = T_C  ===>  તો T_A = T_B (Thermal Equilibrium!)", font=f_large, fill=(50, 255, 50))

    elif stype == "thermometry_basis":
        draw.rectangle([80, 130, 1200, 650], fill=(22, 32, 50), outline=(255, 215, 0), width=3)
        draw.text((160, 160), "SCIENTIFIC BASIS OF TEMPERATURE MEASUREMENT", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 230, 1160, 380], fill=(35, 25, 75), outline=(0, 255, 255), width=2)
        draw.text((150, 260), "💡 Zeroth Law provides scientific foundation for Thermometry!", font=f_title, fill=(50, 255, 50))
        draw.text((150, 315), "• ઝીરોથ લૉ તાપમાન માપન (Temperature Measurement) નો વિજ્ઞાનિક પાયો દર્શાવે છે.", font=f_body, fill=(255, 255, 255))

        draw.text((120, 430), "• Formulation Year: 1931 by R. H. Fowler", font=f_title, fill=(200, 255, 200))
        draw.text((120, 490), "• First & Second Law પછી શોધાયો છતાં તાપમાનની મૂળ વ્યાખ્યા હોવાથી 'Zeroth' કહેવાયો.", font=f_body, fill=(255, 255, 255))

    elif stype == "thermometer_types":
        draw.text((50, 85), "થર્મોમીટર્સ અને તેની થર્મોમેટ્રિક પ્રોપર્ટીઝ (Thermometric Properties)", font=f_title, fill=(255, 215, 0))

        draw.rectangle([50, 130, 1230, 660], fill=(20, 30, 45), outline=(0, 255, 255), width=2)
        draw.text((70, 150), "THERMOMETER TYPE                      THERMOMETRIC PROPERTY", font=f_title, fill=(0, 255, 255))
        draw.line([70, 190, 1210, 190], fill=(150, 150, 150), width=2)

        draw.text((70, 215), "૧. Liquid-in-glass (મરક્યુરી)", font=f_body, fill=(255, 255, 255))
        draw.text((600, 215), "Length of Fluid Column (L)", font=f_body, fill=(255, 215, 0))

        draw.text((70, 275), "૨. Constant Volume Gas Thermometer", font=f_body, fill=(255, 255, 255))
        draw.text((600, 275), "Gas Pressure (P)  [P proportional to T]", font=f_body, fill=(50, 255, 50))

        draw.text((70, 335), "૩. Constant Pressure Gas Thermometer", font=f_body, fill=(255, 255, 255))
        draw.text((600, 335), "Gas Volume (V)    [V proportional to T]", font=f_body, fill=(50, 255, 50))

        draw.text((70, 395), "૪. Resistance Thermometer (Platinum RTD)", font=f_body, fill=(255, 255, 255))
        draw.text((600, 395), "Electrical Resistance (R)", font=f_body, fill=(200, 255, 200))

        draw.text((70, 455), "૫. Thermocouple (Seebeck Effect)", font=f_body, fill=(255, 255, 255))
        draw.text((600, 455), "Electromotive Force / Voltage (EMF - E)", font=f_body, fill=(200, 255, 200))

        draw.text((70, 515), "૬. Optical / Radiation Pyrometer", font=f_body, fill=(255, 255, 255))
        draw.text((600, 515), "Thermal Radiation (High Temp Furnaces / Sun)", font=f_body, fill=(255, 100, 100))

    elif stype == "absolute_zero":
        draw.text((50, 85), "એબ્સોલ્યુટ ઝીરો ટેમ્પરેચર (Absolute Zero Temperature - 0 K)", font=f_large, fill=(0, 255, 255))

        draw.rectangle([180, 140, 1100, 300], fill=(40, 20, 60), outline=(255, 215, 0), width=3)
        draw.text((280, 180), "0 K = -273.15 deg C = -459.67 deg F", font=f_large, fill=(255, 255, 255))

        draw.rectangle([180, 340, 1100, 630], fill=(22, 35, 55), outline=(0, 255, 255), width=2)
        draw.text((210, 380), "🔥 HIGH YIELD EXAM CONCEPT:", font=f_title, fill=(255, 215, 0))
        draw.text((210, 440), "• Absolute Zero (0 K) પર ગેસના તમામ અણુઓની Kinetic Energy = 0 થાય છે!", font=f_title, fill=(50, 255, 50))
        draw.text((210, 500), "• આ તાપમાને વાયુના અણુઓની આણ્વિક ગતિ (Molecular Motion) સંપૂર્ણપણે બંધ થઈ જાય છે.", font=f_body, fill=(255, 255, 255))
        draw.text((210, 560), "• આદર્શ વાયુનું કદ (Volume) અને દબાણ (Pressure) પણ શૂન્ય ધારી લેવામાં આવે છે.", font=f_body, fill=(200, 255, 200))

    elif stype == "triple_point":
        draw.text((50, 85), "વોટર નો ટ્રીપલ પોઈન્ટ (Triple Point of Water - 273.16 K)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 640], fill=(20, 32, 50), outline=(0, 255, 255), width=3)
        draw.text((150, 170), "❄️ SOLID (બરફ)  +  💧 LIQUID (પાણી)  +  💨 GAS (વરાળ)", font=f_title, fill=(255, 255, 255))
        draw.text((150, 220), "ત્રણેય અવસ્થાઓ એકસાથે થર્મોડાયનેમિક સંતુલનમાં રહે છે!", font=f_body, fill=(200, 255, 200))

        draw.rectangle([180, 290, 1100, 450], fill=(35, 25, 75), outline=(255, 215, 0), width=2)
        draw.text((210, 320), "• Triple Point Temperature:  T = 273.16 K = 0.01 deg C", font=f_title, fill=(50, 255, 50))
        draw.text((210, 380), "• Triple Point Pressure:     P = 0.61165 kPa = 4.58 mm of Hg", font=f_title, fill=(0, 255, 255))

        draw.text((150, 490), "• ૧ કેલ્વિનની વ્યાખ્યા = ટ્રીપલ પોઈન્ટ તાપમાનનો 1 / 273.16 મો ભાગ.", font=f_body, fill=(255, 255, 255))
        draw.text((150, 550), "• કેલ્વિન સ્કેલ માટે ટ્રીપલ પોઈન્ટ નો ઉપયોગ Standard Fixed Reference Point તરીકે થાય છે.", font=f_body, fill=(255, 215, 0))

    elif stype == "temp_scales":
        draw.text((50, 85), "ટેમ્પરેચર સ્કેલ્સ અને કિલર એક્ઝામ ટ્રેપ (-40 deg C = -40 deg F)", font=f_large, fill=(0, 255, 255))

        draw.rectangle([100, 140, 1180, 330], fill=(25, 40, 60), outline=(0, 255, 255), width=2)
        draw.text((130, 170), "૧. T(Kelvin) = t(deg C) + 273.15", font=f_title, fill=(255, 255, 255))
        draw.text((130, 230), "૨. C / 5 = (F - 32) / 9    ===>  F = 1.8 * C + 32", font=f_title, fill=(255, 255, 255))

        # KILLER EXAM TRAP BOX
        draw.rectangle([100, 370, 1180, 640], fill=(50, 20, 20), outline=(255, 80, 80), width=4)
        draw.text((130, 400), "🔥 TOP GSSSB EXAM TRAP QUESTION:", font=f_title, fill=(255, 215, 0))
        draw.text((130, 460), "કયા તાપમાને Celsius અને Fahrenheit સ્કેલ એકસરખું રીડિંગ આપશે?", font=f_title, fill=(255, 255, 255))
        draw.text((130, 530), "✅ સાચો જવાબ: -40 deg C  (એટલે કે -40 deg C = -40 deg F)", font=f_large, fill=(50, 255, 50))

    elif stype == "third_law":
        draw.text((50, 85), "થર્ડ લૉ ઓફ થર્મોડાયનેમિક્સ (Third Law - Nernst Statement)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 640], fill=(22, 32, 50), outline=(255, 100, 100), width=3)
        draw.text((160, 180), "THIRD LAW STATEMENT:", font=f_large, fill=(255, 100, 100))

        draw.text((150, 260), "• કોઈપણ પદ્ધતિ દ્વારા, પરિમિત કામગીરીમાં (Finite Operations) સિસ્ટમના", font=f_title, fill=(255, 255, 255))
        draw.text((150, 310), "  તાપમાનને Absolute Zero (0 K) સુધી ઘટાડવું અશક્ય છે!", font=f_title, fill=(255, 100, 100))

        draw.text((150, 410), "• Absolute Zero (0 K) પર શુદ્ધ ક્રિસ્ટલાઇન પદાર્થની Entropy = 0 થાય છે.", font=f_title, fill=(50, 255, 50))
        draw.text((150, 480), "• Nernst Heat Theorem તરીકે પણ ઓળખાય છે.", font=f_body, fill=(200, 255, 200))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: તાપમાનના માપન માટે કયો નિયમ વિજ્ઞાનિક પાયો પૂરો પાડે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: ઝીરોથ લૉ ઓફ થર્મોડાયનેમિક્સ (Zeroth Law)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: Absolute Zero Temperature (0 K) પર ગેસની કઈ લાક્ષણિકતા જોવા મળે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: વાયુના અણુઓની Kinetic Energy શૂન્ય થાય છે!", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: પરિમિત ઓપરેશનમાં સિસ્ટમના તાપમાનને Absolute Zero સુધી ઘટાડવું અશક્ય છે. નિયમ?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. First Law (ઉર્જા સંરક્ષણ)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "❌ B. Second Law (એન્ટ્રોપી નિયમ)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 545), "✅ C. Third Law of Thermodynamics (સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.2 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_2_s{sc['id']}.mp4"
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(temp_raw, fourcc, fps, (width, height))

    for f in range(total_frames):
        t = f / fps
        frame = create_pil_frame(sc, t, width, height)
        out.write(frame)

    out.release()

    # Combine audio and video
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
    print("🎬 Merging all 8 Scenes for Topic 1.2 into Final Asset...")
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

    # Clean up scene video files
    for sc in SCENES:
        if os.path.exists(sc["video_file"]):
            os.remove(sc["video_file"])

    print(f"🎉 SUCCESS! Topic 1.2 Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
