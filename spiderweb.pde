import processing.net.*;
import javax.swing.*;
Client client;
Server server;
String basePath;
FileFolder root;
void setup() {
  size(500,500);
  String[] config = loadStrings("data/config");
  basePath = config[0];
  java.io.File f = new java.io.File(basePath);
  root = new FileFolder(basePath);
  root.printFolder();
}

void draw() {
  //this.frame.setVisible(true);
}

class FileFolder {
  ArrayList<SpiderFile> contents;
  ArrayList<FileFolder> children;
  String name;
  String path;
  FileFolder(String path) {
    path = trim(path);
    this.path = path;
    String[] pathParts = split(path, '/');
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
    println(indent + "(" + name + ")");
    for (int i = 0; i < contents.size(); i++) {
      println(indent + contents.get(i).name);
    }
    for (int i = 0; i < children.size(); i++) {
      children.get(i).printFolder(indent + "   ");
    }
  }
}

class SpiderFile {
  java.io.File f;
  int fileSize;
  String name;
  FileFolder parent;
  SpiderFile(String name, FileFolder parent) {
    this.name = name;
    this.parent = parent;
    //f = new java.io.File(parent.path + "/" + name);
  }
}

