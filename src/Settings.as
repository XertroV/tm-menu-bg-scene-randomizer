bool PluginIsEnabled() {
    return Setting_Enabled;
}

/* Reflection Settings */

[Setting category="BG Reflection" name="Plugin Enabled?"]
bool Setting_Enabled = true;

[Setting category="BG Reflection" name="Opacity" min="-20.0" max="20.0" description="default: 0.63. \\$888 Note: if the slider doesn't seem to change the reflection at all, go into another menu, then back to the main menu. It should work after that."]
float Setting_BgReflectionOpacity = 0.63;

[Setting category="BG Reflection" name="Angle" min="-20.0" max="2.0" description="default: -2.1; Clipping occurs below -6; No reflection is visible below -15.1. \\$888 Note: if the slider doesn't seem to change the reflection at all, go into another menu, then back to the main menu. It should work after that."]
float Setting_BgReflectionAngle = -2.1;
