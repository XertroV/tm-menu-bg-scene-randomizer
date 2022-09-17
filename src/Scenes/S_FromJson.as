    class S_FromJson : Scene {
    // config
    Json::Value@ JsonConfig;
    array<SceneItem@> SceneEntries;
    private uint MyVersion = 0;

    // MSM and consistent vars
    CGameMenuSceneScriptManager@ MenuSceneMgr;
    MwId SceneId;
    MwId CarItemId;

    // track state of menu to do init of scene, etc.
    bool HasCarId = false;
    bool ExpectCarIdNext = false;
    vec3 MM_CarPos;

    // state of scene for reference and cleanup
    MwId[] LocalItems;
    array<SyncdItem@> SyncdCars;
    // uint[] ItemIxsSyncdToMMCar;
    // vec3[] InitCarPositionsBySIx; // SIx == 'syncd inxex' via ItemIxsSyncdToMMCar (indexes of this array and that one correspond to the same local item)




    /*

    Class init and main util functions

     dP""b8 88        db    .dP"Y8 .dP"Y8     88 88b 88 88 888888
    dP   `" 88       dPYb   `Ybo." `Ybo."     88 88Yb88 88   88
    Yb      88  .o  dP__Yb  o.`Y8b o.`Y8b     88 88 Y88 88   88
     YboodP 88ood8 dP""""Yb 8bodP' 8bodP'     88 88  Y8 88   88

    */

    S_FromJson(const string &in jsonStr = "{}") {
        try {
            @JsonConfig = Json::Parse(jsonStr);
        } catch {
            NotifyFailure("Failed to parse JSON scene config.");
        }
    }

    void NotifyFailure(const string &in msg) {
        warn(msg);
        UI::ShowNotification("Scene 'FromJson' Error", msg, vec4(.9, .6, .1, .4), 10000);
    }

    uint get_Version() {
        return MyVersion;
    }

    /*

    MenuSceneManager events

    8b    d8 .dP"Y8 8b    d8     888888 Yb    dP 888888 88b 88 888888 .dP"Y8
    88b  d88 `Ybo." 88b  d88     88__    Yb  dP  88__   88Yb88   88   `Ybo."
    88YbdP88 o.`Y8b 88YbdP88     88""     YbdP   88""   88 Y88   88   o.`Y8b
    88 YY 88 8bodP' 88 YY 88     888888    YP    888888 88  Y8   88   8bodP'

    */

    /*
    - allow the car to be created and flag that we expect its ItemId to be used next.
    - block all other calls
    */

    bool OnItemCreate(CGameMenuSceneScriptManager@ msm, MwId SceneId, const string &in ModelName, const string &in SkinName, const string &in SkinUrl) override {
        if (!HasCarId) {
            ExpectCarIdNext = true;
            @this.MenuSceneMgr = msm;
            this.SceneId = SceneId;
            return true;
        }
        return false;
    }

    /*
    - always block the set location call.
    - keep track of the requested car position so that we can send that data thru to other cars if we want.
    */

    bool OnItemSetLocation(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable) override {
        if (!HasCarId && ExpectCarIdNext) {
            CarItemId = ItemId;
            HasCarId = true;
            msm.ItemDestroy(SceneId, CarItemId);
            auto newCar = CreateCarItem(); // IDs are re-used
            /* testing: are item IDs reused? yes. both have an id of `0` here.
            print("CarItemId: " + CarItemId.Value);
            msm.ItemDestroy(SceneId, CarItemId);
            print("newCarId: " + newCar.Value);
            */
        }
        // if we get a set location on the car, we want to pass this through to all cars that are syncd
        if (HasCarId && ItemId.Value == CarItemId.Value) {
            OnMenuScriptSetCarLocation(Position, AngleDeg, IsTurntable);
        }
        return false;
    }

    /*

    Scene logic and supporting functions

    .dP"Y8  dP""b8 888888 88b 88 888888     88      dP"Yb   dP""b8 88  dP""b8
    `Ybo." dP   `" 88__   88Yb88 88__       88     dP   Yb dP   `" 88 dP   `"
    o.`Y8b Yb      88""   88 Y88 88""       88  .o Yb   dP Yb  "88 88 Yb
    8bodP'  YboodP 888888 88  Y8 888888     88ood8  YbodP   YboodP 88  YboodP

    */

    void OnMenuScriptSetCarLocation(vec3 Position, float AngleDeg, bool IsTurntable) {
        // todo
        // when we get a new location, we want to translate that to one or more in-scene items, but we need
        // to account for the intial positions and rotations of those items.
    }











    void MainLoop() override {
        while (true) {
            yield();
        }
    }

    /*

    Scene and MenuSceneMgr helpers

    8b    d8 .dP"Y8 8b    d8     88  88 888888 88     88""Yb 888888 88""Yb .dP"Y8
    88b  d88 `Ybo." 88b  d88     88  88 88__   88     88__dP 88__   88__dP `Ybo."
    88YbdP88 o.`Y8b 88YbdP88     888888 88""   88  .o 88"""  88""   88"Yb  o.`Y8b
    88 YY 88 8bodP' 88 YY 88     88  88 888888 88ood8 88     888888 88  Yb 8bodP'

    */

    MwId CreateCarItem(const string &in SkinName = "Stadium_AUS", const string &in SkinUrl = "", SyncdItem@ reference = null) {
        string sfx = SkinName.EndsWith(".zip") ? "" : ".zip";
        auto newId = MenuSceneMgr.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\" + SkinName + sfx, SkinUrl);
        LocalItems.InsertLast(newId);
        // if (reference !is null)
        //     SyncdCars.InsertLast(); // LocalItems.Length will always be >= 0 b/c we just appended to it
        return newId;
    }

}

/*
goal: enable easy access to new positions/angles for cars in the scene.
time delay is a 'todo' feature.
*/
class SyncdItem {
    MwId itemId;
    vec3 pos; // in 'world-space'
    vec3 refPos; // in 'world-space'
    float angle; // in 'world-space'
    float refAngle; // in 'world-space'

    SyncdItem(MwId _itemId, vec3 _refPos, float _refAngle) { // we could add turn table too but is basically overhead -- can be an item setting if we care
        MwId itemId = _itemId;
        vec3 refPos = _refPos; // the reference position (initial MM car loc)
        float refAngle = _refAngle; // reference angle (initial MM car angle)
    }

    SyncdItem@ MkRefernce(MwId _itemId, vec3 _refPos, float _refAngle) const {
        auto ret = SyncdItem(_itemId, _refPos, _refAngle);
        ret.SetPosition(_refPos);
        ret.SetAngle(_refAngle);
        return ret;
    }

    SyncdItem@ FromReference(MwId _itemId, SyncdItem@ reference) const {
        return SyncdItem(_itemId, reference.refPos, reference.refAngle);
    }

    SyncdItem@ MkDuplicate() {
        return SyncdItem(itemId, refPos, refAngle);
    }


    void SetPosition(vec3 newPos) {
        pos = newPos;
    }

    void SetAngle(float newAngle) {
        angle = newAngle;
    }

    vec3 NextPosition(vec3 nextRefPos) { // can be optimized, but this version is clear
        auto posDelta = (nextRefPos - refPos) + (refPos - pos);
        return posDelta + pos;
    }
}

enum SItemType
    { CarSport
    , CharacterPilot
    }

class SceneItem {
    SceneItem() {

    }
}

class SItemProps {
    SItemProps() {}
}
