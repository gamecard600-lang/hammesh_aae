# Hammesh AAE v1.3.0 Content Master Update

## Base
Use this ZIP as the source tree. Do not replace or redesign existing features unless listed below.

## Required implementation
1. Keep the existing 14 technical subjects and 165 technical topics.
2. Fluid Mechanics must not contain Thermodynamics questions. The audited source removed IDs 91, 101, 104, 119, 123, 129, 132, 138 and 166 because their content is Thermodynamics/Power Engineering.
3. Study Material definitions must be complete statements, not bare term labels.
4. Every technical topic must have matching study material and matching topic-filtered questions.
5. Study material video UI is video-only. Do not restore canvas animation, P-V/T-S/P-H diagrams, graph/curve placeholders or process animation.
6. Add Non-Technical as a separate section alongside Technical. Structure: Reasoning & Data Interpretation, Quantitative Aptitude, Constitution of India, Current Affairs, Comprehension.
7. Preserve all existing Your Progress storage, calculations and UI behavior. Do not reset, migrate or rename progress keys.
8. Non-Technical questions are syllabus-aligned practice/PYQ-pattern questions. Do not claim paraphrased questions are verbatim PYQs. Use assets/questions/pyq_sources.json for the 2025 paper reference.
9. Bakul Patel video resources are intended primarily for Non-Technical Maths/Reasoning/GS learning. Direct channel: https://www.youtube.com/@bhainskipathshala

## Verification
- flutter pub get
- dart format lib
- flutter analyze
- python tool/verify_mcqs.py (if supported by the project)
- verify every question subject/subTopic against the corresponding syllabus JSON.
- verify every study-material topic has at least one complete definition, matching questions, and video resource where configured.
- verify Your Progress data is untouched.
