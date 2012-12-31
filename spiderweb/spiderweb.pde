import processing.net.*;
import javax.swing.*;
import java.net.URLConnection;
import java.net.InetAddress;
Server server;
String basePath;
FileFolder root;
ArrayList<Peer> peers;
String[] serverReport;
String[] config;
Spiderweb applet = this;
int PORT = 5204;
int SERVER_POLLING_PERIOD = 2000;
int CHUNK_SIZE = 1000000; //bytes
int counter = 0;
void setup() {
  size(1,1);
  config = loadStrings("data/config");
  basePath = config[0];
  root = new FileFolder(basePath);
  server = new Server(this, PORT);
  peers = new ArrayList();
  this.frame.setVisible(false);
  frameRate(1);
}

void draw() {
  this.frame.setVisible(false);
  if (counter%SERVER_POLLING_PERIOD == 0) {
    serverReport = getPeers(config[1],config[2],config[3], getIP());
    peers.clear();
    for (int i = 0; i < serverReport.length; i++) {
      String[] peerRecord = serverReport[i].split(";");
      Peer p = new Peer(peerRecord[0], peerRecord[1]);
      peers.add(p);
    }
  }
  //say hi
  for (int i = 0; i < peers.size(); i++) {
    Peer p = peers.get(i);
    if (p.client.connectionStatus) {
      p.client.write("Hello from " + getIP());
    }
  }
  //get all messages
  Client nextClient = server.available();
  while(nextClient != null) {
    println(nextClient.readString()); 
    nextClient = server.available();
  }
  counter++;
}

String[] getPeers(String server, String user, String password, String ip) {
  return loadStrings(server+"/s.php?u="+user+"&pw="+password+"&ip="+ip);
}

String getIP() {
  try {
    InetAddress inet = InetAddress.getLocalHost();
    return inet.getHostAddress();
  } 
  catch (Exception e) {
    e.printStackTrace();
    return null;
  }
}

String codify(String user, String password) {
  int p1 = 0;
  int p2 = 0;
  String buffer = "";
  for (int i = 0; i < user.length() + password.length(); i++) {
    if (p1 < user.length()) {
      buffer += user.substring(p1,p1+1);
      p1++;
    }
    if (p2 < password.length()) {
      buffer += password.substring(p2,p2+1);
      p2++;
    }
  }
  return md5(buffer);
}

String md5(String message) {
  try {
    java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
    md.update(message.getBytes());
    byte[] dig = md.digest();
    String buffer = "";
    for(int i=0; i<dig.length; i++) {
      buffer += hex(dig[i],2);
    }
    return buffer;
  } 
  catch(java.security.NoSuchAlgorithmException e) {
    println(e.getMessage());
    return null;
  }
} 

class Peer {
  String publicIP;
  String privateIP;
  String conIP;
  SClient client;
  Peer(String publicIP, String privateIP) {
    if (getIP().equals(publicIP)) {
      conIP = privateIP;
    } 
    else {
      conIP = publicIP;
    }
    client = new SClient(applet, conIP, PORT);
  }
  boolean refresh() {
    if (!client.connectionStatus) {
      client = new SClient(applet, conIP, PORT);
    }
    return client.connectionStatus;
  }
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
    f = new java.io.File(parent.path + "/" + name);
  }
}

