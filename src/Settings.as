[Setting hidden]
uint Setting_CameraSeed = 0;

[Setting hidden]
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



int nbElement = 0;
SceneItem[] data = {};

class Values {
    string type = "CarSport";
    int typeChoice = 1;
    string path = "";
    float x = 0.;
    float y = 0.;
    float z = 0.;
    float rotation = 0.;
    bool rotating = false;

    string toJson(){
        array<string> val = {};
        string json = "";

        val.InsertLast('"type": '+ this.type);
        val.InsertLast('"typeChoice": '+ this.typeChoice);
        val.InsertLast('"path": '+ (this.path == "" ? '""' : this.path));
        val.InsertLast('"x": '+ this.x);
        val.InsertLast('"y": '+ this.y);
        val.InsertLast('"z": '+ this.z);
        val.InsertLast('"rotation": '+ this.rotation);
        val.InsertLast('"rotating": '+ this.rotating);

        json = string::Join(val, ",");

        return json;
    }
}

array<string> typeList = {
    'CarSport',
    'HelmetPilot'
};

void ApplyChanges(){
    string dataJson = "[";
    for(int i = 0; i < int(data.Length); i++){
        dataJson = dataJson + "{" + data[i].toJson() + "},";
    }
    dataJson = dataJson + "]";

    print(dataJson);
    // ResetCurrentScene(dataJson);
}

[SettingsTab name="Element customization"]
void RenderPositionCustomization(){

    // if(!UserCanUseThePlugin()){
    //     UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
    //     return;
    // }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");
    if(UI::Button("Apply changes")){
        ApplyChanges();
    }
    UI::Separator();
    for(int i = 0; i < int(data.Length); i++){
        // UI::SameLine();
        UI::SetNextItemWidth(125.);
        if(UI::BeginCombo("Type##"+i, typeList[data[i].typeChoice-1])){
            if(UI::Selectable("CarSport", data[i].typeChoice == 1)){
                data[i].typeChoice = 1;
                UI::SetItemDefaultFocus();
            }
            if(UI::Selectable("HelmetPilot", data[i].typeChoice == 2)){
                data[i].typeChoice = 2;
            }
            UI::EndCombo();
        }

        UI::SameLine();
        UI::SetNextItemWidth(250.);
        data[i].path = UI::InputText("Path##"+i, data[i].path);

        UI::SameLine();
        UI::SetNextItemWidth(125.);
        data[i].x = UI::InputFloat("X##"+i, data[i].x);

        UI::SameLine();
        UI::SetNextItemWidth(125.);
        data[i].y = UI::InputFloat("Y##"+i, data[i].y);

        UI::SameLine();
        UI::SetNextItemWidth(125.);
        data[i].z = UI::InputFloat("Z##"+i, data[i].z);

        UI::SameLine();
        UI::SetNextItemWidth(125.);
        data[i].rotation = UI::InputFloat("Rotation##"+i, data[i].rotation);

        UI::SameLine();
        UI::SetNextItemWidth(150.);
        data[i].rotating = UI::Checkbox("Rotating##"+i, data[i].rotating);
    }

    // if(UI::Button("Reset to default")){
    //     allPositionToGet = {1,10,100,1000,10000};
    //     nbSizePositionToGetArray = 5;
    // }


    if(UI::Button("+ : Add an element")){
        nbElement++;
        Values tmpValues = Values();
        data.InsertLast(tmpValues);
        OnSettingsChanged();
    }

    UI::BeginDisabled((nbElement == 0 ? true : false));
    if(UI::Button("- : Remove an element")){
        if(nbElement > 0){
            data.RemoveAt(nbElement-1);
            nbElement--;
            OnSettingsChanged();
        }
    }
    UI::EndDisabled();



    // if(UI::Button("Refresh")){
    //     ForceRefresh();
    // }
}
