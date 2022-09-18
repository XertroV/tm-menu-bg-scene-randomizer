shared class SkinSpec {
  /* Properties // Mixin: Default Properties */
  private string _baseModel;
  private bool _hasPlayerMesh;
  private array<TextureUrlPair@> _texturePairs;
  
  /* Methods // Mixin: Default Constructor */
  SkinSpec(const string &in baseModel, bool hasPlayerMesh, const TextureUrlPair@[] &in texturePairs) {
    this._baseModel = baseModel;
    this._hasPlayerMesh = hasPlayerMesh;
    this._texturePairs = texturePairs;
  }
  
  /* Methods // Mixin: ToFrom JSON Object */
  SkinSpec(const Json::Value &in j) {
    try {
      this._baseModel = string(j["baseModel"]);
      this._hasPlayerMesh = bool(j["hasPlayerMesh"]);
      this._texturePairs = array<TextureUrlPair@>(j["texturePairs"].Length);
      for (uint i = 0; i < j["texturePairs"].Length; i++) {
        @this._texturePairs[i] = TextureUrlPair(j["texturePairs"][i]);
      }
    } catch {
      OnFromJsonError(j);
    }
  }
  
  Json::Value ToJson() {
    Json::Value j = Json::Object();
    j["baseModel"] = _baseModel;
    j["hasPlayerMesh"] = _hasPlayerMesh;
    Json::Value _tmp_texturePairs = Json::Array();
    for (uint i = 0; i < _texturePairs.Length; i++) {
      auto v = _texturePairs[i];
      _tmp_texturePairs.Add(v.ToJson());
    }
    j["texturePairs"] = _tmp_texturePairs;
    return j;
  }
  
  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }
  
  /* Methods // Mixin: Getters */
  const string get_baseModel() const {
    return this._baseModel;
  }
  
  bool get_hasPlayerMesh() const {
    return this._hasPlayerMesh;
  }
  
  const TextureUrlPair@[]@ get_texturePairs() const {
    return this._texturePairs;
  }
  
  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'SkinSpec('
      + string::Join({'baseModel=' + baseModel, 'hasPlayerMesh=' + '' + hasPlayerMesh, 'texturePairs=' + TS_Array_TextureUrlPair(texturePairs)}, ', ')
      + ')';
  }
  
  private const string TS_Array_TextureUrlPair(const array<TextureUrlPair@> &in arr) {
    string ret = '{';
    for (uint i = 0; i < arr.Length; i++) {
      if (i > 0) ret += ', ';
      ret += arr[i].ToString();
    }
    return ret + '}';
  }
  
  /* Methods // Mixin: Op Eq */
  bool opEquals(const SkinSpec@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    bool _tmp_arrEq_texturePairs = _texturePairs.Length == other.texturePairs.Length;
    for (uint i = 0; i < _texturePairs.Length; i++) {
      if (!_tmp_arrEq_texturePairs) {
        break;
      }
      _tmp_arrEq_texturePairs = _tmp_arrEq_texturePairs && (_texturePairs[i] == other.texturePairs[i]);
    }
    return true
      && _baseModel == other.baseModel
      && _hasPlayerMesh == other.hasPlayerMesh
      && _tmp_arrEq_texturePairs
      ;
  }
}
