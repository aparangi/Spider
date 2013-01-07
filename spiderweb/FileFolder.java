import java.util.*;
class FileFolder implements java.io.Serializable {
  ArrayList<SpiderFile> contents;
  ArrayList<FileFolder> children;
  String name;
  String path;
  transient spiderweb applet;
  FileFolder() {
  }
  FileFolder(String path) {
    path = path.trim();
    this.path = path;
    String[] pathParts = path.split("/");
    name = pathParts[pathParts.length - 1];
    //path = trim(path).substring(0,);
    contents = new ArrayList();
    children = new ArrayList();
    java.io.File f = new java.io.File(path);
    String[] l = f.list();
    for (int i = 0; i < l.length; i++) {
      f  = new java.io.File(path + "/" + l[i]);
      if (f.list() != null) {
        children.add(new FileFolder(path + "/" + l[i]));
      } 
      else {
        contents.add(new SpiderFile(l[i], this));
      }
    }
  }
  void printFolder() {
    printFolder("");
  }
  void printFolder(String indent) {
    applet.println(indent + "(" + name + ")");
    for (int i = 0; i < contents.size(); i++) {
      applet.println(indent + contents.get(i).name);
    }
    for (int i = 0; i < children.size(); i++) {
      children.get(i).printFolder(indent + "   ");
    }
  }
}
