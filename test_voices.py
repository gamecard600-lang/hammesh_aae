import asyncio
import edge_tts

text = "નમસ્તે મિત્રો, થર્મોડાયનેમિક્સમાં આજે આપણે થર્મોડાયનેમિક સિસ્ટમ અને કંટ્રોલ વોલ્યુમ વિશે ખૂબ જ સરળ રીતે સમજીશું."

async def main():
    # 1. Female Neural Voice (gu-IN-DhwaniNeural)
    print("🎙️ Testing gu-IN-DhwaniNeural (Female Natural Voice)...")
    comm1 = edge_tts.Communicate(text, "gu-IN-DhwaniNeural", rate="-3%")
    await comm1.save("assets/videos/voice_dhwani.mp3")

    # 2. Male Neural Voice with smooth pitch (gu-IN-NiranjanNeural)
    print("🎙️ Testing gu-IN-NiranjanNeural (Male Natural Voice)...")
    comm2 = edge_tts.Communicate(text, "gu-IN-NiranjanNeural", rate="-4%", pitch="+1Hz")
    await comm2.save("assets/videos/voice_niranjan.mp3")

    print("✅ Generated voice test files!")

if __name__ == "__main__":
    asyncio.run(main())
