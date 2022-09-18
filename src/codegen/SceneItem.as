class SceneItem {
  /* Properties // Mixin: Default Properties */
  private string _uid;
  private string _name;
  private SItemType _type;
  private bool _visible;
  private vec3 _pos;
  private float _angle;
  private bool _tt;
  private bool _carSync;
  private MaybeOfString@ _attachedTo;
  private string _skinZip;
  private string _skinUrl;
  private uint _ver;

  /* Methods // Mixin: Default Constructor */
  SceneItem(const string &in uid, const string &in name, SItemType type, bool visible, vec3 pos, float angle, bool tt, bool carSync, MaybeOfString@ attachedTo, const string &in skinZip, const string &in skinUrl, uint ver) {
    this._uid = uid;
    this._name = name;
    this._type = type;
    this._visible = visible;
    this._pos = pos;
    this._angle = angle;
    this._tt = tt;
    this._carSync = carSync;
    @this._attachedTo = attachedTo;
    this._skinZip = skinZip;
    this._skinUrl = skinUrl;
    this._ver = ver;
  }

  /* Methods // Mixin: ToFrom JSON Object */
  SceneItem(const Json::Value &in j) {
    try {
      this._uid = string(j["uid"]);
      this._name = string(j["name"]);
      this._type = SItemType(uint(j["type"]));
      this._visible = bool(j["visible"]);
      this._pos = vec3(float(j["pos"]['x']), float(j["pos"]['y']), float(j["pos"]['z']));
      this._angle = float(j["angle"]);
      this._tt = bool(j["tt"]);
      this._carSync = bool(j["carSync"]);
      @this._attachedTo = MaybeOfString(j["attachedTo"]);
      this._skinZip = string(j["skinZip"]);
      this._skinUrl = string(j["skinUrl"]);
      this._ver = uint(j["ver"]);
    } catch {
      OnFromJsonError(j);
    }
  }

  Json::Value ToJson() {
    Json::Value j = Json::Object();
    j["uid"] = _uid;
    j["name"] = _name;
    j["type"] = _type;
    j["visible"] = _visible;
    j["pos"] = Vec3ToJsonObj(_pos);
    j["angle"] = _angle;
    j["tt"] = _tt;
    j["carSync"] = _carSync;
    j["attachedTo"] = _attachedTo.ToJson();
    j["skinZip"] = _skinZip;
    j["skinUrl"] = _skinUrl;
    j["ver"] = _ver;
    return j;
  }

  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }

  /* Methods // Mixin: Getters */
  const string get_uid() const {
    return this._uid;
  }

  const string get_name() const {
    return this._name;
  }

  SItemType get_type() const {
    return this._type;
  }

  bool get_visible() const {
    return this._visible;
  }

  vec3 get_pos() const {
    return this._pos;
  }

  float get_angle() const {
    return this._angle;
  }

  bool get_tt() const {
    return this._tt;
  }

  bool get_carSync() const {
    return this._carSync;
  }

  MaybeOfString@ get_attachedTo() const {
    return this._attachedTo;
  }

  const string get_skinZip() const {
    return this._skinZip;
  }

  const string get_skinUrl() const {
    return this._skinUrl;
  }

  uint get_ver() const {
    return this._ver;
  }

  /* Methods // Mixin: Setters */
  void set_uid(const string &in new_uid) {
    this._uid = new_uid;
  }

  void set_name(const string &in new_name) {
    this._name = new_name;
  }

  void set_type(SItemType new_type) {
    this._type = new_type;
  }

  void set_visible(bool new_visible) {
    this._visible = new_visible;
  }

  void set_pos(vec3 new_pos) {
    this._pos = new_pos;
  }

  void set_angle(float new_angle) {
    this._angle = new_angle;
  }

  void set_tt(bool new_tt) {
    this._tt = new_tt;
  }

  void set_carSync(bool new_carSync) {
    this._carSync = new_carSync;
  }

  void set_attachedTo(MaybeOfString@ new_attachedTo) {
    @this._attachedTo = new_attachedTo;
  }

  void set_skinZip(const string &in new_skinZip) {
    this._skinZip = new_skinZip;
  }

  void set_skinUrl(const string &in new_skinUrl) {
    this._skinUrl = new_skinUrl;
  }

  void set_ver(uint new_ver) {
    this._ver = new_ver;
  }

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'SceneItem('
      + string::Join({'uid=' + uid, 'name=' + name, 'type=' + tostring(type), 'visible=' + '' + visible, 'pos=' + pos.ToString(), 'angle=' + '' + angle, 'tt=' + '' + tt, 'carSync=' + '' + carSync, 'attachedTo=' + attachedTo.ToString(), 'skinZip=' + skinZip, 'skinUrl=' + skinUrl, 'ver=' + '' + ver}, ', ')
      + ')';
  }

  /* Methods // Mixin: Op Eq */
  bool opEquals(const SceneItem@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    return true
      && _uid == other.uid
      && _name == other.name
      && _type == other.type
      && _visible == other.visible
      && pos.x == other.pos.x && pos.y == other.pos.y && pos.z == other.pos.z
      && _angle == other.angle
      && _tt == other.tt
      && _carSync == other.carSync
      && _attachedTo == other.attachedTo
      && _skinZip == other.skinZip
      && _skinUrl == other.skinUrl
      && _ver == other.ver
      ;
  }
}
