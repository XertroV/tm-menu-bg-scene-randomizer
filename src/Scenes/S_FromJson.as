[Setting hidden]
string Setting_Scene_FromJson_LastJsonConfig = "";

class S_FromJson : Scene {
    // config
    private string _settingsTmpConfig = "{}";
    array<SceneItem@> SceneItems;
    dictionary@ ItemLookup = {}; // UID -> SceneItem
    dictionary@ ItemStates = {}; // UID -> SItemState

    // array<SceneItem@> SceneEntries = {};
    private uint MyVersion = 0;

    // MSM and consistent vars
    CGameMenuSceneScriptManager@ MenuSceneMgr;
    MwId SceneId;
    MwId CarItemId;

    // track state of menu to do init of scene, etc.
    bool HasCarId = false;
    bool ExpectCarIdNext = false;
    vec3 MM_CarPos;

    // vec3 CameraLoc = vec3(InitCameraLoc);
    // vec2 CameraAngleFov = vec2(InitCameraAngle, InitCameraFov);
    SceneCamera@ Camera = SceneCamera();

    // state of scene for reference and cleanup
    // MwId[] LocalItems;

    // array<SyncdItem@> SyncdCars;
    // uint[] ItemIxsSyncdToMMCar;
    // vec3[] InitCarPositionsBySIx; // SIx == 'syncd inxex' via ItemIxsSyncdToMMCar (indexes of this array and that one correspond to the same local item)

#if DEV
    bool SceneBuilderAuxWindowVisible = true;
#else
    bool SceneBuilderAuxWindowVisible = false;
#endif

    /*

    Class init and main util functions

     dP""b8 88        db    .dP"Y8 .dP"Y8     88 88b 88 88 888888
    dP   `" 88       dPYb   `Ybo." `Ybo."     88 88Yb88 88   88
    Yb      88  .o  dP__Yb  o.`Y8b o.`Y8b     88 88 Y88 88   88
     YboodP 88ood8 dP""""Yb 8bodP' 8bodP'     88 88  Y8 88   88

    */

    S_FromJson(CGameMenuSceneScriptManager@ msm) {
        @this.MenuSceneMgr = msm;
        if (HasSavedSceneJson()) {
            _settingsTmpConfig = ReadSavedSceneJson();
        }
    }

    bool HasSavedSceneJson() { return Setting_Scene_FromJson_LastJsonConfig.Length > 0; }
    // seems like settings after the first line aren't saved.
    string ReadSavedSceneJson() {
        return Setting_Scene_FromJson_LastJsonConfig.Replace("\\n", "\n");
    }
    void WriteSavedSceneJson(const string &in s) {
        Setting_Scene_FromJson_LastJsonConfig = s.Replace("\n", "\\n");
        // trace("Wrote Setting_Scene_FromJson_LastJsonConfig: " + Setting_Scene_FromJson_LastJsonConfig);
    }

    void LoadJsonSceneConfig(const string &in config, bool canSleep = false) {
        if (config.Length == 0) return;
        trace('Json scene config: ' + config);
        auto jConfig = Json::Parse(config);
        // Camera = SceneCamera(jConfig['camera']);
        auto jItems = jConfig['items'];
        if (jItems.GetType() != Json::Type::Array) {
            NotifyFailure("config.items was not an array.");
        } else {
            // todo: load config
            for (uint i = 0; i < jItems.Length; i++) {
                LoadItem(SceneItem(jItems[i]));
                if (canSleep) yield();
            }
        }
    }

