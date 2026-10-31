from manim import *
import os
import subprocess

def get_audio_duration(file_path):
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", file_path],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        )
        return float(result.stdout.strip())
    except Exception:
        return 10.0

class ThermoSystemsStory(Scene):
    def construct(self):
        # SCENE 1: Intro to System, Surroundings, Boundary
        dur1 = get_audio_duration("sys_scene_1.wav")
        if os.path.exists("sys_scene_1.wav"):
            self.add_sound("sys_scene_1.wav")

        box = DashedVMobject(Rectangle(width=4, height=3, color=RED), num_dashes=30)
        sys_text = Text("System\n(અભ્યાસનો વિસ્તાર)", font_size=24, color=BLUE).move_to(box.get_center())
        surr_text = Text("Surroundings", font_size=24, color=GREY).next_to(box, RIGHT, buff=1)
        bound_text = Text("Boundary", color=RED, font_size=24).next_to(box, UP, buff=0.1)

        self.play(Create(box), Write(sys_text), run_time=2)
        self.play(Write(surr_text), Write(bound_text), run_time=2)

        univ_text = Text("Universe = System + Surroundings", font_size=24, color=GOLD).to_edge(DOWN)
        self.play(Write(univ_text), run_time=1)

        self.wait(max(0.1, dur1 - 5))
        self.play(FadeOut(box, sys_text, surr_text, bound_text, univ_text))
        self.wait(0.5)

        # SCENE 2: Closed System (Cooker / Piston)
        dur2 = get_audio_duration("sys_scene_2.wav")
        if os.path.exists("sys_scene_2.wav"):
            self.add_sound("sys_scene_2.wav")

        c_title = Text("Closed System (Control Mass)", color=YELLOW, font_size=26).to_edge(UP)
        c_box = Rectangle(width=2.5, height=3, color=WHITE)
        piston = Rectangle(width=2.4, height=0.3, color=GREY).move_to(c_box.get_top() + DOWN*0.5)

        heat_arrow = Arrow(c_box.get_bottom() + DOWN*1.5, c_box.get_bottom(), color=RED)
        heat_text = Text("Heat IN", font_size=24, color=RED).next_to(heat_arrow, RIGHT)

        mass_text = Text("Mass = Blocked (અચળ)", font_size=22, color=BLUE).next_to(c_box, LEFT, buff=0.5)

        self.play(Write(c_title), Create(c_box), Create(piston), run_time=2)
        self.play(GrowArrow(heat_arrow), Write(heat_text), run_time=1)
        self.play(Write(mass_text), run_time=1.5)

        self.wait(max(0.1, dur2 - 4.5))
        self.play(FadeOut(c_title, c_box, piston, heat_arrow, heat_text, mass_text))
        self.wait(0.5)

        # SCENE 3: Open System (Turbine)
        dur3 = get_audio_duration("sys_scene_3.wav")
        if os.path.exists("sys_scene_3.wav"):
            self.add_sound("sys_scene_3.wav")

        o_title = Text("Open System (Control Volume)", color=YELLOW, font_size=26).to_edge(UP)
        turbine = Polygon(LEFT*1 + UP*1.5, RIGHT*2 + UP*2.5, RIGHT*2 + DOWN*2.5, LEFT*1 + DOWN*1.5, color=BLUE)

        m_in = Arrow(LEFT*3, turbine.get_left(), color=WHITE)
        m_in_t = Text("Mass & Energy IN", font_size=20).next_to(m_in, UP)

        m_out = Arrow(turbine.get_right(), RIGHT*4, color=WHITE)
        m_out_t = Text("Mass & Energy OUT", font_size=20).next_to(m_out, UP)

        w_out = Arrow(turbine.get_center(), turbine.get_center() + RIGHT*3, color=GREEN)
        w_out_t = Text("Work", font_size=20, color=GREEN).next_to(w_out, DOWN)

        self.play(Write(o_title), Create(turbine), run_time=1.5)
        self.play(GrowArrow(m_in), Write(m_in_t), GrowArrow(m_out), Write(m_out_t), run_time=2)
        self.play(GrowArrow(w_out), Write(w_out_t), run_time=1)

        self.wait(max(0.1, dur3 - 4.5))
        self.play(FadeOut(o_title, turbine, m_in, m_in_t, m_out, m_out_t, w_out, w_out_t))
        self.wait(0.5)

        # SCENE 4: Isolated System (Thermos)
        dur4 = get_audio_duration("sys_scene_4.wav")
        if os.path.exists("sys_scene_4.wav"):
            self.add_sound("sys_scene_4.wav")

        i_title = Text("Isolated System", color=YELLOW, font_size=26).to_edge(UP)
        flask = RoundedRectangle(corner_radius=0.5, width=2, height=3.5, color=GREY)
        flask_inner = RoundedRectangle(corner_radius=0.4, width=1.6, height=3.1, color=BLUE)

        cross_m = Cross(Arrow(LEFT*2, flask.get_left()), stroke_color=RED)
        cross_q = Cross(Arrow(flask.get_right(), RIGHT*2), stroke_color=RED)

        iso_t1 = Text("No Mass", font_size=22).next_to(cross_m, LEFT)
        iso_t2 = Text("No Heat/Work", font_size=22).next_to(cross_q, RIGHT)

        self.play(Write(i_title), Create(flask), Create(flask_inner), run_time=2)
        self.play(Create(cross_m), Write(iso_t1), Create(cross_q), Write(iso_t2), run_time=2)

        self.wait(max(0.1, dur4 - 4))
        self.play(FadeOut(i_title, flask, flask_inner, cross_m, cross_q, iso_t1, iso_t2))
        self.wait(0.5)

        # SCENE 5: Exam Golden Points
        dur5 = get_audio_duration("sys_scene_5.wav")
        if os.path.exists("sys_scene_5.wav"):
            self.add_sound("sys_scene_5.wav")

        exam_box = Rectangle(width=10, height=4.2, color=RED)
        exam_title = Text("EXAM GOLDEN POINTS", font_size=28, color=RED).next_to(exam_box, UP)

        p1 = Text("1. Piston-Cylinder (without valve) = Closed System", font_size=20, color=WHITE)
        p2 = Text("2. Mass flow rate in Open System: m_dot = rho * A * V", font_size=20, color=YELLOW)
        p3 = Text("3. Universe = Isolated System (No surroundings)", font_size=20, color=GREEN)

        exam_text = VGroup(p1, p2, p3).arrange(DOWN, aligned_edge=LEFT, buff=0.5).move_to(exam_box.get_center())

        self.play(Create(exam_box), Write(exam_title), run_time=1.5)
        self.play(Write(exam_text), run_time=3)

        self.wait(max(0.1, dur5 - 4.5))
        self.play(FadeOut(exam_box, exam_title, exam_text))
