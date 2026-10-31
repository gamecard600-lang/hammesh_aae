import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

fluid_subject = data[1] # Subject 2: Fluid Mechanics
topics = fluid_subject.get('topics', [])

exact_mappings = [
    'assets/videos/fluid_properties.mp4',                # Topic 1: Fluid & Viscosity
    'assets/videos/fluid_properties.mp4',                # Topic 2: Fluid Properties
    'assets/videos/fluid_statics.mp4',                   # Topic 3: Fluid Statics
    'assets/videos/fluid_kinematics_and_dynamics.mp4',   # Topic 4: Fluid Kinematics & Dynamics
    'assets/videos/fluid_kinematics_and_dynamics.mp4',   # Topic 5: Fluid Dynamics
    'assets/videos/flow_through_pipes.mp4',              # Topic 6: Pipe Flow
    'assets/videos/units_and_dimensions.mp4',            # Topic 7: Units & Dimensions
    'assets/videos/boundary_layer_theory.mp4',           # Topic 8: Boundary Layer Theory
    'assets/videos/fluid_control_volume.mp4',            # Topic 9: Control Volume Analysis
    'assets/videos/flow_measurement_devices.mp4',        # Topic 10: Bernoulli's Equation & Devices
    'assets/videos/centrifugal_and_reciprocating_pumps.mp4', # Topic 11: Viscous Flow & Pumps
    'assets/videos/hydraulic_turbines.mp4',              # Topic 12: Water Turbines
    'assets/videos/hydraulic_turbines.mp4'               # Topic 13: Types of Turbines
]

for i, t in enumerate(topics):
    if i < len(exact_mappings):
        mp4_path = exact_mappings[i]
        vl = t.get('visualLearning', {})
        videos = vl.get('videos', [])
        if videos:
            videos[0]['assetPath'] = mp4_path
        else:
            t['visualLearning'] = {
                'videos': [
                    {
                        'title': f"{t.get('title')} Video Lesson",
                        'assetPath': mp4_path
                    }
                ]
            }
        print(f"✅ Topic {i+1} ({t.get('title')}): Mapped to {mp4_path}")

json.dump(data, open(file_path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print("\n🎉 MASTER STUDY MATERIAL EXACTLY UPDATED FOR SUBJECT 2 (FLUID MECHANICS)!")
