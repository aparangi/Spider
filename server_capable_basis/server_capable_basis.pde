import java.net.URLConnection;
postThread post;
String transitionString;
boolean transitioning;
int transitionIndex;

void setup() 
{
  //textMode(MODEL); 
  post = new postThread("http://cambriangames.com/zen/feelingZen.php");
  post.start();
  size(700,700);
  smooth();
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  );
}
void mouseWheel(int delta) {
}



void stop()
{
  post.quit();
  super.stop();
} 

void draw()
{
  background(255);
}

