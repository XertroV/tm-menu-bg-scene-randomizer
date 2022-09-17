[Setting hidden]
uint Setting_CameraSeed = 0;
uint Setting_SceneSeed = 0;


[SettingsTab name="Scene Settings"]
void RenderSceneSettingsTab() {

}

[SettingsTab name="Scene Customization"]
void RenderSceneCustomizationTab() {
    if (Setting_SceneSeed == 0) {
        UI::Text("These settings are inactive when randomization is enabled.");
        return;
    }
}