    const string GenerateSceneConfig() {
        // 1. camera, 2. items
        string _config = '{ "camera": ' + Json::Write(Camera.ToJson());
        _config += '\n, "items": ';
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            _config += (i > 0 ? "    , " : "\n    [ ") + Json::Write(item.ToJson()) + "\n";
        }
        _config += (SceneItems.Length > 0 ? "    ]" : "[]") + "\n";
        _config += "}";
        WriteSavedSceneJson(_config);
        _settingsTmpConfig = _config;
        trace('Generated new config:'); // + _settingsTmpConfig);
        return _config;
    }

    void NotifyFailure(const string &in msg) {
        warn(msg);
        UI::ShowNotification("Scene 'FromJson' Error", msg, vec4(.9, .6, .1, .4), 10000);
    }

    uint get_Version() {
        return MyVersion;
    }

    void RenderUI() override {
        if (SceneBuilderAuxWindowVisible)
            RenderAuxWindow();
    }

    /*

    MenuSceneManager events

    8b    d8 .dP"Y8 8b    d8     888888 Yb    dP 888888 88b 88 888888 .dP"Y8
    88b  d88 `Ybo." 88b  d88     88__    Yb  dP  88__   88Yb88   88   `Ybo."
    88YbdP88 o.`Y8b 88YbdP88     88""     YbdP   88""   88 Y88   88   o.`Y8b
    88 YY 88 8bodP' 88 YY 88     888888    YP    888888 88  Y8   88   8bodP'

    */

    bool OnSceneCreate(CGameMenuSceneScriptManager@ msm, const string &in Layout) override {
        @this.MenuSceneMgr = msm;
        return true;
    }

    void _RunInitScene() {
        // SceneId = MenuSceneMgr.SceneCreate(wstring("Empty"));
    }

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
            try {
                LoadJsonSceneConfig(ReadSavedSceneJson());
            } catch {
                NotifyFailure("Failed to parse JSON scene config.");
            }
            // auto newCar = CreateCarItem(); // IDs are re-used
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

    bool OnItemSetVehicleState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke) override {
        if (ItemId.Value == CarItemId.Value) {
            OnMenuScriptSetVehicleState(Steer, Brakes, FrontLight, TurboLvl, BoostLvl, BurnoutSmoke);
        } else {
            warn("Got OnItemSetVehicleState for unexpected item id: " + ItemId.Value);
        }
        return false;
    }

    bool HijackedScene = false;

    bool OnCameraSetLocation1(CGameMenuSceneScriptManager@ msm, MwId SceneId, vec3 Position, float AngleDeg, float FovY_Deg) override {
        if (!HijackedScene) {
            HijackedScene = true;
            msm.SceneDestroy(SceneId);
            auto nsid = msm.SceneCreate("Empty");
            trace('NewSceneId: ' + nsid.Value);
            return true;
        }
        return false;
    }


    bool OnCameraSetLocation0(CGameMenuSceneScriptManager@ msm, MwId SceneId, vec3 Position, float AngleDeg) override {return false;}
    bool OnCameraSetFromItem(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId) override {return false;}
    bool OnLightDir0Set(CGameMenuSceneScriptManager@ msm, MwId SceneId, vec3 sRGB, float Intensity) override {return false;}
    bool OnItemCreate0(CGameMenuSceneScriptManager@ msm, MwId SceneId, const string &in ModelName, const string &in SkinNameOrUrl) override {return false;}
    bool OnItemDestroy(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId) override {return false;}
    bool OnItemAttachTo(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, MwId ParentItemId) override {return false;}
    bool OnItemSetPlayerState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 LightrailColor, vec3 DossardColor, const string &in DossardNumber, const string &in DossardTrigram) override {return false;}

    /*

    Scene logic and supporting functions

    .dP"Y8  dP""b8 888888 88b 88 888888     88      dP"Yb   dP""b8 88  dP""b8
    `Ybo." dP   `" 88__   88Yb88 88__       88     dP   Yb dP   `" 88 dP   `"
    o.`Y8b Yb      88""   88 Y88 88""       88  .o Yb   dP Yb  "88 88 Yb
    8bodP'  YboodP 888888 88  Y8 888888     88ood8  YbodP   YboodP 88  YboodP

    */

    void OnMenuScriptSetVehicleState(float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke) {

    }

    void OnMenuScriptSetCarLocation(vec3 Position, float AngleDeg, bool IsTurntable) {
        // todo
        // when we get a new location, we want to translate that to one or more in-scene items, but we need
        // to account for the intial positions and rotations of those items.
    }





    private bool anyChanged = false;  // track if anything was changed by the user this loop -- need to know so we can update json
    // avoid calling MenuSceneMgr stuff here -- it's for background stuff.
    // Scene updates should be done in Update();
    void MainLoop() override {
        while (true) {
            yield();
            if (anyChanged) {
                // todo
                trace('change detected');
                anyChanged = false;
                GenerateSceneConfig();
            }
        }
    }

    private float t = Time::Now;  // global time
    uint lastLog = uint(Time::Now / 1000);  // for rate limiting update calls
    void Update(float dt) override {
        t += dt;
        if (uint(Math::Floor(t / 1000)) > lastLog) {
            // trace('Update called; dt=' + dt);
            lastLog++;
        }
        if (MenuSceneMgr !is null) {
            MenuSceneMgr.CameraSetLocation1(SceneId, Camera.pos, Camera.angle, Camera.fov);
            SetAllItemPositions();
        }
    }

    void SetAllItemPositions() {
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            if (item.visible) {
                auto state = GetItemState(item);
                MenuSceneMgr.ItemSetLocation(SceneId, state.ItemId, item.pos, item.angle, item.tt);
                // trace("Set item " + state.ItemId.Value + " location to " + item.pos.ToString());
            }
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
        // LocalItems.InsertLast(newId);
        // if (reference !is null)
        //     SyncdCars.InsertLast(); // LocalItems.Length will always be >= 0 b/c we just appended to it
        return newId;
    }

    void ReloadScene() {
        NotifyFailure("ReloadScene currently bugged. Better to go to a new menu and back.");
        string config = GenerateSceneConfig();
        RemoveAllItems();
        MenuSceneMgr.SceneDestroy(SceneId);
        SceneId = MenuSceneMgr.SceneCreate("Empty"); // "Stadium" breaks the game; "Default" sorta works but need to set up bg reflections and camera and things
        trace('Reloaded Scene ID: ' + SceneId.Value);
        LoadJsonSceneConfig(config);
    }

    void LoadItem(SceneItem@ item) {
        // todo: other logic about creating the item in the scene, etc
        bool firstItem = SceneItems.Length == 0;
        SceneItems.InsertLast(@item);
        ItemLookup[item.uid] = @item;
        AddToScene(item);
        if (firstItem) selectedUid = item.uid;
        // todo: regen config
        anyChanged = true;
    }

    void RemoveAllItems() {
        while (SceneItems.Length > 0) {
            RemoveItem(SceneItems[0]);
        }
    }

    void RemoveItem(SceneItem@ item) {
        // if (SceneItems[ix] != item) {
        //     ErrorAndThrow('Tried to remove a scene item with a mismatching index');
        // }
        if (item.visible)
            RemoveFromScene(item);
        ItemLookup.Delete(item.uid);
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto _item = SceneItems[i];
            if (item.uid == _item.uid) {
                SceneItems.RemoveAt(i);
                break;
            }
        }
        anyChanged = true;
    }

    void RemoveFromScene(SceneItem@ item) {
        // todo: handle
        warn("todo: handle attached and/or otherwise interconnected items.");
        auto state = GetItemState(item);
        trace('Removing item ' + state.ItemId.Value + ' from scene ' + state.SceneId.Value);
        MenuSceneMgr.ItemDestroy(state.SceneId, state.ItemId);
        ItemStates.Delete(item.uid);
    }

    void ToggleItemVisibility(SceneItem@ item) {
        item.visible = !item.visible;
        item.visible ? AddToScene(item) : RemoveFromScene(item);
    }

    void AddToScene(SceneItem@ item) {
        if (ItemStates.Exists(item.uid)) throw("Called AddToScene on an item that exists.");
        if (!item.visible) throw("Called AddToScene on an non-visible item.");
        auto id = _AddToSceneRaw(item);
        ItemStates[item.uid] = @SItemState(SceneId, id);
    }

    private MwId _AddToSceneRaw(SceneItem@ item) {
        // custom meshes are character pilots
        auto ty = item.type == SItemType::CustomMesh ? SItemType::CharacterPilot : item.type;
        // the dir that skins must be in
        bool isPilot = ty == SItemType::CharacterPilot;
        auto _skinDir = isPilot ? "HelmetPilot" : "CarSport";
        auto _skinZip = item.skinZip.Length > 0 ? item.skinZip : (isPilot ? "StadiumFemale.zip" : "Stadium_AUS.zip");
        auto id = MenuSceneMgr.ItemCreate(SceneId, tostring(ty), "Skins\\Models\\" + _skinDir + "\\" + _skinZip, item.skinUrl);
        trace("_AddToSceneRaw: " + string::Join({tostring(SceneId.Value), tostring(ty), "Skins\\Models\\" + _skinDir + "\\" + _skinZip, "=>", tostring(id.Value)}, ", "));
        return id;
    }

    void OnItemTypeChanged(SceneItem@ item) {
        auto state = GetItemState(item);
        if (state is null) return;
        // remove old item from scene
        auto oldId = state.ItemId;
        MenuSceneMgr.ItemDestroy(SceneId, state.ItemId);
        // add new item to scene and update state
        state.ItemId = _AddToSceneRaw(item);
        // trace("Item Type Changed; oldId:" + oldId.Value + ", newId:" + state.ItemId.Value);
    }

    SItemState@ GetItemState(SceneItem@ item) {
        return cast<SItemState>(ItemStates[item.uid]);
    }

    // void Template(SceneItem@ item) {}

    /*

    Scene settings

    .dP"Y8 888888 888888 888888 88 88b 88  dP""b8 .dP"Y8
    `Ybo." 88__     88     88   88 88Yb88 dP   `" `Ybo."
    o.`Y8b 88""     88     88   88 88 Y88 Yb  "88 o.`Y8b
    8bodP' 888888   88     88   88 88  Y8  YboodP 8bodP'

    */


    void RenderSceneSettings() override {
        Heading("Scene Builder");
        DrawSceneBuilderUtilButtons();
        UI::Separator();
        RenderSettingsJson();

        PaddedSep();
        SubHeading("Scene Items");
        RenderSceneBuilder();
    }

    void DrawSceneBuilderUtilButtons() {
        // bool reloadScene = UI::Button(Icons::FloppyO + Icons::TrashO + Icons::Refresh);
        // AddSimpleTooltip("Save the current scene and completely reload it.\n\\$888(Useful if the scene becomes glitched.)");
        // if (reloadScene) ReloadScene();
    }


    private uint lastCopy = 0;

    void RenderSettingsJson() {
        SubHeading("Scene Config");

        UI::Dummy(vec2(30, 0));
        UI::SameLine();
        bool justCopied = (lastCopy + 2000) > Time::Now;
        bool copySceneConfig = MDisabledButton(justCopied, justCopied ? "Scene Config Copied!" : "Copy Scene Config", vec2(150, UI::GetFrameHeight()));
        SameLineWithDummyX(30);
        bool shouldLoadConfig = UI::Button("Load Scene Config", vec2(150, UI::GetFrameHeight()));
        UI::Text("\\$f91Todo: cache json to avoid long frame times");

        // todo: update saved config each time scene is altered + allow for changes to be made to the textbox
        // sorta manual formatting so it's kinda pretty printed.
        // string _config = GenerateSceneConfig();

        // main text for config import/export
        _settingsTmpConfig = UI::InputTextMultiline("##S_FromJson-json-spec", _settingsTmpConfig, vec2(Math::Min(600, UI::GetContentRegionAvail().x), 130), DisabledMultlineInputFlags());

        if (copySceneConfig) {
            IO::SetClipboard(_settingsTmpConfig);
            lastCopy = Time::Now;
        }

        if (shouldLoadConfig) {
            // RemoveAllItems();
            // LoadJsonSceneConfig(_settingsTmpConfig);
            startnew(CoroutineFunc(ReloadFromConfigCoro));
        }
    }

    void ReloadFromConfigCoro() {
        while (SceneItems.Length > 0) {
            RemoveItem(SceneItems[0]);
            yield();
        }
        LoadJsonSceneConfig(_settingsTmpConfig, true);
    }

    UI::InputTextFlags DisabledMultlineInputFlags() {
        return UI::InputTextFlags(
              UI::InputTextFlags::None
            // | UI::InputTextFlags::ReadOnly
            | UI::InputTextFlags::AutoSelectAll
            | UI::InputTextFlags::AllowTabInput
        );
    }

    /*

    Scene Builder

    88""Yb 88   88 88 88     8888b.  888888 88""Yb
    88__dP 88   88 88 88      8I  Yb 88__   88__dP
    88""Yb Y8   8P 88 88  .o  8I  dY 88""   88"Yb
    88oodP `YbodP' 88 88ood8 8888Y"  888888 88  Yb

    */

    private string selectedUid = "";

    bool ItemIsSelected(SceneItem@ item) {
        return selectedUid == item.uid;
    }

    bool IsAnyItemSelected() {
        return selectedUid.Length > 0 && ItemLookup.Exists(selectedUid);
    }

    SceneItem@ GetSelectedItem() {
        return cast<SceneItem>(ItemLookup[selectedUid]);
    }

    // ui gets laggy (30ms frame times) around 36 entries for me

    void RenderSceneBuilder() {
        /* we start with a tool bar so do some calculations about dimensions and things.
        layout: [b1] [button]                          [b3] [b4] [b5] [b6]
         */

        vec2 bDims = vec2(30, 30);
        float xSep = 10; // how far apart are 2 buttons
        uint rightButtons = 4;
        float rbWidth = (rightButtons) * bDims.x + (rightButtons) * xSep;
        float xSpaceLeft = UI::GetContentRegionAvail().x - rbWidth - bDims.x - xSep;
        bool isItemSelected = IsAnyItemSelected();

        bool addItem = UI::Button(Icons::Plus, bDims);
        AddSimpleTooltip("Add Item");
        // xSpaceLeft -= bDims.x;
        if (isItemSelected) {
            UI::SameLine();
            SceneBuilderAuxWindowVisible = MDisabledButton(SceneBuilderAuxWindowVisible, "Show Item Properties", vec2(150, 30))
                || SceneBuilderAuxWindowVisible;
            xSpaceLeft -= 150 + xSep;
        }
        UI::SameLine();
        UI::Dummy(vec2(xSpaceLeft, 0));
        UI::SameLine();
        // alt icons: Icons::ArrowUp, Icons::ChevronUp, Icons::ArrowCircleUp, Icons::CaretUp, Icons::ChevronCircleUp
        bool moveWayUp = MDisabledButton(!isItemSelected, Icons::AngleDoubleUp, bDims);
        AddSimpleTooltip("Move to Top");
        UI::SameLine();
        bool moveUp = MDisabledButton(!isItemSelected, Icons::AngleUp, bDims);
        AddSimpleTooltip("Move Up");
        UI::SameLine();
        bool moveDown = MDisabledButton(!isItemSelected, Icons::AngleDown, bDims);
        AddSimpleTooltip("Move Down");
        UI::SameLine();
        bool moveWayDown = MDisabledButton(!isItemSelected, Icons::AngleDoubleDown, bDims);
        AddSimpleTooltip("Move to Bottom");


        if (addItem) {
            LoadItem(DefaultSceneItem());
        }


        // UI::Separator();
        PaddedSep();

        int nCols = 5;

        // // note: initially I went with a table b/c I know them,
        // // but I decided to go with columns after trying them out
        // // and with AlignTextToFramePadding worked as expected.
        // // the following table code is legacy.
        // auto tFlags = UI::TableFlags::None
        //     | UI::TableFlags::Borders
        //     | UI::TableFlags::SizingStretchProp
        //     | UI::TableFlags::PadOuterX
        //     ;
        // if (UI::BeginTable("s-fromjson-scene-builder-table", nCols, tFlags)) {
        //     UI::TableSetupColumn("UID");
        //     UI::TableSetupColumn("Name");
        //     UI::TableSetupColumn("Type");
        //     UI::TableSetupColumn("Selected"); // button if not selected,
        //     UI::TableSetupColumn("Options"); // hide / delete
        //     UI::PushFont(stdBold);
        //     UI::TableHeadersRow();
        //     UI::PopFont();
        //     UI::EndTable();
        // }

        // PaddedSep();

        // -1 b/c hide UID
        UI::Columns(nCols-1, "s-fromjson-scene-builder-cols", false);

        // ColHeading("UID");
        // ForEachItem(function(SceneItem@ item) {
        //     bool s = cast<S_FromJson>(CurrentScene).ItemIsSelected(item);
        //     UI::AlignTextToFramePadding();
        //     UI::Text((s ? "\\$9e3" : "") + item.uid + "\\$z");
        // });
        // UI::NextColumn();

        ColHeading("Name");
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            UI::AlignTextToFramePadding();
            item.name = UI::InputText("##item-name-" + item.uid, item.name);
        }

        UI::NextColumn();
        ColHeading("Type");
        ForEachItem(function(SceneItem@ item) {
            UI::AlignTextToFramePadding();
            cast<S_FromJson>(CurrentScene).DrawSelectItemType(item);
        });

        UI::NextColumn();
        ColHeading("Selected");
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            if (selectedUid == item.uid) {
                UI::AlignTextToFramePadding();
                UI::Text(Icons::Check);
                UI::SameLine();
                UI::AlignTextToFramePadding();
                bool deselect = UI::Button(Icons::Ban + "##" + item.uid);
                AddSimpleTooltip("Deselect item.");
                if (deselect) selectedUid = "";
            } else {
                if (UI::Button("Select##" + item.uid)) {
                    selectedUid = item.uid;
                    SceneBuilderAuxWindowVisible = true;
                }
            }
        };

        UI::NextColumn();
        ColHeading("Options");
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            DrawItemVisibilityButton(item);
            UI::SameLine();
            DrawItemDeleteButton(item);
        };

        UI::Columns(1);

    }

    void DrawItemDeleteButton(SceneItem@ item) {
        bool deleteThisItem = UI::Button(Icons::Trash + "##" + item.uid);  // alt: Icons::TrashO
        AddSimpleTooltip("Remove Item");
        if (deleteThisItem)
            RemoveItem(item);
    }

    void DrawItemVisibilityButton(SceneItem@ item) {
        UI::AlignTextToFramePadding();
        bool toggleVisibility = ButtonVariant(!item.visible, item.uid, Icons::Eye, Icons::EyeSlash, vec4(.7, .4, .1, 1) * .85);
        AddSimpleTooltip(item.visible ? "Hide" : "Show");
        if (toggleVisibility) {
            ToggleItemVisibility(item);
        }
    }



    void DrawSelectItemType(SceneItem@ item, bool showTypeLabel = false) {
        if (showTypeLabel) {
            UI::AlignTextToFramePadding();
            UI::Text("Type:");
            UI::SameLine();
        }
        if (UI::BeginCombo("##item-type-" + item.uid, tostring(item.type))) {
            for (uint i = 0; i < AllItemTypes.Length; i++) {
                auto ty = AllItemTypes[i];
                if (UI::Selectable(tostring(ty), ty == item.type)) {
                    bool typeChanged = item.type != ty;
                    item.type = ty;
                    if (typeChanged) OnItemTypeChanged(item);
                }
            }
            UI::EndCombo();
        }
    }

    private vec2 propsWindowSize = vec2(400, 400); // used to calculate size of children
    private float xRatioItemList = .3;
    private float xRatioItemProps = 1 - xRatioItemList;
    // a window with 2 partitions: a list of items on the left, and the selected item's properties on the right
    void RenderAuxWindow() {
        if (UI::Begin("Scene Builder Item Properties", SceneBuilderAuxWindowVisible, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize)) {
            UI::PushStyleVar(UI::StyleVar::ChildBorderSize, 1.0);
            UI::PushStyleColor(UI::Col::Border, vec4(.8, .8, .8, .8));
            bool border = true;
            if (UI::BeginChild("##item-props-item-select", propsWindowSize * vec2(xRatioItemList, 1), border)) {
                ColHeading("Items:", false);
                SameLineWithDummyX(28);
                if (TinyButton("+##ip-add-item")) LoadItem(DefaultSceneItem());
                UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(0,0));
                if (UI::BeginChild("##ip-list-of-items", UI::GetContentRegionAvail(), false)) {
                    DrawShortListOfItems();
                }
                UI::EndChild();
                UI::PopStyleVar();
            }
            UI::EndChild();

            UI::SameLine();
            if (UI::BeginChild("##item-props-main", propsWindowSize * vec2(xRatioItemProps, 1), false)) {
                DrawSelectedItemProperties();
            }
            UI::EndChild();
            UI::PopStyleColor();
            UI::PopStyleVar(1);
            // RenderSceneBuilder(); // debug: draw this in the item props window
        }
        UI::End();
    }

    void ForEachItem(SceneItemFunc@ f) {
        for (uint i = 0; i < SceneItems.Length; i++) {
            f(SceneItems[i]);
        }
    }

    SceneItem@ DefaultSceneItem() {
        return SceneItem(GenUID(), "Item " + SceneItems.Length, SItemType::CarSport, true, vec3(-.8, 0, -2), 180, false, true, MaybeOfString(), "", "", 1);
    }

    void DrawShortListOfItems() {
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            if (SelectablePseudoButton("item-quick-select-" + item.uid, item.name, ItemIsSelected(item), true)) {
                selectedUid = item.uid;
            }
        }
    }

    void DrawSelectedItemProperties() {
        if (!IsAnyItemSelected()) {
            UI::Text("Please select an item.");
            return;
        }
        auto item = GetSelectedItem();
        ColHeading("Item Properties: " + item.name);
        // utility buttons
        // - visibility, delete, copy(?), refresh skin, help(?), <other buttons?>
        DrawItemOperationButtons(item);
        VPad();

        if (true || UI::CollapsingHeader("Type, Name, Skin")) {
            // top rows:
            // - item name
            // - item type
            // - SkinZip
            // - SkinUrl (for cars only)
            DrawSelectItemType(item, true);
            item.name = DrawIPTextInput("item-name-" + item.uid, "Name:", item.name);
            item.skinZip = DrawIPTextInput("item-skinZip-" + item.uid, "Skin.zip:", item.skinZip);
            if (item.type == SItemType::CarSport)
                item.skinUrl = DrawIPTextInput("item-skinUrl-" + item.uid, "Skin URL:", item.skinUrl);
            else if (item.type == SItemType::CharacterPilot)
                DrawItemAttachProps(item);

        }
        // groups:
        // - position: x,y,z,delta
        // - angle: theat, checkbox for turntable
        VPad();
        DrawItemPositionProps(item);
        DrawItemStepAdjustment();
        VPad();
        DrawItemAngleProps(item);
        // general function rows / extra
        // - copy position + angle from another item
        // - attach to another item
        DrawItemAttachProps(item);
        // DrawItemCopyPosProps(item);
    }

    string DrawIPTextInput(const string &in id, const string &in label, const string &in value) {
        bool changed = false;
        UI::AlignTextToFramePadding();
        UI::Text(label);
        UI::SameLine();
        auto ret = UI::InputText("##" + id, value, changed);
        anyChanged = anyChanged || changed;
        return ret;
    }

    private float itemPropFloatInputW = 120;
    private float itemPropFloatLabelW = 30;
    float DrawIPropFloatInput(const string &in id, const string &in label, float value, float step = 0.1, const string &in tooltip = "") {
        auto tl = UI::GetCursorPos();
        UI::AlignTextToFramePadding();
        UI::Text(label);
        if (tooltip.Length > 0) AddSimpleTooltip(tooltip);
        UI::SetCursorPos(tl + vec2(itemPropFloatLabelW, 0));
        UI::SetNextItemWidth(itemPropFloatInputW);
        auto ret = UI::InputFloat("##" + id + label, value, step);
        if (Math::Abs(value - ret) > 0.0001) anyChanged = true;
        return ret;
    }

    private float itemPropAdjustmentStep = 0.1;
    void DrawItemPositionProps(SceneItem@ item) {
        auto pos = item.pos;  // if we just replace 'pos' with 'item.pos' below we get the error: 'expression is not an l-value'
        pos.x = DrawIPropFloatInput(item.uid, "  x:", pos.x, itemPropAdjustmentStep);
        pos.y = DrawIPropFloatInput(item.uid, "  y:", pos.y, itemPropAdjustmentStep);
        pos.z = DrawIPropFloatInput(item.uid, "  z:", pos.z, itemPropAdjustmentStep);
        // if ((pos - item.pos).LengthSquared() > 0.0001) anyChanged = true;
        item.pos = pos;
    }
    void DrawItemStepAdjustment() {
        float prevIPAS = itemPropAdjustmentStep;
        itemPropAdjustmentStep = DrawIPropFloatInput("step-adjustment", "|Δ|", itemPropAdjustmentStep, 1, "Adjustment size for\n[+] and [-] buttons.");
        if (prevIPAS < itemPropAdjustmentStep) {
            itemPropAdjustmentStep = Math::Min(2.0, prevIPAS * 2);
        } else if (prevIPAS > itemPropAdjustmentStep) {
            itemPropAdjustmentStep = Math::Max(0.001, prevIPAS / 2);
        }
    }
    void DrawItemAngleProps(SceneItem@ item) {
        bool prevTt = item.tt;
        item.angle = DrawIPropFloatInput(item.uid, "  θ:", item.angle, 1, "Angle");
        item.tt = UI::Checkbox("Rotating?##" + item.uid, item.tt);
        if (item.tt != prevTt) anyChanged = true;
    }
    void DrawItemAttachProps(SceneItem@ item) {}
    void DrawItemSkinProps(SceneItem@ item) {}

    void DrawItemOperationButtons(SceneItem@ item) {
        DrawItemRegenButton(item);
        UI::SameLine();
        DrawItemVisibilityButton(item);
        UI::SameLine();
        DrawItemDuplicateButton(item);
        SameLineWithDummyX(100);
        DrawItemDeleteButton(item);
    }

    void DrawItemRegenButton(SceneItem@ item) {
        bool doRegen = MDisabledButton(!item.visible, Icons::Refresh + "##ips-type-regen");
        AddSimpleTooltip("Remove and re-add the in-scene item.\n\\$888(Useful if the item glitches.)");
        if (doRegen) {
            OnItemTypeChanged(item); // we reload the item in full
        }
    }

    void DrawItemDuplicateButton(SceneItem@ item) {
        bool duplicate = UI::Button(Icons::FilesO + "##ips-duplicate");
        AddSimpleTooltip("Duplicate");
        if (duplicate) {
            NotifyFailure("todo: implement duplication");
            // OnItemTypeChanged(item);
        }
    }
}

