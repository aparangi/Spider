import processing.net.*;
import javax.swing.*;
import java.math.*;
import java.net.URLConnection;
import java.net.InetAddress;
Server server;
String basePath;
FileFolder root;
ArrayList<Peer> peers;
String[] serverReport;
String[] config;
spiderweb applet = this;
int PORT = 5204;
int SERVER_POLLING_PERIOD = 200;
int REFRESH_POLLING_PERIOD = 5;
int CHUNK_SIZE = 1000000; //bytes
int counter = 0;
String PUBLIC_IP = "";
void setup() {
  size(1,1);
  config = loadStrings("data/config");
  refreshIP();
  basePath = config[0];
  root = new FileFolder(basePath);
  server = new Server(this, PORT);
  peers = new ArrayList();
  this.frame.setVisible(false);
  println(root.flattenToString());
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
  //send messages
  for (int i = 0; i < peers.size(); i++) {
    Peer p = peers.get(i);
    if (p.client.connectionStatus) {
      p.client.write("Hello from " + getIP());
    } 
    else if (counter%REFRESH_POLLING_PERIOD == 0) {
      p.refresh();
    }
  }
  //get all messages
  Client nextClient = server.available();
  while(nextClient != null) {
    //println(nextClient.readString()); 
    nextClient = server.available();
  }
  counter++;
}

String[] getPeers(String server, String user, String password, String ip) {
  String[] serverResponse = loadStrings(server+"s.php?u="+user+"&pw="+password+"&ip="+ip);
  if (serverResponse != null) {
    return serverResponse;
  } 
  else {
    return new String[0];
  }
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

void refreshIP() {
  String[] ip = loadStrings(config[1] + "ip.php");
  if (ip != null) {
    PUBLIC_IP = ip[0];
  } 
  else {
    PUBLIC_IP = "0";
  }
}

public static String toHex(byte[] bytes) {
  BigInteger bi = new BigInteger(1, bytes);
  return String.format("%0" + (bytes.length << 1) + "X", bi);
}

class Peer {
  String publicIP;
  String privateIP;
  String conIP;
  SClient client;
  Peer(String publicIP, String privateIP) {
    if (PUBLIC_IP.equals(publicIP)) {
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
  
  
  String flattenToString() {
    String buffer = name + " <";
    for (int i = 0; i < contents.size(); i++) {
      buffer += contents.get(i).name;
      if (i < contents.size() - 1) {
        buffer += ",";
      }
    }
    for (int i = 0; i < children.size(); i++) {
      buffer += children.get(i).flattenToString();
    }
    return buffer;
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

