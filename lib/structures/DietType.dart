enum DietType {
  NONE,
  VEG,
  NON_VEG,
  EGG
}


DietType getDietTypeFromString(String type) {
switch (type) {
case "NONE": return DietType.NONE;
case "VEG": return DietType.VEG;
case "NON_VEG": return DietType.NON_VEG;
case "CONTAINS_EGG": return DietType.EGG;
}
return DietType.NONE;
}