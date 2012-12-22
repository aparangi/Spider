import processing.core.*; 
import processing.xml.*; 

import java.net.URLConnection; 
import java.net.URLConnection; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class server_capable_basis extends PApplet {


postThread post;
String transitionString;
boolean transitioning;
int transitionIndex;

public void setup() 
{
  //textMode(MODEL); 
  post = new postThread("http://cambriangames.com/zen/feelingZen.php");
  post.start();
  size(450,700);
  smooth();
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  );
}
public void mouseWheel(int delta) {
  
  
}



public void stop()
{
  post.quit();
  super.stop();
} 

class postThread extends Thread {

  public boolean running;
  String url;
  String post;
  boolean mp = false;
  boolean gd = false;
  int fetchTime = -1000000;
  int minFetch = 60000;
  ArrayList<String> data;
  postThread (String s) {
    running = false;
    url = s;
    post = "";
  }

  public void start () 
  {
    running = true;
    super.start();
  }


  public void run () 
  {
    HttpURLConnection server;
    URL serverAddress;
    OutputStreamWriter wr;
    BufferedReader br;
    String brline;
    while (running)
    {
      if (mp) {
        try
        {
          serverAddress = new URL(url);
          server = (HttpURLConnection)serverAddress.openConnection();
          server.setRequestMethod("POST");
          server.setDoOutput(true);
          server.setDoInput(true);
          server.setUseCaches(false);
          server.connect();
          wr = new OutputStreamWriter(server.getOutputStream());
          wr.write(URLEncoder.encode("zen", "UTF-8") + "="+URLEncoder.encode(post+"\n", "UTF-8"));
          wr.flush();
          server.getInputStream();
          wr.close();

          server.disconnect();
        }
        catch (MalformedURLException e)
        {
          println(e);
        }
        catch (IOException e)
        {
          println(e);
        }
        println("posted");
        mp = false;
      }
      else if (gd)
      {


        if (millis() - fetchTime > minFetch)
        {
          fetchTime = millis();
          println(millis());
          try
          {
            serverAddress = new URL(url);
            server = (HttpURLConnection)serverAddress.openConnection();
            server.setRequestMethod("POST");
            server.setDoOutput(true);
            server.setDoInput(true);
            server.setUseCaches(false);
            server.connect();
            br = new BufferedReader(new InputStreamReader(server.getInputStream()));
            data = new ArrayList<String>();
            while ( (brline = br.readLine()) != null)
            {
              brline = brline.replaceAll("<br />","");
              brline = brline.replaceAll("\\\\'","'");
              println(brline);
              data.add(brline);
            }
            server.disconnect();
          }
          catch (MalformedURLException e)
          {
            println(e);
          }
          catch (IOException e)
          {
            println(e);
          }
          println("fetched");
        }

        gd = false;
        transitionString = data.get((int)random(data.size()));
        transitioning = true;
        transitionIndex = 0;
        
      }
      try 
      {
        sleep((long)(10));
      } 
      catch (Exception e) 
      {
      }
    }
  }

  // Our method that quits the thread
  public void quit() 
  {
    running = false;
    interrupt();
  }
  public void makePost(String s)
  {
    println("trying to post");
    boolean overlap = false;
    if (data != null)
    {
      for (int i = 0;i<data.size();i++)
      {
        if (data.get(i).equals(s))
        {
          overlap = true;
        }
      }
    }
    if (!mp && !s.equals("") && !gd && !overlap)
    {
      mp = true;
      post = s;
    }
    else
    {
      println("failed");
    }
  }
  public void getData()
  {
    if (!gd && !mp)
    {
      gd = true;
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "server_capable_basis" });
  }
}
