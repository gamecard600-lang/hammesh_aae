import os
import asyncio
import numpy as np
import cv2
from PIL import Image, ImageDraw, ImageFont
from moviepy import VideoFileClip, AudioFileClip, concatenate_videoclips

# 1. High-Resolution Gujarati Font Path
FONT_PATH = "C:/Windows/Fonts/Nirmala.ttc"

def get_font(size):
    try:
        return ImageFont.truetype(FONT_PATH, size)
    except Exception:
        return ImageFont.load_default()

SCENES = [
    {
        "id": 1,
        "title": "૧. પાવર પ્લાન્ટની મુલાકાત: સિસ્ટમ, સરાઉન્ડિંગ્સ & બાઉન્ડ્રી",
        "audio_file": "assets/videos/master_scene_1.mp3",
        "video_file": "assets/videos/std_scene_1.mp4",
        "type": "story_intro"
    },
    {
        "id": 2,
        "title": "૨. બાઉન્ડ્રીના ૪ પ્રકારો (Boundary Classification)",
        "audio_file": "assets/videos/master_scene_2.mp3",
        "video_file": "assets/videos/std_scene_2.mp4",
        "type": "boundary_types"
    },
    {
        "id": 3,
        "title": "૩. મેક્રોસ્કોપિક વિ. માઈક્રોસ્કોપિક અભિગમ",
        "audio_file": "assets/videos/master_scene_3.mp3",
        "video_file": "assets/videos/std_scene_3.mp4",
        "type": "approaches"
    },
    {
        "id": 4,
        "title": "૪. ૩ સિસ્ટમ્સની વાર્તા: કૂકર, ટર્બાઇન અને થર્મોસ",
        "audio_file": "assets/videos/master_scene_4.mp3",
        "video_file": "assets/videos/std_scene_4.mp4",
        "type": "systems_story"
    },
    {
        "id": 5,
        "title": "૫. કંટ્રોલ વોલ્યુમ અને માસ ફ્લો રેટનું સૂત્ર (m_dot = rho*A*V)",
        "audio_file": "assets/videos/master_scene_5.mp3",
        "video_file": "assets/videos/std_scene_5.mp4",
        "type": "formula_m_dot"
    },
    {
        "id": 6,
        "title": "૬. હોમોજીનિયસ વિ. હેટરોજીનિયસ સિસ્ટમ (Phases)",
        "audio_file": "assets/videos/master_scene_6.mp3",
        "video_file": "assets/videos/std_scene_6.mp4",
        "type": "phases"
    },
    {
        "id": 7,
        "title": "૭. પરીક્ષામાં થતી ગૂંચવણો (Exam Traps)",
        "audio_file": "assets/videos/master_scene_7.mp3",
        "video_file": "assets/videos/std_scene_7.mp4",
        "type": "exam_traps"
    },
    {
        "id": 8,
        "title": "૮. MCQ એલિમિનેશન મેથડ (Option Elimination)",
        "audio_file": "assets/videos/master_scene_8.mp3",
        "video_file": "assets/videos/std_scene_8.mp4",
        "type": "mcq_elimination"
    }
]

FINAL_OUTPUT = "assets/videos/thermodynamic_systems.mp4"

def get_audio_duration(path):
    clip = AudioFileClip(path)
    dur = clip.duration
    clip.close()
    return dur

