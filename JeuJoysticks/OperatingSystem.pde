class OperatingSystem {

  String getOperatingSystem() { // systems d'exploitation
    String OS = System.getProperty("os.name").toLowerCase();
    if (OS.contains("win")) {
      return "WINDOWS";
    } else if (OS.contains("nix") || OS.contains("nux") || OS.contains("aix")) {
      return "LINUX";
    } else if (OS.contains("mac")) {
      return "MAC";
    } else if (OS.contains("sunos")) {
      return "SOLARIS";
    }
    return null;
  }
}
