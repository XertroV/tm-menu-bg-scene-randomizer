    class S_FromJson : Scene {
    // config
    Json::Value@ JsonConfig;
    array<SceneItem@> SceneItems;
    dictionary@ ItemLookup = {}; // UID -> SceneItem

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

    // state of scene for reference and cleanup
    MwId[] LocalItems;

    // array<SyncdItem@> SyncdCars;
    // uint[] ItemIxsSyncdToMMCar;
    // vec3[] InitCarPositionsBySIx; // SIx == 'syncd inxex' via ItemIxsSyncdToMMCar (indexes of this array and that one correspond to the same local item)

    bool SceneBuilderAuxWindowVisible = false;

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





    bool anyChanged = false;  // track if anything was changed by the user this loop -- need to know so we can update json

    void MainLoop() override {
        while (true) {
            yield();
            if (anyChanged) {
                // todo
                anyChanged = false;
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
        LocalItems.InsertLast(newId);
        // if (reference !is null)
        //     SyncdCars.InsertLast(); // LocalItems.Length will always be >= 0 b/c we just appended to it
        return newId;
    }

    void LoadItem(SceneItem@ item) {
        // todo: other logic about creating the item in the scene, etc
        SceneItems.InsertLast(@item);
        ItemLookup[item.uid] = @item;
        // todo: regen config
    }

    void RemoveItem(uint ix, SceneItem@ item) {
        if (SceneItems[ix] != item) {
            ErrorAndThrow('Tried to remove a scene item with a mismatching index');
        }
        // todo: handle
        warn("todo: handle attached and/or otherwise interconnected items.");
        ItemLookup.Delete(item.uid);
        SceneItems.RemoveAt(ix);
        // todo: call ItemDestroy
    }

    void ToggleItemVisibility(SceneItem@ item) {
        item.visible = !item.visible;
        (item.visible ? SceneItemFunc(AddToScene) : SceneItemFunc(RemoveFromScene))(item);
    }

    void AddToScene(SceneItem@ item) {
        MenuSceneMgr.ItemCreate(SceneId, tostring(item.type), item.skinZip, item.skinUrl);
    }

    void RemoveFromScene(SceneItem@ item) {

    }

    /*

    Scene settings

    .dP"Y8 888888 888888 888888 88 88b 88  dP""b8 .dP"Y8
    `Ybo." 88__     88     88   88 88Yb88 dP   `" `Ybo."
    o.`Y8b 88""     88     88   88 88 Y88 Yb  "88 o.`Y8b
    8bodP' 888888   88     88   88 88  Y8  YboodP 8bodP'

    */


    void RenderSceneSettings() override {
        Heading("Scene Builder");
        UI::Separator();
        RenderSettingsJson();

        PaddedSep();
        SubHeading("Scene Items");
        RenderSceneBuilder();
    }

    private uint lastCopy = 0;

    void RenderSettingsJson() {
        SubHeading("Scene Config");

        UI::Dummy(vec2(30, 0));
        UI::SameLine();
        bool justCopied = (lastCopy + 2000) > Time::Now;
        bool copySceneConfig = MDisabledButton(justCopied, justCopied ? "Scene Config Copied!" : "Copy Scene Config", vec2(150, UI::GetFrameHeight()));
        UI::SameLine();
        UI::Dummy(vec2(30, 0));
        UI::SameLine();
        bool shouldLoadConfig = UI::Button("Load Scene Config", vec2(150, UI::GetFrameHeight()));

        auto j = Json::Array();
        for (uint i = 0; i < SceneItems.Length; i++) {

        }

        // sorta manual formatting so it's kinda pretty printed.
        string _config = "";
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            _config += (i > 0 ? ", " : "[ ") + Json::Write(item.ToJson()) + "\n";
        }
        _config += (SceneItems.Length > 0 ? "" : "[") + "]";

        // main text for config import/export
        string config = UI::InputTextMultiline("##S_FromJson-json-spec", _config, vec2(Math::Min(600, UI::GetContentRegionAvail().x), 130), DisabledMultlineInputFlags());

        if (copySceneConfig) {
            IO::SetClipboard(config);
            lastCopy = Time::Now;
        }

        if (shouldLoadConfig) {
            auto jConfig = Json::Parse(config);
            auto jItems = jConfig['items'];
            if (jItems.GetType() != Json::Type::Array) {
                // handle error
            } else {
                // todo: load config
                for (uint i = 0; i < jItems.Length; i++) {
                    LoadItem(SceneItem(jItems[i]));
                }
            }
        }
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

    void RenderSceneBuilder() {
        /* we start with a tool bar so do some calculations about dimensions and things.
        layout: [b1] [button]                          [b3] [b4] [b5] [b6]
         */

        vec2 bDims = vec2(30, 30);
        float xSep = 10; // how far apart are 2 buttons
        uint rightButtons = 4;
        float rbWidth = (rightButtons) * bDims.x + (rightButtons) * xSep;
        float xSpaceLeft = UI::GetContentRegionAvail().x - rbWidth - bDims.x - xSep;

        bool isItemSelected = selectedUid.Length > 0 && ItemLookup.Exists(selectedUid);

        bool addItem = UI::Button(Icons::Plus, bDims);
        AddSimpleTooltip("Add Item");
        // xSpaceLeft -= bDims.x;
        if (isItemSelected) {
            UI::SameLine();
            SceneBuilderAuxWindowVisible = SceneBuilderAuxWindowVisible
                || MDisabledButton(!SceneBuilderAuxWindowVisible, "Show Item Properties", vec2(150, 30));
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

        // UI::Separator();
        PaddedSep();

        int nCols = 5;

        auto tFlags = UI::TableFlags::None
            | UI::TableFlags::Borders
            | UI::TableFlags::SizingStretchProp
            | UI::TableFlags::PadOuterX
            ;
        if (UI::BeginTable("s-fromjson-scene-builder-table", nCols, tFlags)) {
            UI::TableSetupColumn("UID");
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("Type");
            UI::TableSetupColumn("Selected"); // button if not selected,
            UI::TableSetupColumn("Options"); // hide / delete
            UI::PushFont(stdBold);
            UI::TableHeadersRow();
            UI::PopFont();
            UI::EndTable();
        }

        PaddedSep();

        UI::Columns(nCols, "s-fromjson-scene-builder-cols", false);

        ColHeading("UID");
        ForEachItem(function(SceneItem@ item) {
            bool s = cast<S_FromJson>(CurrentScene).ItemIsSelected(item);
            UI::AlignTextToFramePadding();
            UI::Text((s ? "\\$9e3" : "") + item.uid + "\\$z");
        });

        UI::NextColumn();
        ColHeading("Name");
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            UI::AlignTextToFramePadding();
            item.name = UI::InputText("##item-name-" + item.uid, item.name, anyChanged);
        }

        UI::NextColumn();
        ColHeading("Type");
        ForEachItem(function(SceneItem@ item) {
            UI::AlignTextToFramePadding();
            if (UI::BeginCombo("##item-type-" + item.uid, tostring(item.type))) {
                for (uint i = 0; i < AllItemTypes.Length; i++) {
                    auto ty = AllItemTypes[i];
                    if (UI::Selectable(tostring(ty), ty == item.type)) {
                        item.type = ty;
                    }
                }
                UI::EndCombo();
            }
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
                }
            }
        };

        UI::NextColumn();
        ColHeading("Options");
        for (uint i = 0; i < SceneItems.Length; i++) {
            auto item = SceneItems[i];
            bool isSelected = selectedUid == item.uid;

            UI::AlignTextToFramePadding();
            bool toggleVisibility = ButtonVariant(!item.visible, item.uid, Icons::Eye, Icons::EyeSlash, vec4(.7, .4, .1, 1) * .85);
            AddSimpleTooltip(item.visible ? "Hide" : "Show");

            UI::SameLine();
            bool deleteThisItem = UI::Button(Icons::Trash + "##" + item.uid);  // alt: Icons::TrashO
            AddSimpleTooltip("Remove Item");

            if (toggleVisibility) {
                ToggleItemVisibility(item);
            }

            if (deleteThisItem)
                RemoveItem(i, item);
            // if (selectedUid == item.uid) {
            //     UI::AlignTextToFramePadding();
            //     UI::Text(Icons::Check);
            //     UI::SameLine();
            //     bool deselect = UI::Button(Icons::Ban);
            //     AddSimpleTooltip("Deselect item.");
            //     if (deselect) selectedUid = "";
            // } else {
            //     if (UI::Button("Select")) {
            //         selectedUid = item.uid;
            //     }
            // }
        };

        UI::Columns(1);

        if (addItem) {
            LoadItem(DefaultSceneItem());
        }
    }

    void RenderAuxWindow() {
        if (UI::Begin("Scene Builder Item Properties", SceneBuilderAuxWindowVisible, UI::WindowFlags::None)) {


            UI::End();
        }
    }

    void ForEachItem(SceneItemFunc@ f) {
        for (uint i = 0; i < SceneItems.Length; i++) {
            f(SceneItems[i]);
        }
    }

    SceneItem@ DefaultSceneItem() {
        return SceneItem(GenUID(), "Item " + SceneItems.Length, SItemType::CarSport, true, vec3(), 180, false, true, MaybeOfString(), "", "", 1);
    }
}

funcdef void SceneItemFunc(SceneItem@ item);

const string GenUID() {
    uint a = uint(Math::Rand(-0x7FFFFFFF, 0x7FFFFFFF)); // uint(-392_112_762) == 3_902_854_534; works as expected
    print("Rand bounds: " + (-0x7FFFFFFF) + ", " + 0x7FFFFFFF + "; val = " + a + ", " + uint(a) + ", " + uint8(a));
    string uid = "01234567";
    for (uint i = 0; i < uid.Length; i++) {
        uid[i] = ToSingleHexCol(a >> i);
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

const SItemType[] AllItemTypes = {SItemType::CarSport, SItemType::CharacterPilot};

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

class SItemProps {
    SItemProps() {}
}
