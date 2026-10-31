import os
import asyncio
import numpy as np
import cv2
from moviepy import VideoFileClip, AudioFileClip, concatenate_videoclips

SCENES = [
    {
        "id": 1,
        "title": "🎬 1. Introduction & Basic Definitions",
        "type": "intro_definitions",
        "audio_file": "assets/videos/full_scene_1.mp3",
        "video_file": "assets/videos/full_scene_1.mp4",
    },
    {
        "id": 2,
        "title": "📐 2. Boundary and its 4 Core Types",
        "type": "boundary_types",
        "audio_file": "assets/videos/full_scene_2.mp3",
        "video_file": "assets/videos/full_scene_2.mp4",
    },
    {
        "id": 3,
        "title": "🔬 3. Macroscopic vs Microscopic Approach",
        "type": "approaches",
        "audio_file": "assets/videos/full_scene_3.mp3",
        "video_file": "assets/videos/full_scene_3.mp4",
    },
    {
        "id": 4,
        "title": "🔒 4. Closed System (Control Mass)",
        "type": "closed_system",
        "audio_file": "assets/videos/full_scene_4.mp3",
        "video_file": "assets/videos/full_scene_4.mp4",
    },
    {
        "id": 5,
        "title": "⚙️ 5. Open System (Control Volume)",
        "type": "open_system",
        "audio_file": "assets/videos/full_scene_5.mp3",
        "video_file": "assets/videos/full_scene_5.mp4",
    },
    {
        "id": 6,
        "title": "📏 6. Control Volume & Mass Flow Rate Equation",
        "type": "formula_m_dot",
        "audio_file": "assets/videos/full_scene_6.mp3",
        "video_file": "assets/videos/full_scene_6.mp4",
    },
    {
        "id": 7,
        "title": "❄️ 7. Isolated System (Q=0, W=0, delta_U=0)",
        "type": "isolated_system",
        "audio_file": "assets/videos/full_scene_7.mp3",
        "video_file": "assets/videos/full_scene_7.mp4",
    },
    {
        "id": 8,
        "title": "🧪 8. Homogeneous vs Heterogeneous System",
        "type": "phases",
        "audio_file": "assets/videos/full_scene_8.mp3",
        "video_file": "assets/videos/full_scene_8.mp4",
    },
    {
        "id": 9,
        "title": "🏆 9. GSSSB Exam Traps & Revision Table",
        "type": "exam_traps",
        "audio_file": "assets/videos/full_scene_9.mp3",
        "video_file": "assets/videos/full_scene_9.mp4",
    },
]

FINAL_OUTPUT = "assets/videos/thermodynamic_systems.mp4"

def get_audio_duration(path):
    clip = AudioFileClip(path)
    dur = clip.duration
    clip.close()
    return dur

