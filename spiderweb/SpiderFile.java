import java.util.*;
class SpiderFile implements java.io.Serializable {
  transient java.io.File f;
  int fileSize;
  String name;
  FileFolder parent;
  SpiderFile() {
  }
  SpiderFile(String name, FileFolder parent) {
    this.name = name;
    this.parent = parent;
    f = new java.io.File(parent.path + "/" + name);
  }
}
