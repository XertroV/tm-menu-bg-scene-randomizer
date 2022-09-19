shared enum SItemType {
  CarSport,
  CharacterPilot,
  CustomMesh
}

shared Json::Value Vec3ToJsonObj(vec3 &in v) {
  auto j = Json::Object();
  j['x'] = v.x;
  j['y'] = v.y;
  j['z'] = v.z;
  return j;
}
