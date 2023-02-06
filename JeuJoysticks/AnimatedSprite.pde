class AnimatedSprite {
  /** 
  classe utilisée pour afficher des séquences d'images sous la forme d'images animés 
  **/

  PImage[] img;    // array contenant les images (plutôt des pointeurs vers l'ArrayList "ressource" en réalité )
  int imgCount, 
      frame,       // numéro de la frame courante
      frameDelay,  // nombre d'appels de méthode d'affichage nessessaire à la progression de l'animation (ces methodes sont appelés en continu et processing execute le draw 60x par seconde donc le nombre de 1/60 de sec entre chaque frame)
      timer,     
      lastFrame;   // numéro de la dernière frame utilisée
      
  boolean animationLocked; // permet de "geler" une image animée en mode noLoop

  AnimatedSprite(String fileNamePrefix, int nbrOfFrame, int delay) {
    imgCount = nbrOfFrame;
    img = new PImage[imgCount];
    frameDelay = delay;
    timer = 0;

    for (int i = 1; i <= imgCount; i++) {
      String filename = fileNamePrefix + i;
      img[i-1] = findImg(filename);
    }
  }

  void display(float posX, float posY) {
  /** méthode pour l'affichage du sprite avec répétition infinie **/
    
    if (imgCount != 0) // si il nous arrive de déclarer des animations "vides", pour éviter une erreur outOfBound on conditionne l'affichage
    {
      lastFrame = frame;
      if (timer >= frameDelay) {
        frame = (frame + 1) % imgCount ;
        timer = 0;
      }
      image(img[frame], posX, posY);
      timer ++;
    }
  }

  void displayNoLoop(float posX, float posY) {
  /** méthode pour l'affichage du sprite sans répétion, l'animation s'arrête à la dernière image **/
  
    if (imgCount != 0)
    {
      lastFrame = frame;
      if (timer >= frameDelay && !animationLocked) {
        frame ++;
        timer = 0;
        if (frame == imgCount-1) {
          animationLocked = true;
        }
      }
      image(img[frame], posX, posY);
      timer ++;
    }
  }

  void releaseAnimation() {
  /** méthode pour remettre à zéro l'animation **/  
 
    frame = 0;
    timer = 0;
    animationLocked = false;
  }

  int getWidth() {
    return img[0].width;
  }
  
  int getHeight() {
    return img[0].height;
  }
  
  boolean animationEnded() {
    return(frame == imgCount -1);
  }

  boolean animationGotToFrame(int x) {
    if (lastFrame != frame && frame == x) {
      return true;
    } else {
      return false;
    }
  }
}
