import java.net.URLConnection;
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

  void start () 
  {
    running = true;
    super.start();
  }


  void run () 
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
  void quit() 
  {
    running = false;
    interrupt();
  }
  void makePost(String s)
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
  void getData()
  {
    if (!gd && !mp)
    {
      gd = true;
    }
  }
}

