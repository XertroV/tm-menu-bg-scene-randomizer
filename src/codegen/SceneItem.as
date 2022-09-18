shared class SceneItem {
  /* Properties // Mixin: Default Properties */
  private string _name;
  private uint _ver;
  private SItemType _type;
  private vec3 _pos;
  private float _angle;
  private bool _tt;
  private bool _carSync;
  private MaybeOfString@ _attachedTo;
  private string _skinZip;

  /* Methods // Mixin: Default Constructor */
  SceneItem(const string &in name, uint ver, SItemType type, vec3 pos, float angle, bool tt, bool carSync, MaybeOfString@ attachedTo, const string &in skinZip) {
    this._name = name;
    this._ver = ver;
    this._type = type;
    this._pos = pos;
    this._angle = angle;
    this._tt = tt;
    this._carSync = carSync;
    @this._attachedTo = attachedTo;
    this._skinZip = skinZip;
  }

  /* Methods // Mixin: ToFrom JSON Object */
  SceneItem(const Json::Value &in j) {
    try {
      this._name = string(j["name"]);
      this._ver = uint(j["ver"]);
      this._type = SItemType(uint(j["type"]));
      this._pos = vec3(float(j["pos"]['x']), float(j["pos"]['y']), float(j["pos"]['z']));
      this._angle = float(j["angle"]);
      this._tt = bool(j["tt"]);
      this._carSync = bool(j["carSync"]);
      @this._attachedTo = MaybeOfString(j["attachedTo"]);
      this._skinZip = string(j["skinZip"]);
    } catch {
      OnFromJsonError(j);
    }
  }

  Json::Value ToJson() {
    Json::Value j = Json::Object();
    j["name"] = _name;
    j["ver"] = _ver;
    j["type"] = _type;
    j["pos"] = Vec3ToJsonObj(_pos);
    j["angle"] = _angle;
    j["tt"] = _tt;
    j["carSync"] = _carSync;
    j["attachedTo"] = _attachedTo.ToJson();
    j["skinZip"] = _skinZip;
    return j;
  }

  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }

  /* Methods // Mixin: Getters */
  const string get_name() const {
    return this._name;
  }

  uint get_ver() const {
    return this._ver;
  }

  SItemType get_type() const {
    return this._type;
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

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'SceneItem('
      + string::Join({'name=' + name, 'ver=' + '' + ver, 'type=' + tostring(type), 'pos=' + pos.ToString(), 'angle=' + '' + angle, 'tt=' + '' + tt, 'carSync=' + '' + carSync, 'attachedTo=' + attachedTo.ToString(), 'skinZip=' + skinZip}, ', ')
      + ')';
  }

  /* Methods // Mixin: Op Eq */
  bool opEquals(const SceneItem@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    return true
      && _name == other.name
      && _ver == other.ver
      && _type == other.type
      && pos.x == other.pos.x && pos.y == other.pos.y && pos.z == other.pos.z
      && _angle == other.angle
      && _tt == other.tt
      && _carSync == other.carSync
      && _attachedTo == other.attachedTo
      && _skinZip == other.skinZip
      ;
  }
}
