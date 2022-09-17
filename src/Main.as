/* Notes: */

SceneRandomizer@ g_SceneRand = SceneRandomizer();

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(SetUpReflsIntercept);
}

void SetUpReflsIntercept() {
    SetUpSceneRandomizerIntercepts();
}
