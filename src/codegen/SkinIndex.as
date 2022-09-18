shared class SkinIndex {
  /* Properties // Mixin: Default Properties */
  private array<SkinSpec@> _skins;
  
  /* Methods // Mixin: Default Constructor */
  SkinIndex(const SkinSpec@[] &in skins) {
    this._skins = skins;
  }
  
  /* Methods // Mixin: ToFrom JSON Object */
  SkinIndex(const Json::Value &in j) {
    try {
      this._skins = array<SkinSpec@>(j.Length);
      for (uint i = 0; i < j.Length; i++) {
        @this._skins[i] = SkinSpec(j[i]);
      }
    } catch {
      OnFromJsonError(j);
    }
  }
  
  Json::Value ToJson() {
    Json::Value _tmp_skins = Json::Array();
    for (uint i = 0; i < _skins.Length; i++) {
      auto v = _skins[i];
      _tmp_skins.Add(v.ToJson());
    }
    return _tmp_skins;
  }
  
  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }
  
  /* Methods // Mixin: Getters */
  const SkinSpec@[]@ get_skins() const {
    return this._skins;
  }
  
  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'SkinIndex('
      + string::Join({'skins=' + TS_Array_SkinSpec(skins)}, ', ')
      + ')';
  }
  
  private const string TS_Array_SkinSpec(const array<SkinSpec@> &in arr) {
    string ret = '{';
    for (uint i = 0; i < arr.Length; i++) {
      if (i > 0) ret += ', ';
      ret += arr[i].ToString();
    }
    return ret + '}';
  }
  
  /* Methods // Mixin: Op Eq */
  bool opEquals(const SkinIndex@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    bool _tmp_arrEq_skins = _skins.Length == other.skins.Length;
    for (uint i = 0; i < _skins.Length; i++) {
      if (!_tmp_arrEq_skins) {
        break;
      }
      _tmp_arrEq_skins = _tmp_arrEq_skins && (_skins[i] == other.skins[i]);
    }
    return true
      && _tmp_arrEq_skins
      ;
  }
}
