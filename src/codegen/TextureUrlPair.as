shared class TextureUrlPair {
  /* Properties // Mixin: Default Properties */
  private string _filename;
  private string _url;
  
  /* Methods // Mixin: Default Constructor */
  TextureUrlPair(const string &in filename, const string &in url) {
    this._filename = filename;
    this._url = url;
  }
  
  /* Methods // Mixin: ToFrom JSON Object */
  TextureUrlPair(const Json::Value &in j) {
    try {
      this._filename = string(j["filename"]);
      this._url = string(j["url"]);
    } catch {
      OnFromJsonError(j);
    }
  }
  
  Json::Value ToJson() {
    Json::Value j = Json::Object();
    j["filename"] = _filename;
    j["url"] = _url;
    return j;
  }
  
  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }
  
  /* Methods // Mixin: Getters */
  const string get_filename() const {
    return this._filename;
  }
  
  const string get_url() const {
    return this._url;
  }
  
  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'TextureUrlPair('
      + string::Join({'filename=' + filename, 'url=' + url}, ', ')
      + ')';
  }
  
  /* Methods // Mixin: Op Eq */
  bool opEquals(const TextureUrlPair@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    return true
      && _filename == other.filename
      && _url == other.url
      ;
  }
}
