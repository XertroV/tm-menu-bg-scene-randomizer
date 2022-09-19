// originally from rebind-master

vec2 GetMenuItemSize(float cols = 1) {
    return vec2(UI::GetWindowContentRegionWidth() / cols - 2 * (cols - 1), UI::GetTextLineHeightWithSpacing());
}

float GetSpacingBetweenLines() {
    return (UI::GetTextLineHeightWithSpacing() - UI::GetTextLineHeight()) / 2;
}

bool MouseHoveringRegion(vec2 tlPos, vec2 size) {
    vec2 mousePos = UI::GetMousePos();
    vec2 brPos = tlPos + size;
    // trace(tostring(tlPos) + " | " + tostring(mousePos) + " | " + tostring(brPos));
    return tlPos.x <= mousePos.x && tlPos.y <= mousePos.y
        && mousePos.x <= brPos.x && mousePos.y <= brPos.y;
}

void ModCursorPos(vec2 deltas) {
    UI::SetCursorPos(UI::GetCursorPos() + deltas);
}

vec2 GetScrollPos() {
    // scroll pos is like the offset from top left of the region
    return vec2(UI::GetScrollX(), UI::GetScrollY());
    // UI::GetContentRegionAvail();
    // print(vec2(UI::GetScrollX(), UI::GetScrollY()).ToString() + " out of " + vec2(UI::GetScrollMaxX(), UI::GetScrollMaxY()).ToString());
    //  / vec2(UI::GetScrollMaxX(), UI::GetScrollMaxY());
}

bool SelectablePseudoButton(const string &in id, const string &in label, bool selected = false, bool enabled = true) {
    bool hovered = MouseHoveringRegion(UI::GetWindowPos() + UI::GetCursorPos() - GetScrollPos(), GetMenuItemSize());
    float alpha = hovered ? 1.0 : 0.0;

    UI::PushStyleColor(UI::Col::ChildBg, vec4(.231, .537, .886, alpha));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(2,2));

    UI::BeginChild("c-" + label + "##" + id, GetMenuItemSize());
    // "pad" top a bit
    ModCursorPos(vec2(GetSpacingBetweenLines(), GetSpacingBetweenLines()));
    // store current cursor pos
    vec2 tl = UI::GetCursorPos();
    if (selected)
        UI::Text(Icons::Check);
    // right of check mark
    UI::SetCursorPos(tl + vec2(24, 0));
    UI::Text(label);
    UI::EndChild();

    UI::PopStyleVar();
    UI::PopStyleColor();

    return UI::IsItemClicked();
}
