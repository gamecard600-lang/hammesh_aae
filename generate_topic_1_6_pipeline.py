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
        "title": "૧. થર્મોડાયનેમિક પ્રોપર્ટીઝ (Thermodynamic Properties)",
        "text": "થર્મોડાયનેમિક પ્રોપર્ટી એટલે સિસ્ટમની અવસ્થા દર્શાવતા માપી શકાય તેવા ભૌતિક ગુણધર્મો. જેમ કે દબાણ, તાપમાન, કદ, ઘનતા, ઇન્ટરનલ એનર્જી અને એન્થાલ્પી. પ્રોપર્ટીઝ એ સ્ટેટ ફંક્શન અને પોઇન્ટ ફંક્શન છે, જે માત્ર પ્રારંભિક અને અંતિમ અવસ્થા પર જ આધાર રાખે છે.",
        "audio_file": "assets/videos/t1_6_scene_1.mp3",
        "video_file": "assets/videos/t1_6_std_scene_1.mp4",
        "type": "properties_intro"
    },
    {
        "id": 2,
        "title": "૨. ઇન્ટેન્સિવ વિ. એક્સટેન્સિવ પ્રોપર્ટીઝ (Intensive vs Extensive)",
        "audio_file": "assets/videos/t1_6_scene_2.mp3",
        "video_file": "assets/videos/t1_6_std_scene_2.mp4",
        "text": "પરીક્ષામાં વારંવાર પૂછાતો મુખ્ય તફાવત: ૧. ઇન્ટેન્સિવ પ્રોપર્ટીઝ એ સિસ્ટમના દળ કે સાઇઝ પર આધાર રાખતી નથી! જેમ કે તાપમાન, દબાણ, ઘનતા, વિસ્કોસિટી અને સ્પેસિફિક વોલ્યુમ. ૨. એક્સટેન્સિવ પ્રોપર્ટીઝ એ સિસ્ટમના દળ પર આધાર રાખે છે! જેમ કે માસ, કદ, ઇન્ટરનલ એનર્જી, એન્થાલ્પી અને એન્ટ્રોપી. કોઈપણ એક્સટેન્સિવ પ્રોપર્ટીને દળ વડે ભાગતાં તે સ્પેસિફિક પ્રોપર્ટી બને છે, જે ઇન્ટેન્સિવ બની જાય છે!",
        "type": "intensive_extensive"
    },
    {
        "id": 3,
        "title": "૩. સ્ટેટ, પ્રોસેસ અને સાયકલ (State, Process & Cycle)",
        "audio_file": "assets/videos/t1_6_scene_3.mp3",
        "video_file": "assets/videos/t1_6_std_scene_3.mp4",
        "text": "સ્ટેટ એટલે ચોક્કસ પ્રોપર્ટીઝ વડે દર્શાવેલી સિસ્ટમની અવસ્થા. પ્રોસેસ એટલે સ્ટેટ ૧ થી સ્ટેટ ૨ તરફનો ફેરફાર. અને સાયકલ એટલે એવી પ્રક્રિયાઓનો સમૂહ જેમાં સિસ્ટમ વિવિધ ફેરફારોમાંથી પસાર થઈને મૂળ પ્રારંભિક અવસ્થામાં પાછી ફરે છે. કોઈપણ સાયકલ માટે તમામ પ્રોપર્ટીઝનો કુલ ફેરફાર શૂન્ય થાય છે!",
        "type": "state_process_cycle"
    },
    {
        "id": 4,
        "title": "૪. ક્વાસી-સ્ટેટિક અને રિવર્સિબલ પ્રોસેસ (Quasi-Static Process)",
        "audio_file": "assets/videos/t1_6_scene_4.mp3",
        "video_file": "assets/videos/t1_6_std_scene_4.mp4",
        "text": "ક્વાસી-સ્ટેટિક પ્રોસેસ એટલે અત્યંત ધીમી ઝડપે થતી પ્રક્રિયા! જેમાં સિસ્ટમ દરેક ક્ષણે થર્મોડાયનેમિક સંતુલનમાં રહે છે. ઘર્ષણરહિત ક્વાસી-સ્ટેટિક પ્રોસેસ એ આદર્શ રિવર્સિબલ પ્રોસેસ બને છે. તેને પી-વી ડાયાગ્રામ પર ઘાટી લાઇન વડે દર્શાવી શકાય છે.",
        "type": "quasistatic"
    },
    {
        "id": 5,
        "title": "૫. MCQ એલિમિનેશન અને સોલ્યુશન્સ (Actual App MCQs)",
        "audio_file": "assets/videos/t1_6_scene_5.mp3",
        "video_file": "assets/videos/t1_6_std_scene_5.mp4",
        "text": "ચાલો હવે વાસ્તવિક પ્રશ્નો સોલ્વ કરીએ: પ્રશ્ન ૧: નીચેનામાંથી કઈ ઇન્ટેન્સિવ પ્રોપર્ટી છે? સાચો જવાબ: તાપમાન અને દબાણ! પ્રશ્ન ૨: એક્સટેન્સિવ પ્રોપર્ટીને પર યુનિટ માસ ગણતાં તે કઈ પ્રોપર્ટી બને છે? સાચો જવાબ: ઇન્ટેન્સિવ પ્રોપર્ટી! અને પ્રશ્ન ૩: ક્વાસી-સ્ટેટિક પ્રોસેસની મુખ્ય લાક્ષણિકતા કઈ છે? સાચો જવાબ: અત્યંત ધીમી ઝડપ અને સંતુલન!",
        "type": "mcq_elimination"
    }
]

