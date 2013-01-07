import processing.net.*;
import javax.swing.*;
import java.math.*;
import java.net.URLConnection;
import java.net.InetAddress;
import java.lang.Object;
Server server;
String basePath;
FileFolder root;
byte[] rootBytes;
ArrayList<Peer> peers;
String[] serverReport;
String[] config;
spiderweb applet = this;
int PORT = 5204;
int SERVER_POLLING_PERIOD = 200;
int REFRESH_POLLING_PERIOD = 9;
int CHUNK_SIZE = 1000000; //bytes
int counter = 0;
String PUBLIC_IP = "";
void setup() {
  size(1, 1);
  config = loadStrings("data/config");
  refreshIP();
  basePath = config[0];
  root = new FileFolder(basePath);
  root.applet = applet;
  rootBytes = serialize(root);
  server = new Server(this, PORT);
  peers = new ArrayList();
  this.frame.setVisible(false);
  frameRate(1);
}

void draw() {
  this.frame.setVisible(false);
  //refresh file folder

  //DO SOME SHIT HERE

  if (counter%SERVER_POLLING_PERIOD == 0) {
    serverReport = getPeers(config[1], config[2], config[3], getIP());
    peers.clear();
    for (int i = 0; i < serverReport.length; i++) {
      String[] peerRecord = serverReport[i].split(";");
      Peer p = new Peer(peerRecord[0], peerRecord[1]);
      println("adding " + peerRecord[0] + ", " + peerRecord[1]);
      peers.add(p);
    }
  }
  //send messages
  for (int i = 0; i < peers.size(); i++) {
    Peer p = peers.get(i);
    if (p.client.connectionStatus) {
      //p.client.write("Hello from " + getIP());
      p.client.write(rootBytes);
    } 
    else if (counter%REFRESH_POLLING_PERIOD == 0) {
      p.refresh();
    }
  }
  //get all messages
  Client nextClient = server.available();
  while (nextClient != null) {
    //println(toHex(nextClient.readBytes())); 
    FileFolder manifest = (FileFolder)(deserialize(nextClient.readBytes()));
    manifest.applet = applet;
    println(manifest.name);
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
      buffer += user.substring(p1, p1+1);
      p1++;
    }
    if (p2 < password.length()) {
      buffer += password.substring(p2, p2+1);
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
    for (int i=0; i<dig.length; i++) {
      buffer += hex(dig[i], 2);
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
/*
public static String toHex(byte[] bytes) {
 BigInteger bi = new BigInteger(1, bytes);
 return String.format("%0" + (bytes.length << 1) + "X", bi);
 }*/

public static String toHex(byte[] bytes) {
  String buffer = "";
  for (int i = 0; i < bytes.length; i++) {
    buffer += trim(String.format("%02X ", bytes[i]));
  }
  return buffer;
}

public static byte[] toBytes(String s) {
  byte[] result = new byte[s.length()/2];
  for (int i = 0; i < s.length()/2; i++) {
    byte b = Byte.parseByte(s.substring(i*2, i*2+2), 16);
    result[i] = b;
  }
  return result;
}


public static byte[] serialize(Object obj) {
  ByteArrayOutputStream out = null;
  ObjectOutputStream os = null;
  try {
    out = new ByteArrayOutputStream();
    os = new ObjectOutputStream(out);
    os.writeObject(obj);
  } 
  catch (Exception e) {
  }
  return out.toByteArray();
}
public static Object deserialize(byte[] data) {
  ByteArrayInputStream in = null;
  ObjectInputStream is = null;
  Object result = null;
  try {
    in = new ByteArrayInputStream(data);
    is = new ObjectInputStream(in);
  } 
  catch (Exception e) {
    println("YOLO");
  }
  try {
    result = is.readObject();
  } 
  catch (Exception e) {
    println(e);
  }
  return result;
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





