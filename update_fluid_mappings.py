import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

fluid_subject = data[1] # Fluid Mechanics
topics = fluid_subject.get('topics', [])
print(f"Subject: {fluid_subject.get('subject')}, Total topics: {len(topics)}")

mappings = [
    'fluid_properties.mp4',
    'fluid_statics.mp4',
    'fluid_kinematics_and_dynamics.mp4',
    'units_and_dimensions.mp4',
    'flow_through_pipes.mp4',
    'fluid_control_volume.mp4',
    'laminar_and_turbulent_flow.mp4',
    'boundary_layer_theory.mp4',
    'flow_measurement_devices.mp4',
    'hydraulic_turbines.mp4',
    'centrifugal_and_reciprocating_pumps.mp4',
    'compressible_flow.mp4',
    'open_channel_flow.mp4',
    'model_analysis_and_similitude.mp4'
]

for i, t in enumerate(topics):
    mp4_file = mappings[i % len(mappings)]
    vl = t.get('visualLearning', {})
    videos = vl.get('videos', [])
    if videos:
        videos[0]['assetPath'] = f"assets/videos/{mp4_file}"
        print(f"  Topic {i+1} ({t.get('title')}): Mapped to assets/videos/{mp4_file}")
    else:
        t['visualLearning'] = {
            'videos': [
                {
                    'title': f"{t.get('title')} Video Lesson",
                    'assetPath': f"assets/videos/{mp4_file}"
                }
            ]
        }
        print(f"  Topic {i+1} ({t.get('title')}): Created visual learning video mapping to assets/videos/{mp4_file}")

json.dump(data, open(file_path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print("✅ MASTER STUDY MATERIAL UPDATED FOR FLUID MECHANICS!")
