/*

main idea:
- have a bunch of preset 'scenes' to populate
- each scene has flags and things as variant options

scene ideas:
- std-ish
    - pilot beside
    - pilot near front
    - shift left
    - more cars
- pilot shot
    - male/female
    - camera angle
- looking from rear of car forward (or flipped)
    - mb lined with pilots on side?
        - suit permutations
- country cars + pilots in sorta podium esq situation
- scrolling country cars
    - random order
    - ordered based on country alphabetical
        - randomized start position

*/

enum SceneFlags
    { FlipAlongZ = 1
    , ShiftLeft = 2
    , CarOnTurntable = 4
    , CarBreaking = 8
    , PilotInCar = 16
    , PilotBehindCar = 32
    , PilotFrontLeft = 64
    , SecondCar = 128
    , SecondCarPilot = 256
    , ThirdCar = 512
    , ThirdCarPilot = 1024
    , AuxCarsBoostToo = 2048
    , Car2OnTurntable = 4096
    , Car3OnTurntable = 8192
    , LastOption // this is used as an upper limit to generate random values
}

enum CamFlags
    { Standard = 1
    , FocusOnPilot = 2
    , LastOption
    }

class SceneRandomizer {
    uint sceneSeed;
    uint cameraSeed;

    SceneRandomizer() {
        // 8192, LO: 8193
        // print('before LO: ' + SceneFlags::Car3OnTurntable + '; LastOption: ' + SceneFlags::LastOption);
        ReInit();
    }

    void ReInit() {
        sceneSeed = SetSeed(Setting_SceneSeed);
        cameraSeed = SetSeed(Setting_CameraSeed);
    }

    uint SetSeed(uint settingsValue) const {
        if (settingsValue > 0) return settingsValue;
        uint s = 0;
        uint e = 0xFFFFFFFF;
        return uint(Math::Rand(s, e)) + 1;
    }
}
