const string SkinsSubPath = "Skins\\Models\\";
// const string CharPilotSkinPath = SkinsSubPath + "CharacterPilot\\";
const string CharPilotSkinPath = SkinsSubPath + "HelmetPilot\\";
const string CarSkinPath = SkinsSubPath + "CarSport\\";

// only male and female by default; alt-player-skin will add the other two in future (MaleBlack = Orig, FemaleBlack = male textures on female mesh)
enum PilotModel {Male = 0, Female, MaleBlack, FemaleBlack, FemaleWhite, MaleWhite, __Last};

const string PilotModelSkin(PilotModel pm) {
    if (pm == 1)
        return CharPilotSkinPath + "StadiumFemale.zip";
    else if (pm == 2)
        return CharPilotSkinPath + "StadiumMaleDG.zip";
    else if (pm == 3)
        return CharPilotSkinPath + "StadiumFemaleDG.zip";
    else if (pm == 4)
        return CharPilotSkinPath + "StadiumFemaleCG.zip";
    else if (pm == 5)
        return CharPilotSkinPath + "StadiumMaleCG.zip";
    // default; pm == 0
    return CharPilotSkinPath + "Stadium.zip";
}

bool HasExtraPilotModels() {
    string f = IO::FromUserGameFolder("Skins\\Models\\HelmetPilot\\");
    return true
        && IO::FolderExists(f + "StadiumFemaleDG")
        && IO::FolderExists(f + "StadiumFemaleCG")
        && IO::FolderExists(f + "StadiumMaleDG")
        && IO::FolderExists(f + "StadiumMaleCG")
        && IO::FileExists(f + "StadiumFemaleDG.zip")
        && IO::FileExists(f + "StadiumFemaleCG.zip")
        && IO::FileExists(f + "StadiumMaleDG.zip")
        && IO::FileExists(f + "StadiumMaleCG.zip")
        ;
}

PilotModel RandomPilotModel() {
    if (HasExtraPilotModels()) {
        return PilotModel(Math::Rand(2, 6));
    }
    return PilotModel(Math::Rand(0, 2));
}