def create_pil_frame(scene_data, t, width=1280, height=720):
    # Dark Slate Engineering Background
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

    if stype == "story_intro":
        # Thermal Power Plant Scene Illustration
        draw.rectangle([100, 200, 320, 520], fill=(45, 55, 75), outline=(100, 120, 150), width=3)
        draw.polygon([(100, 200), (210, 130), (320, 200)], fill=(70, 85, 110))
        # Chimney with animated smoke
        draw.rectangle([250, 100, 290, 200], fill=(60, 70, 90))
        for s in range(3):
            sy = int(80 - s * 25 - (t * 30) % 30)
            sx = int(270 + np.sin(t * 3 + s) * 15)
            draw.ellipse([sx - 12, sy - 12, sx + 12, sy + 12], fill=(180, 180, 180))

        # Boiler with Fire Flame Illustration (The System)
        pulse = int(5 * np.sin(t * 4))
        draw.rectangle([450 - pulse, 220 - pulse, 850 + pulse, 480 + pulse], fill=(35, 65, 105), outline=(0, 255, 255), width=4)
        draw.rectangle([430 - pulse, 200 - pulse, 870 + pulse, 500 + pulse], outline=(255, 80, 80), width=2)
        draw.text((470, 250), "BOILER (બોઇલર)", font=f_large, fill=(255, 255, 255))
        draw.text((490, 310), "🔥 THERMODYNAMIC SYSTEM", font=f_title, fill=(255, 215, 0))
        draw.text((480, 360), "(અભ્યાસ માટે પસંદ કરેલો વિસ્તાર)", font=f_body, fill=(200, 255, 200))

        # Engineer Mehta & Junior Aarav Avatars
        draw.ellipse([980, 240, 1060, 320], fill=(220, 180, 140)) # Head
        draw.rectangle([960, 320, 1080, 480], fill=(40, 90, 180)) # Body
        draw.text((950, 490), "મહેતા સાહેબ (Senior)", font=f_body, fill=(0, 255, 255))

        draw.ellipse([880, 270, 940, 330], fill=(230, 190, 150)) # Head
        draw.rectangle([865, 330, 955, 480], fill=(50, 140, 80)) # Body
        draw.text((860, 490), "આરવ (Junior)", font=f_body, fill=(200, 255, 200))

        draw.text((150, 560), "SURROUNDINGS: બોઇલર સિવાયનો આખો પાવર પ્લાન્ટ વિસ્તાર", font=f_body, fill=(180, 180, 180))
        draw.text((260, 640), "UNIVERSE (બ્રહ્માંડ) = SYSTEM + SURROUNDINGS", font=f_large, fill=(255, 215, 0))

    elif stype == "boundary_types":
        draw.text((50, 85), "બાઉન્ડ્રીના ૪ મુખ્ય પ્રકારો (Boundary Classification)", font=f_title, fill=(255, 215, 0))

        draw.rectangle([50, 130, 610, 380], fill=(28, 38, 55), outline=(0, 255, 255), width=2)
        draw.text((70, 150), "૧. Fixed vs Movable Boundary", font=f_body, fill=(0, 255, 255))
        draw.rectangle([100, 200, 300, 340], outline=(255, 255, 255), width=3)
        px = int(220 + 20 * np.sin(t * 3))
        draw.rectangle([px, 204, px + 20, 336], fill=(180, 100, 50))
        draw.text((330, 220), "• Cylinder Walls = Fixed", font=f_body, fill=(200, 255, 200))
        draw.text((330, 270), "• Moving Piston = Movable", font=f_body, fill=(255, 215, 0))

        draw.rectangle([650, 130, 1210, 380], fill=(28, 38, 55), outline=(0, 255, 255), width=2)
        draw.text((670, 150), "૨. Real vs Imaginary Boundary", font=f_body, fill=(0, 255, 255))
        draw.line([700, 230, 950, 230], fill=(200, 200, 200), width=4)
        draw.line([700, 310, 950, 310], fill=(200, 200, 200), width=4)
        draw.line([700, 230, 700, 310], fill=(255, 80, 80), width=2)
        draw.text((980, 220), "• Pipe Metal Wall = Real", font=f_body, fill=(200, 255, 200))
        draw.text((980, 270), "• Pipe Inlet/Outlet = Imaginary", font=f_body, fill=(255, 215, 0))

        draw.rectangle([50, 410, 610, 660], fill=(28, 38, 55), outline=(0, 255, 255), width=2)
        draw.text((70, 430), "૩. Diathermic Boundary (Heat Conductor)", font=f_body, fill=(0, 255, 255))
        draw.text((70, 480), "• ઉષ્મા પસાર થવા દે છે (Q != 0)", font=f_title, fill=(50, 255, 50))
        draw.text((70, 540), "• ઉદાહરણ: તાંબા કે લોખંડનું પાત્ર", font=f_body, fill=(255, 255, 255))

        draw.rectangle([650, 410, 1210, 660], fill=(28, 38, 55), outline=(0, 255, 255), width=2)
        draw.text((670, 430), "૪. Adiabatic Boundary (Thermal Insulator)", font=f_body, fill=(0, 255, 255))
        draw.text((670, 480), "• સંપૂર્ણ અવાહક - ઉષ્મા રોકાઈ જાય (Q = 0)", font=f_title, fill=(255, 100, 100))
        draw.text((670, 540), "• ઉદાહરણ: ઇન્સ્યુલેટેડ થર્મોસ દીવાલ", font=f_body, fill=(255, 255, 255))

    elif stype == "approaches":
        draw.text((50, 85), "થર્મોડાયનેમિક્સના ૨ મુખ્ય અભિગમો (Macroscopic vs Microscopic)", font=f_title, fill=(255, 215, 0))

        draw.rectangle([50, 130, 610, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((70, 160), "1. MACROSCOPIC APPROACH", font=f_title, fill=(0, 255, 255))
        draw.text((70, 205), "(Classical Thermodynamics)", font=f_body, fill=(200, 255, 200))

        draw.ellipse([180, 260, 320, 400], outline=(255, 215, 0), width=4)
        needle_angle = np.sin(t * 3) * 0.8
        nx = int(250 + 50 * np.cos(needle_angle - np.pi/2))
        ny = int(330 + 50 * np.sin(needle_angle - np.pi/2))
        draw.line([250, 330, nx, ny], fill=(255, 50, 50), width=3)
        draw.text((150, 410), "P = 2.5 bar, T = 150°C, V = 0.08 m³", font=f_body, fill=(255, 255, 255))
        draw.text((70, 470), "• કરોડો અણુઓની સરેરાશ અસરનો અભ્યાસ", font=f_body, fill=(255, 255, 255))
        draw.text((70, 520), "• દબાણ, તાપમાન ડાયરેક્ટ માપી શકાય", font=f_body, fill=(255, 255, 255))
        draw.text((70, 570), "• એન્જિનિયરિંગમાં ૧૦૦% આ જ વપરાય છે", font=f_body, fill=(255, 215, 0))

        draw.rectangle([650, 130, 1210, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((670, 160), "2. MICROSCOPIC APPROACH", font=f_title, fill=(0, 255, 255))
        draw.text((670, 205), "(Statistical Thermodynamics)", font=f_body, fill=(200, 255, 200))

        draw.ellipse([830, 260, 1030, 460], fill=(10, 20, 35), outline=(0, 255, 255), width=3)
        for i in range(16):
            mx = int(930 + 70 * np.cos(i + t * 4))
            my = int(360 + 70 * np.sin(i * 1.5 + t * 3))
            draw.ellipse([mx - 6, my - 6, mx + 6, my + 6], fill=(255, 200, 50))

        draw.text((670, 480), "• દરેક અણુની ગતિ અને ઉર્જાની ગણતરી", font=f_body, fill=(255, 255, 255))
        draw.text((670, 530), "• ઉચ્ચ શૂન્યાવકાશ (High Vacuum) માં વપરાય", font=f_body, fill=(255, 255, 255))
        draw.text((670, 580), "• ઓછી ઘનતાવાળા વાયુઓ માટે ઉપયોગી", font=f_body, fill=(255, 215, 0))

    elif stype == "systems_story":
        draw.text((50, 85), "૩ મુખ્ય થર્મોડાયનેમિક સિસ્ટમ્સ (3 System Types Comparison)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([50, 130, 410, 660], fill=(28, 42, 60), outline=(0, 255, 255), width=2)
        draw.text((70, 155), "૧. CLOSED SYSTEM", font=f_title, fill=(0, 255, 255))
        draw.text((70, 195), "(Control Mass)", font=f_body, fill=(200, 255, 200))
        draw.text((70, 250), "🔒 Mass = Constant (0)", font=f_body, fill=(255, 100, 100))
        draw.text((70, 300), "⚡ Heat & Work = YES", font=f_body, fill=(50, 255, 50))
        draw.text((70, 370), "જીવંત ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((70, 420), "• વાલ્વ વગરનું પિસ્ટન", font=f_body, fill=(255, 255, 255))
        draw.text((70, 470), "• બોમ્બ કેલોરીમીટર", font=f_body, fill=(255, 255, 255))
        draw.text((70, 520), "• બંધ પ્રેશર કૂકર", font=f_body, fill=(255, 255, 255))
        draw.text((70, 570), "• કારની સીલબંધ બેટરી", font=f_body, fill=(255, 255, 255))

        draw.rectangle([440, 130, 800, 660], fill=(28, 42, 60), outline=(0, 255, 255), width=2)
        draw.text((460, 155), "૨. OPEN SYSTEM", font=f_title, fill=(0, 255, 255))
        draw.text((460, 195), "(Control Volume)", font=f_body, fill=(200, 255, 200))
        draw.text((460, 250), "🌊 Mass = Flow (YES)", font=f_body, fill=(50, 255, 50))
        draw.text((460, 300), "⚡ Heat & Work = YES", font=f_body, fill=(50, 255, 50))
        draw.text((460, 370), "જીવંત ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((460, 420), "• સ્ટીમ ટર્બાઇન, બોઇલર", font=f_body, fill=(255, 255, 255))
        draw.text((460, 470), "• એર કોમ્પ્રેસર, પંપ", font=f_body, fill=(255, 255, 255))
        draw.text((460, 520), "• નોઝલ, ડિફ્યુઝર", font=f_body, fill=(255, 255, 255))
        draw.text((460, 570), "• વાલ્વ સાથેનું IC એન્જિન", font=f_body, fill=(255, 255, 255))

        draw.rectangle([830, 130, 1190, 660], fill=(28, 42, 60), outline=(0, 255, 255), width=2)
        draw.text((850, 155), "૩. ISOLATED SYSTEM", font=f_title, fill=(0, 255, 255))
        draw.text((850, 195), "(Ideal System)", font=f_body, fill=(200, 255, 200))
        draw.text((850, 250), "❌ Mass = Blocked (0)", font=f_body, fill=(255, 100, 100))
        draw.text((850, 300), "❌ Energy = Blocked (0)", font=f_body, fill=(255, 100, 100))
        draw.text((850, 370), "જીવંત ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((850, 420), "• ઇન્સ્યુલેટેડ થર્મોસ ફ્લાસ્ક", font=f_body, fill=(255, 255, 255))
        draw.text((850, 470), "• આપણું સમગ્ર Universe", font=f_body, fill=(255, 215, 0))

    elif stype == "formula_m_dot":
        draw.text((50, 85), "કંટ્રોલ વોલ્યુમ અને માસ ફ્લો રેટનું સૂત્ર (Mass Flow Rate Formula)", font=f_large, fill=(0, 255, 255))

        draw.rectangle([220, 140, 1020, 280], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((320, 180), "m_dot = rho * A * V", font=f_large, fill=(255, 255, 255))

        draw.text((260, 310), "• m_dot = માસ ફ્લો રેટ (દર સેકન્ડે દળનો પ્રવાહ) [SI એકમ: kg/s]", font=f_title, fill=(50, 255, 50))
        draw.text((260, 370), "• rho = ફ્લુઇડની ઘનતા (Density) [SI એકમ: kg/m³]", font=f_body, fill=(200, 255, 200))
        draw.text((260, 420), "• A = પાઇપ/નોઝલનું ક્ષેત્રફળ (Area) [SI એકમ: m²]", font=f_body, fill=(200, 255, 200))
        draw.text((260, 470), "• V = પ્રવાહનો વેગ (Velocity) [SI એકમ: m/s]", font=f_body, fill=(200, 255, 200))

        draw.rectangle([220, 530, 1020, 650], fill=(25, 45, 65), outline=(0, 255, 255), width=2)
        draw.text((240, 560), "💡 Control Surface = કંટ્રોલ વોલ્યુમની કાલ્પનિક બાઉન્ડ્રી સપાટી", font=f_title, fill=(255, 215, 0))
        draw.text((240, 605), "• SFEE (Steady Flow Energy Equation) તમામ ઓપન સિસ્ટમ્સ માટે લાગુ પડે છે.", font=f_body, fill=(255, 255, 255))

    elif stype == "phases":
        draw.text((50, 85), "હોમોજીનિયસ વિ. હેટરોજીનિયસ સિસ્ટમ (Phases of Matter)", font=f_title, fill=(255, 215, 0))

        draw.rectangle([50, 130, 610, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((70, 160), "HOMOGENEOUS SYSTEM", font=f_title, fill=(0, 255, 255))
        draw.text((70, 205), "(Single Phase - સિંગલ ફેઝ)", font=f_body, fill=(200, 255, 200))
        draw.text((70, 270), "• આખા વિસ્તારમાં એકસમાન ભૌતિક અવસ્થા", font=f_body, fill=(255, 255, 255))
        draw.text((70, 330), "ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((70, 380), "• શુદ્ધ વાયુ (Pure Gas)", font=f_body, fill=(255, 255, 255))
        draw.text((70, 430), "• હવા અને પાણીની વરાળનું મિશ્રણ", font=f_body, fill=(255, 255, 255))
        draw.text((70, 480), "• પાણીમાં સંપૂર્ણ ઓગળેલું મીઠું", font=f_body, fill=(255, 255, 255))

        draw.rectangle([650, 130, 1210, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((670, 160), "HETEROGENEOUS SYSTEM", font=f_title, fill=(0, 255, 255))
        draw.text((670, 205), "(Multi Phase - મલ્ટી ફેઝ)", font=f_body, fill=(200, 255, 200))
        draw.text((670, 270), "• બે કે તેથી વધુ અલગ અલગ અવસ્થા/ફેઝ", font=f_body, fill=(255, 255, 255))
        draw.text((670, 330), "ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((670, 380), "• પાણી અને બરફનું મિશ્રણ (Ice + Water)", font=f_body, fill=(255, 255, 255))
        draw.text((670, 430), "• પાણી અને તેલનું મિશ્રણ (Oil + Water)", font=f_body, fill=(255, 255, 255))

    elif stype == "exam_traps":
        draw.rectangle([60, 110, 1200, 660], fill=(22, 32, 50), outline=(255, 100, 100), width=3)
        draw.text((180, 140), "GSSSB EXAM TRAPS & CONFUSIONS", font=f_large, fill=(255, 215, 0))

        draw.text((90, 210), "૧. વાલ્વ વગરનું પિસ્ટન = Closed, પણ Piston with Valves = Open System!", font=f_body, fill=(255, 255, 255))
        draw.text((90, 270), "૨. પ્રેશર કૂકર સીટી વાગે ત્યાં સુધી Closed, સીટી વાગે પછી Open System", font=f_body, fill=(255, 255, 0))
        draw.text((90, 330), "૩. Steady Flow CV: અંદરનું દળ અચળ, પણ દળ વહનને લીધે Open System જ કહેવાય", font=f_body, fill=(0, 255, 255))
        draw.text((90, 390), "૪. Control Volume ની બાઉન્ડ્રીને Control Surface કહેવાય છે", font=f_body, fill=(200, 255, 200))
        draw.text((90, 450), "૫. Universe નો કોઈ સરાઉન્ડિંગ્સ નથી -> Universe હંમેશા Isolated System છે!", font=f_body, fill=(50, 255, 50))
        draw.text((90, 510), "૬. Adiabatic એટલે Q = 0 (ઉષ્મા ટ્રાન્સફર શૂન્ય), તાપમાન અચળ રહેવું જરૂરી નથી", font=f_body, fill=(255, 150, 150))
        draw.text((90, 570), "૭. Mass Flow Rate Equation: m_dot = rho * A * V (kg/s)", font=f_title, fill=(255, 215, 0))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: કયું Open System (Control Volume) નું ઉદાહરણ છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "❌ A. Bomb Calorimeter -> સીલબંધ પાત્ર (Closed System)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 270), "❌ B. Thermos Flask -> માસ/હીટ રોકાયેલા (Isolated System)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 310), "✅ C. Centrifugal Pump -> સતત માસ/એનર્જી પ્રવાહ (Correct Open System)", font=f_body, fill=(50, 255, 50))
        draw.text((90, 350), "❌ D. Cylinder without valves -> વાલ્વ ન હોવાથી (Closed System)", font=f_body, fill=(255, 100, 100))

        draw.text((70, 420), "Q2: બરફ અને પાણીનું મિશ્રણ (Ice + Water) કઈ સિસ્ટમ બનાવે છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 470), "• રાસાયણિક સૂત્ર H2O એક જ છે, પરંતુ બરફ = Solid, પાણી = Liquid", font=f_body, fill=(200, 255, 200))
        draw.text((90, 515), "❌ A. Homogeneous System (ભૂલથી ઘણા ટિક કરે છે!)", font=f_body, fill=(255, 100, 100))
        draw.text((90, 560), "✅ B. Heterogeneous System (૨ અલગ અલગ ભૌતિક અવસ્થા હોવાથી સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    # Convert PIL Image to OpenCV BGR numpy array
    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Master Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15 # 15 fps for fast high-quality animated rendering
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_std_s{sc['id']}.mp4"
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
    print("🎬 Merging all 8 Master Story Scenes into Final Video Asset...")
    clips = []
    for sc in SCENES:
        clips.append(VideoFileClip(sc["video_file"]))

    final_video = concatenate_videoclips(clips)
    final_video.write_videofile(
        FINAL_OUTPUT,
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

    print(f"🎉 SUCCESS! Final Master Story Video Saved: {FINAL_OUTPUT}")

if __name__ == "__main__":
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