funcdef void SceneItemFunc(SceneItem@ item);

uint RandUint() {
    uint a = uint(Math::Rand(-0x7FFFFFFF, 0x7FFFFFFF)); // uint(-392_112_762) == 3_902_854_534; works as expected
    // print("Rand bounds: " + (-0x7FFFFFFF) + ", " + 0x7FFFFFFF + "; val = " + a + ", " + uint(a) + ", " + uint8(a));
    return a;
}

const string GenUID() {
    uint a = RandUint();
    string uid = "01234567";
    for (int i = 0; i < uid.Length; i++) {
        uid[i] = ToSingleHexCol(a >> (4*i));
    }
    return uid.SubStr(0, 3) + "-" + uid.SubStr(3, 5);
}

uint8 ToSingleHexCol(uint v) {
    uint8 u = v % 16;
    if (u < 10) { return 48 + u; }  /* 48 = '0' */
    return 87 + u;  /* u>=10 and 97 = 'a' */
}

void ErrorAndThrow(const string &in msg) {
    UI::ShowNotification("Menu BG Scene", msg, vec4(.5, .0, .0, .5), 10000);
    warn(msg);
    throw(msg);
}

const SItemType[] AllItemTypes = {SItemType::CarSport, SItemType::CharacterPilot, SItemType::CustomMesh};

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

// class SItemProps {
//     SItemProps() {}
// }

// tracks scene info like ItemId
class SItemState {
    private MwId _SceneId;
    private MwId _ItemId;

    SItemState(MwId _SceneId, MwId _ItemId) {
        this._SceneId = _SceneId;
        this._ItemId = _ItemId;
    }

    MwId get_SceneId() { return _SceneId; }
    MwId get_ItemId() { return _ItemId; }
    void set_ItemId(MwId NewItemId) { _ItemId = NewItemId; }
}

class SceneCamera : SceneItem {
    float fov = InitCameraFov;
    SceneCamera() {
        super("camera", "Camera", SItemType::CustomMesh, false, InitCameraLoc, InitCameraAngle, false, false, MaybeOfString(), "", "", 1);
    }

    SceneCamera(Json::Value &in j) {
        fov = float(j['fov']);
        super(j);

    }

    Json::Value ToJson() override {
        auto j = SceneItem::ToJson();
        j['fov'] = this.fov;
        return j;
    }
}
