from manim import *
import subprocess
import os

def get_audio_duration(file_path):
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", file_path],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        )
        return float(result.stdout.strip())
    except:
        return 10.0  # જો ffprobe ના મળે તો ડિફોલ્ટ ૧૦ સેકન્ડ

class ThermoSystemsStory(Scene):
    def construct(self):
        base_dir = r"C:\Users\hamme\AndroidStudioProjects\hammesh_aae"

        # --- SCENE 1 ---
        path1 = os.path.join(base_dir, "sys_scene_1.mp3")
        dur1 = get_audio_duration(path1)
        if os.path.exists(path1):
            self.add_sound(path1)

        box = DashedVMobject(Rectangle(width=5, height=3, color=RED), num_dashes=30)
        sys_text = Text("System", font_size=36, color=BLUE).move_to(box.get_center())
        surr_text = Text("Surroundings", font_size=28, color=GREY).next_to(box, RIGHT, buff=1)
        bound_text = Text("Boundary", color=RED, font_size=28).next_to(box, UP, buff=0.1)

        self.play(Create(box), Write(sys_text), run_time=2)
        self.play(Write(surr_text), Write(bound_text), run_time=2)

        univ_text = Text("Universe = System + Surroundings", color=GOLD, font_size=28).to_edge(DOWN)
        self.play(Write(univ_text), run_time=1)

        self.wait(max(0.1, dur1 - 5))
        self.play(FadeOut(box, sys_text, surr_text, bound_text, univ_text))
        self.wait(0.5)

        # --- SCENE 2 ---
        path2 = os.path.join(base_dir, "sys_scene_2.mp3")
        dur2 = get_audio_duration(path2)
        if os.path.exists(path2):
            self.add_sound(path2)

        c_title = Text("Closed System (Control Mass)", color=YELLOW, font_size=36).to_edge(UP)
        c_box = Rectangle(width=3, height=4, color=WHITE)
        piston = Rectangle(width=2.8, height=0.3, color=GREY).move_to(c_box.get_top() + DOWN*0.5)

        heat_arrow = Arrow(c_box.get_bottom() + DOWN*1.5, c_box.get_bottom(), color=RED)
        heat_text = Text("Heat", font_size=24, color=RED).next_to(heat_arrow, RIGHT)
        mass_text = Text("Mass = Blocked", font_size=24, color=BLUE).next_to(c_box, LEFT, buff=0.5)

        self.play(Write(c_title), Create(c_box), Create(piston), run_time=2)
        self.play(GrowArrow(heat_arrow), Write(heat_text), run_time=1)
        self.play(Write(mass_text), run_time=1)

        self.wait(max(0.1, dur2 - 4))
        self.play(FadeOut(c_title, c_box, piston, heat_arrow, heat_text, mass_text))
        self.wait(0.5)

        # --- SCENE 3 ---
        path3 = os.path.join(base_dir, "sys_scene_3.mp3")
        dur3 = get_audio_duration(path3)
        if os.path.exists(path3):
            self.add_sound(path3)

        o_title = Text("Open System (Control Volume)", color=YELLOW, font_size=36).to_edge(UP)
        turbine = Polygon(LEFT*1 + UP*1.5, RIGHT*2 + UP*2.5, RIGHT*2 + DOWN*2.5, LEFT*1 + DOWN*1.5, color=BLUE)

        m_in = Arrow(LEFT*3, turbine.get_left(), color=WHITE)
        m_in_t = Text("Mass & Heat IN", font_size=20).next_to(m_in, UP)

        m_out = Arrow(turbine.get_right(), RIGHT*4, color=WHITE)
        m_out_t = Text("Mass & Heat OUT", font_size=20).next_to(m_out, UP)

        w_out = Arrow(turbine.get_center(), turbine.get_center() + RIGHT*3, color=GREEN)
        w_out_t = Text("Work", font_size=20, color=GREEN).next_to(w_out, DOWN)

        self.play(Write(o_title), Create(turbine), run_time=1.5)
        self.play(GrowArrow(m_in), Write(m_in_t), GrowArrow(m_out), Write(m_out_t), run_time=2)
        self.play(GrowArrow(w_out), Write(w_out_t), run_time=1)

        self.wait(max(0.1, dur3 - 4.5))
        self.play(FadeOut(o_title, turbine, m_in, m_in_t, m_out, m_out_t, w_out, w_out_t))
        self.wait(0.5)

        # --- SCENE 4 ---
        path4 = os.path.join(base_dir, "sys_scene_4.mp3")
        dur4 = get_audio_duration(path4)
        if os.path.exists(path4):
            self.add_sound(path4)

        i_title = Text("Isolated System", color=YELLOW, font_size=36).to_edge(UP)
        flask = RoundedRectangle(corner_radius=0.5, width=2.5, height=4, color=GREY)
        flask_inner = RoundedRectangle(corner_radius=0.4, width=2.1, height=3.6, color=BLUE)

        cross_m = Cross(Arrow(LEFT*2.5, flask.get_left()), stroke_color=RED)
        cross_q = Cross(Arrow(flask.get_right(), RIGHT*2.5), stroke_color=RED)

        iso_t1 = Text("No Mass", font_size=24).next_to(cross_m, LEFT)
        iso_t2 = Text("No Energy", font_size=24).next_to(cross_q, RIGHT)

        self.play(Write(i_title), Create(flask), Create(flask_inner), run_time=2)
        self.play(Create(cross_m), Write(iso_t1), Create(cross_q), Write(iso_t2), run_time=2)

        self.wait(max(0.1, dur4 - 4))
        self.play(FadeOut(i_title, flask, flask_inner, cross_m, cross_q, iso_t1, iso_t2))
        self.wait(0.5)

        # --- SCENE 5 ---
        path5 = os.path.join(base_dir, "sys_scene_5.mp3")
        dur5 = get_audio_duration(path5)
        if os.path.exists(path5):
            self.add_sound(path5)

        exam_box = Rectangle(width=12, height=5, color=RED)
        exam_title = Text("EXAM GOLDEN POINTS", font_size=32, color=RED).next_to(exam_box, UP)

        p1 = Text("1. Piston-Cylinder (without valve) = Closed System", font_size=20, color=WHITE)
        p2 = Text("2. Open System Mass flow rate: m_dot = rho * A * V", font_size=20, color=YELLOW)
        p3 = Text("3. Universe = Isolated System (No surroundings)", font_size=20, color=GREEN)

        exam_text = VGroup(p1, p2, p3).arrange(DOWN, aligned_edge=LEFT, buff=0.6).move_to(exam_box.get_center())

        self.play(Create(exam_box), Write(exam_title), run_time=1.5)
        self.play(Write(exam_text), run_time=3)

        self.wait(max(0.1, dur5 - 4.5))
        self.play(FadeOut(exam_box, exam_title, exam_text))
