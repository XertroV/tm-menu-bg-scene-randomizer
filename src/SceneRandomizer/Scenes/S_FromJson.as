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

    // state of scene for reference and cleanup
    MwId[] LocalItems;
    uint[] ItemsSyncdToCar;

    /*

    Class init and main util functions

     dP""b8 88        db    .dP"Y8 .dP"Y8     88 88b 88 88 888888
    dP   `" 88       dPYb   `Ybo." `Ybo."     88 88Yb88 88   88
    Yb      88  .o  dP__Yb  o.`Y8b o.`Y8b     88 88 Y88 88   88
     YboodP 88ood8 dP""""Yb 8bodP' 8bodP'     88 88  Y8 88   88

    */

    S_FromJson(const string &in jsonStr = "{}") {
        try {
            JsonConfig = Json::Parse(jsonStr);
        } catch {
            NotifyFailure("Failed to parse JSON scene config.");
        }

        startnew(CoroutineFunc(MainLoop));
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
            // testing
            print("CarItemId: " + CarItemId.Value);
            msm.ItemDestroy(SceneId, CarItemId);
            // auto newCar = CreateCarItem();
            // print("newCarId: " + newCar.Value);
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
    }











    void MainLoop() {
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

    MwId CreateCarItem(const string &in SkinName = "Stadium_AUS", const string &in SkinUrl = "") {
        string sfx = SkinName.EndsWith(".zip") ? "" : ".zip";
        return MenuSceneMgr.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\" + SkinName + sfx, SkinUrl);
    }

}

class SceneItem {

}