OUTPUT_VIDEO_PATH = "assets/videos/properties_process_and_state.mp4"

async def generate_audios():
    print("🎙️ Generating Topic 1.6 Gujarati Audio Narration...")
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

    if stype == "properties_intro":
        draw.rectangle([60, 110, 1200, 650], fill=(24, 36, 52), outline=(0, 255, 255), width=3)
        draw.text((100, 140), "THERMODYNAMIC PROPERTIES (સિસ્ટમના ગુણધર્મો)", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 210, 1140, 350], fill=(35, 25, 75), outline=(255, 215, 0), width=3)
        draw.text((150, 240), "• Property = Point Function & State Function ( Exact Differential )", font=f_title, fill=(50, 255, 50))
        draw.text((150, 295), "• માત્ર પ્રારંભિક (State 1) અને અંતિમ (State 2) પર આધાર રાખે છે.", font=f_title, fill=(255, 255, 255))

        draw.text((120, 400), "• Examples: Pressure (P), Temperature (T), Volume (V)", font=f_body, fill=(200, 255, 200))
        draw.text((120, 460), "• Density (rho), Internal Energy (U), Enthalpy (H), Entropy (S)", font=f_body, fill=(200, 255, 200))

    elif stype == "intensive_extensive":
        draw.text((50, 85), "INTENSIVE VS EXTENSIVE PROPERTIES (TOP EXAM CONCEPT)", font=f_large, fill=(255, 215, 0))

        # Intensive
        draw.rectangle([50, 130, 610, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((70, 160), "INTENSIVE PROPERTIES", font=f_title, fill=(0, 255, 255))
        draw.text((70, 205), "(Independent of Mass / Size)", font=f_body, fill=(200, 255, 200))
        draw.text((70, 270), "• દળ કે સાઇઝ પર આધાર રાખતી નથી!", font=f_body, fill=(50, 255, 50))
        draw.text((70, 330), "ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((70, 380), "• Pressure (P), Temperature (T)", font=f_body, fill=(255, 255, 255))
        draw.text((70, 430), "• Density (rho), Viscosity (mu)", font=f_body, fill=(255, 255, 255))
        draw.text((70, 480), "• Specific Volume (v = V/m)", font=f_body, fill=(255, 255, 255))

        # Extensive
        draw.rectangle([650, 130, 1210, 660], fill=(22, 35, 50), outline=(0, 255, 255), width=2)
        draw.text((670, 160), "EXTENSIVE PROPERTIES", font=f_title, fill=(0, 255, 255))
        draw.text((670, 205), "(Dependent on Mass / Size)", font=f_body, fill=(200, 255, 200))
        draw.text((670, 270), "• દળ કે સાઇઝ પર આધાર રાખે છે!", font=f_body, fill=(255, 100, 100))
        draw.text((670, 330), "ઉદાહરણો:", font=f_body, fill=(255, 215, 0))
        draw.text((670, 380), "• Mass (m), Total Volume (V)", font=f_body, fill=(255, 255, 255))
        draw.text((670, 430), "• Internal Energy (U), Enthalpy (H)", font=f_body, fill=(255, 255, 255))
        draw.text((670, 480), "• Entropy (S)", font=f_body, fill=(255, 255, 255))

    elif stype == "state_process_cycle":
        draw.text((50, 85), "STATE, PROCESS & THERMODYNAMIC CYCLE", font=f_large, fill=(255, 215, 0))

        draw.rectangle([120, 140, 1160, 300], fill=(35, 25, 75), outline=(0, 255, 255), width=3)
        draw.text((150, 180), "• State = પ્રોપર્ટીઝ વડે દર્શાવેલી સિસ્ટમની અવસ્થા (State 1, State 2)", font=f_title, fill=(255, 255, 255))
        draw.text((150, 240), "• Process = અવસ્થા ૧ થી અવસ્થા ૨ તરફનો ફેરફાર (Path 1-2)", font=f_title, fill=(50, 255, 50))

        draw.rectangle([120, 330, 1160, 630], fill=(20, 30, 45), outline=(255, 215, 0), width=2)
        draw.text((150, 370), "🔄 Thermodynamic Cycle:", font=f_title, fill=(255, 215, 0))
        draw.text((150, 430), "• સિસ્ટમ વિવિધ પ્રોસેસમાંથી પસાર થઈને મૂળ પ્રારંભિક અવસ્થામાં પાછી ફરે છે.", font=f_body, fill=(255, 255, 255))
        draw.text((150, 490), "• Cycle માટે કોઈપણ પ્રોપર્ટીનો ફેરફાર delta_Property = 0 થાય છે!", font=f_title, fill=(0, 255, 255))

    elif stype == "quasistatic":
        draw.text((50, 85), "QUASI-STATIC & REVERSIBLE PROCESS", font=f_large, fill=(0, 255, 255))

        draw.rectangle([120, 140, 1160, 640], fill=(25, 45, 65), outline=(255, 215, 0), width=3)
        draw.text((150, 180), "💡 QUASI-STATIC PROCESS (અત્યંત ધીમી પ્રોસેસ):", font=f_large, fill=(50, 255, 50))

        draw.text((150, 270), "• પ્રોસેસ એટલી ધીમી ઝડપે થાય છે કે સિસ્ટમ દરેક ક્ષણે સંતુલનમાં રહે છે.", font=f_title, fill=(255, 255, 255))
        draw.text((150, 330), "• Frictionless Quasi-Static Process = Reversible Process!", font=f_title, fill=(200, 255, 200))

        draw.text((150, 430), "• P-V ડાયાગ્રામ પર ઘાટી સળંગ લાઇન (Solid Line) વડે દર્શાવાય છે.", font=f_body, fill=(255, 215, 0))

    else:
        # MCQ Option Elimination
        draw.rectangle([50, 100, 1210, 660], fill=(18, 28, 45), outline=(0, 255, 255), width=3)
        draw.text((180, 125), "MCQ OPTION ELIMINATION METHOD", font=f_large, fill=(255, 215, 0))

        draw.text((70, 185), "Q1: નીચેનામાંથી કઈ Intensive Property છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 230), "✅ સાચો જવાબ: Temperature & Pressure! (દળ પર આધાર ન રાખે)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 300), "Q2: Extensive Property ને per unit mass ગણતાં તે કઈ પ્રોપર્ટી બને?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 345), "✅ સાચો જવાબ: Intensive Property (Specific Property)", font=f_body, fill=(50, 255, 50))

        draw.text((70, 420), "Q3: Quasi-Static Process ની મુખ્ય લાક્ષણિકતા કઈ છે?", font=f_title, fill=(255, 255, 255))
        draw.text((90, 465), "❌ A. ઉચ્ચ ઝડપ", font=f_body, fill=(255, 100, 100))
        draw.text((90, 505), "✅ B. અત્યંત ધીમી ઝડપ અને સંતુલન (Infinitely Slow & Equilibrium - સાચો જવાબ!)", font=f_body, fill=(50, 255, 50))

    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Topic 1.6 Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 15
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_t1_6_s{sc['id']}.mp4"
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
    print("🎬 Merging all 5 Scenes for Topic 1.6 into Final Asset...")
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

    print(f"🎉 SUCCESS! Topic 1.6 Video Saved: {OUTPUT_VIDEO_PATH}")

if __name__ == "__main__":
    asyncio.run(generate_audios())
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