def draw_scene_frame(scene_data, t, width=1280, height=720):
    img = np.zeros((height, width, 3), dtype=np.uint8)
    img[:] = (24, 18, 12) # Dark Engineering Slate Background

    # Header Bar
    cv2.rectangle(img, (0, 0), (width, 80), (50, 35, 20), -1)
    cv2.putText(img, scene_data["title"], (30, 52), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (255, 215, 0), 2)

    stype = scene_data["type"]

    if stype == "intro_definitions":
        cv2.rectangle(img, (180, 160), (1100, 620), (50, 40, 30), 2)
        cv2.putText(img, "SURROUNDINGS (સરાઉન્ડિંગ્સ)", (210, 200), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (180, 180, 180), 2)

        pulse = int(4 * np.sin(t * 4))
        cv2.rectangle(img, (380 - pulse, 260 - pulse), (900 + pulse, 520 + pulse), (180, 100, 30), -1)
        cv2.rectangle(img, (380 - pulse, 260 - pulse), (900 + pulse, 520 + pulse), (0, 255, 255), 3)
        cv2.putText(img, "THERMODYNAMIC SYSTEM", (420, 370), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (255, 255, 255), 2)
        cv2.putText(img, "Region in Space or Fixed Mass (Car Engine / Cooker)", (410, 410), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (200, 255, 200), 2)
        cv2.putText(img, "<-- BOUNDARY (બાઉન્ડ્રી) -->", (440, 560), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 255), 2)
        cv2.putText(img, "UNIVERSE = SYSTEM + SURROUNDINGS", (320, 660), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (255, 215, 0), 2)

    elif stype == "boundary_types":
        cv2.putText(img, "4 CORE TYPES OF BOUNDARIES", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (255, 215, 0), 2)
        # Quadrant 1
        cv2.rectangle(img, (80, 160), (600, 380), (40, 50, 70), -1)
        cv2.putText(img, "1. Fixed vs Movable", (100, 200), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 255), 2)
        cv2.putText(img, "Container Wall = Fixed Boundary", (100, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(img, "Moving Piston = Movable Boundary", (100, 300), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)

        # Quadrant 2
        cv2.rectangle(img, (680, 160), (1200, 380), (40, 50, 70), -1)
        cv2.putText(img, "2. Real vs Imaginary", (700, 200), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 255), 2)
        cv2.putText(img, "Pipe Metal Wall = Real Boundary", (700, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(img, "Pipe Inlet/Outlet = Imaginary Boundary", (700, 300), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)

        # Quadrant 3
        cv2.rectangle(img, (80, 410), (600, 630), (40, 50, 70), -1)
        cv2.putText(img, "3. Diathermic Boundary", (100, 450), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 255), 2)
        cv2.putText(img, "Allows Heat Transfer across Boundary", (100, 500), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(img, "Heat Transfer Q != 0", (100, 550), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (50, 255, 50), 2)

        # Quadrant 4
        cv2.rectangle(img, (680, 410), (1200, 630), (40, 50, 70), -1)
        cv2.putText(img, "4. Adiabatic Boundary", (700, 450), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 255), 2)
        cv2.putText(img, "Thermally Insulated (Heat Proof)", (700, 500), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(img, "Heat Transfer Q = 0", (700, 550), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 100, 100), 2)

    elif stype == "approaches":
        cv2.putText(img, "MACROSCOPIC VS MICROSCOPIC APPROACH", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (255, 215, 0), 2)

        # Left Column: Macroscopic
        cv2.rectangle(img, (80, 160), (600, 620), (30, 45, 65), -1)
        cv2.putText(img, "MACROSCOPIC APPROACH", (100, 210), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(img, "(Classical Thermodynamics)", (100, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (200, 255, 200), 2)
        cv2.putText(img, "- Average behavior of system", (100, 310), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)
        cv2.putText(img, "- Measured directly: P, V, T", (100, 370), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)
        cv2.putText(img, "- No molecular structure required", (100, 430), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)

        # Right Column: Microscopic
        cv2.rectangle(img, (680, 160), (1200, 620), (30, 45, 65), -1)
        cv2.putText(img, "MICROSCOPIC APPROACH", (700, 210), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(img, "(Statistical Thermodynamics)", (700, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (200, 255, 200), 2)
        cv2.putText(img, "- Individual molecular dynamics", (700, 310), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)
        cv2.putText(img, "- Used in low density gases & high vacuum", (700, 370), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)

        # Draw moving gas molecules on right side
        for i in range(12):
            mx = int(800 + (i * 30 + t * 40) % 350)
            my = int(450 + 40 * np.sin(i + t * 5))
            cv2.circle(img, (mx, my), 8, (255, 200, 50), -1)

    elif stype == "closed_system":
        cv2.putText(img, "CLOSED SYSTEM (CONTROL MASS)", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (0, 255, 255), 2)
        cv2.rectangle(img, (400, 180), (880, 440), (60, 60, 60), 4)
        piston_pos = int(600 + 30 * np.sin(t * 3))
        cv2.rectangle(img, (piston_pos, 184), (piston_pos + 40, 436), (200, 100, 50), -1)

        cv2.putText(img, "MASS TRANSFER = NO (Mass = Constant)", (240, 500), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (50, 255, 50), 2)
        cv2.putText(img, "ENERGY TRANSFER = YES (Heat Q & Work W)", (240, 550), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (255, 200, 50), 2)
        cv2.putText(img, "Examples: Valve-less Piston-Cylinder, Bomb Calorimeter, Cooker", (140, 610), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (255, 255, 255), 2)

    elif stype == "open_system":
        cv2.putText(img, "OPEN SYSTEM (CONTROL VOLUME)", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (255, 215, 0), 2)
        cv2.rectangle(img, (440, 180), (840, 440), (40, 100, 180), -1)
        cv2.rectangle(img, (440, 180), (840, 440), (0, 255, 255), 3)
        cv2.putText(img, "CONTROL VOLUME", (510, 300), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)

        flow = int((t * 200) % 150)
        cv2.arrowedLine(img, (180 + flow, 310), (420, 310), (0, 255, 0), 5, tipLength=0.2)
        cv2.putText(img, "Mass In", (180, 270), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        cv2.arrowedLine(img, (860, 310), (1100 + flow % 50, 310), (0, 255, 0), 5, tipLength=0.2)
        cv2.putText(img, "Mass Out", (880, 270), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        cv2.putText(img, "BOTH MASS & ENERGY CROSS BOUNDARY", (280, 510), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (50, 255, 255), 2)
        cv2.putText(img, "Examples: Steam Turbine, Compressor, Pump, Boiler, Nozzle, Diffuser", (100, 570), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (255, 255, 255), 2)

    elif stype == "formula_m_dot":
        cv2.putText(img, "CONTROL VOLUME MASS FLOW RATE EQUATION", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (0, 255, 255), 2)

        cv2.rectangle(img, (260, 180), (1020, 320), (40, 30, 80), -1)
        cv2.rectangle(img, (260, 180), (1020, 320), (255, 215, 0), 3)
        cv2.putText(img, "m_dot = rho * A * V", (370, 260), cv2.FONT_HERSHEY_SIMPLEX, 1.7, (255, 255, 255), 4)

        cv2.putText(img, "m_dot = Mass Flow Rate (kg/s)", (300, 380), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (200, 255, 200), 2)
        cv2.putText(img, "rho = Fluid Density (kg/m3)", (300, 430), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (200, 255, 200), 2)
        cv2.putText(img, "A = Cross-Sectional Area (m2)", (300, 480), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (200, 255, 200), 2)
        cv2.putText(img, "V = Fluid Velocity (m/s)", (300, 530), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (200, 255, 200), 2)
        cv2.putText(img, "Control Surface = Boundary of Control Volume", (280, 610), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (255, 215, 0), 2)

    elif stype == "isolated_system":
        cv2.putText(img, "ISOLATED SYSTEM (Neither Mass nor Energy Transfer)", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 255), 2)
        cv2.rectangle(img, (520, 180), (760, 440), (100, 100, 100), -1)
        cv2.rectangle(img, (540, 200), (740, 420), (40, 40, 120), -1)
        cv2.rectangle(img, (520, 180), (760, 440), (255, 255, 255), 4)

        cv2.putText(img, "MASS TRANSFER = NO", (280, 500), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (0, 255, 0), 2)
        cv2.putText(img, "ENERGY TRANSFER = NO (Q = 0, W = 0, delta_U = 0)", (200, 550), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (0, 255, 0), 2)
        cv2.putText(img, "Examples: Insulated Thermos Flask, Ice-Water Mixture, Universe", (140, 610), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (255, 255, 255), 2)

    elif stype == "phases":
        cv2.putText(img, "HOMOGENEOUS VS HETEROGENEOUS SYSTEM", (80, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (255, 215, 0), 2)

        # Left Column: Homogeneous
        cv2.rectangle(img, (80, 160), (600, 620), (30, 45, 65), -1)
        cv2.putText(img, "HOMOGENEOUS SYSTEM", (100, 210), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(img, "(Single Phase / Uniform Structure)", (100, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (200, 255, 200), 2)
        cv2.putText(img, "Examples:", (100, 310), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(img, "• Mixture of Air + Water Vapour", (100, 360), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)
        cv2.putText(img, "• Salt completely dissolved in Water", (100, 410), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)

        # Right Column: Heterogeneous
        cv2.rectangle(img, (680, 160), (1200, 620), (30, 45, 65), -1)
        cv2.putText(img, "HETEROGENEOUS SYSTEM", (700, 210), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(img, "(Multi Phase / Non-Uniform)", (700, 250), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (200, 255, 200), 2)
        cv2.putText(img, "Examples:", (700, 310), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(img, "• Mixture of Ice + Water", (700, 360), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)
        cv2.putText(img, "• Mixture of Oil + Water", (700, 410), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 1)

    else:
        # GSSSB Exam Traps
        cv2.rectangle(img, (100, 140), (1180, 640), (20, 35, 55), -1)
        cv2.rectangle(img, (100, 140), (1180, 640), (255, 100, 100), 3)
        cv2.putText(img, "GSSSB EXAM TRAPS & GOLDEN POINTS", (180, 190), cv2.FONT_HERSHEY_SIMPLEX, 0.95, (255, 215, 0), 3)

        cv2.putText(img, "1. Valve closed Piston-Cylinder = Closed System (Mass = Constant)", (130, 260), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (255, 255, 255), 2)
        cv2.putText(img, "2. Valve opens & gas flows = Open System immediately!", (130, 320), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (255, 255, 0), 2)
        cv2.putText(img, "3. Steady Flow CV: Storage inside CV = Constant, but mass crosses boundary!", (130, 380), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (0, 255, 255), 2)
        cv2.putText(img, "4. Boundary of Control Volume = Control Surface", (130, 440), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (200, 255, 200), 2)
        cv2.putText(img, "5. Universe has no surroundings -> Always Isolated System!", (130, 500), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (255, 150, 150), 2)
        cv2.putText(img, "6. Formula: m_dot = rho * A * V (kg/s)", (130, 560), cv2.FONT_HERSHEY_SIMPLEX, 0.68, (255, 215, 0), 2)

    return img

def render_scene(sc):
    audio_path = sc["audio_file"]
    video_path = sc["video_file"]
    duration = get_audio_duration(audio_path)
    print(f"🎥 Rendering Scene {sc['id']}: {sc['title']} ({duration:.2f}s)...")

    fps = 30
    total_frames = int(duration * fps)
    width, height = 1280, 720

    temp_raw = f"assets/videos/temp_full_s{sc['id']}.mp4"
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(temp_raw, fourcc, fps, (width, height))

    for f in range(total_frames):
        t = f / fps
        frame = draw_scene_frame(sc, t, width, height)
        out.write(frame)

    out.release()

    # Combine audio and video
    v_clip = VideoFileClip(temp_raw)
    a_clip = AudioFileClip(audio_path)

    final = v_clip.with_duration(a_clip.duration)
    final = final.with_audio(a_clip)

    final.write_videofile(
        video_path,
        codec="libx264",
        audio_codec="aac",
        fps=30,
        preset="fast"
    )

    v_clip.close()
    a_clip.close()
    final.close()

    if os.path.exists(temp_raw):
        os.remove(temp_raw)

    print(f"  ✅ Scene {sc['id']} Complete!")

def merge_all_scenes():
    print("🎬 Merging all 9 Detailed Scenes into Final Video Asset...")
    clips = []
    for sc in SCENES:
        clips.append(VideoFileClip(sc["video_file"]))

    final_video = concatenate_videoclips(clips)
    final_video.write_videofile(
        FINAL_OUTPUT,
        codec="libx264",
        audio_codec="aac",
        fps=30,
        preset="fast"
    )

    for c in clips:
        c.close()
    final_video.close()

    # Clean up scene video files
    for sc in SCENES:
        if os.path.exists(sc["video_file"]):
            os.remove(sc["video_file"])

    print(f"🎉 SUCCESS! Final 9-Scene Extreme Detail Video Saved: {FINAL_OUTPUT}")

if __name__ == "__main__":
    for sc in SCENES:
        render_scene(sc)
    merge_all_scenes()
