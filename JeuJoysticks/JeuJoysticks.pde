import processing.serial.*;
import cc.arduino.*;

PImage mapImg;
ArrayList<FileImg> ressources;
PFont liberationSans, unbutton;
PShape manette; // image SVG

SystemGame game;
OperatingSystem OS; // OS systeme
clockTimer clock;

boolean pause = false;
boolean menuSelect = true;
boolean choix = false;
PVector resizeRatio;
ArrayList<Arduino> controllers;

void setup() {
  fullScreen();
  imageMode(CENTER);

  OS = new OperatingSystem();
  clock = new clockTimer();

  controllers = new ArrayList<Arduino>();

  if (OS.getOperatingSystem().contains("WINDOWS")) {
    if (Arduino.list().length >= 2) { //Arduino.list récupère les COM ouvert et non les cartes arduino connectés
      // les ports COM utilisés par les connexions Arduino sont le plus souvent les derniers + windows attribue le COM1 à on ne sait quoi
      controllers.add(new Arduino(this, Arduino.list()[Arduino.list().length - 2], 57600));
      controllers.add(new Arduino(this, Arduino.list()[Arduino.list().length - 1], 57600));
    }
  } else if (OS.getOperatingSystem().contains("LINUX")) {
    //controllers.add(new Arduino(this, "/dev/ttyACM0", 57600));
    //controllers.add(new Arduino(this, "/dev/ttyACM1", 57600));

    stop(); // version WINDOWS uniquement donc shutdown si autre OS
  } else {

    println("OS non pris en charge");

    stop();
  }

  /** La detection des OS est ici inutile puisque l'on ne peut pas façilement gérer les ports COM en dehors de WINDOWS **/

  println("controllers connected");

  manette = loadShape("data/manette.svg");
  manette.scale(0.20);
  manette.disableStyle();

  ressources = new ArrayList<FileImg>(); // ArrayList contenant tous les assets grapgiques du jeu dans des objets FileImg

  // un objet Java.File peut aussi bien désignier un fichier qu'un dossier File.listFiles() récupère les fichiers dans un dossier
  File[] listOfEffects = new File("data/ressource/effects").listFiles();
  File[] listOfFLeft   = new File("data/ressource/facingLeft").listFiles();
  File[] listOfFRight  = new File("data/ressource/facingRight").listFiles();

  println(listOfEffects.length + listOfFLeft.length + listOfFRight.length + " assets found");


  for (File f : listOfEffects) {
    ressources.add(new FileImg("data/ressource/effects/" + f.getName())); // adapter selon l'emplacement du fichier à partir de l'exe processing
  }
  for (File f : listOfFLeft) {
    ressources.add(new FileImg("data/ressource/facingLeft/" + f.getName())); // adapter selon l'emplacement du fichier à partir de l'exe processing
  }
  for (File f : listOfFRight) {
    ressources.add(new FileImg("data/ressource/facingRight/" + f.getName())); // adapter selon l'emplacement du fichier à partir de l'exe processing
  }
  
  println(ressources.size() + " assets loaded");

  mapImg = findImg("data/ressource/effects/mapV2");
  // la résolution native de la carte est de 960x544px, elle est redimentionnée à la taille de la fenêtre
  // le facteur de redimentionnement est utilisé pour définir la position de certains éléments sur l'image (les murs)
  // en fonction de la taille de la fenêtre.
  resizeRatio = new PVector(width/mapImg.width, height/mapImg.height);
  mapImg.resize(width, height);
  println("assets loaded");
  
  game = new SystemGame();
  
  liberationSans = loadFont("LiberationSans-16.vlw");
  unbutton = loadFont("unbutton.vlw");
  textFont(unbutton);

  println("Game setup complete");
  delay(1000);
}

void draw() {
  if (menuSelect) {
    game.characterSelect();
  } else {
    if (!game.lock) {
      game.personnages();
      game.lock =! game.lock;
    } else {
      if (pause) {
        game.menu();
      } else {
        background(200);
        imageMode(CORNER);
        image(mapImg, 0, 0);
        game.run();
      }
    }
    if (game.restart) {
      game = new SystemGame();
      menuSelect = true;
      if (pause) {
        pause = false;
      }
    }
  }
}

class FileImg {
  /** la classe FileImg permet de ne pas dissocier une image Pimage (array de pixels) de son
   nom pour la récupérer facilement dans l'array "ressources" **/

  PImage img;
  String fileName;

  FileImg(String filePath) {
    //println("loading " + filePath);
    img = loadImage(filePath);
    fileName = filePath;
  }
}

PImage findImg(String filePath) {
  //println("searching "+ filePath);
  for (FileImg i : ressources) {
    if (i.fileName.equals(filePath + ".png")) {
      return i.img;
    }
  }
  println("unable to find " + filePath);
  return null;
}

void keyPressed() {
  if (menuSelect) {
    if (keyCode == DOWN || keyCode == LEFT) {
      game.choixPlayer.set(0, game.choixPlayer.get(0)-1);
      if (game.choixPlayer.get(0) < 0) {
        game.choixPlayer.set(0, 2);
      }
    }
    if (keyCode == UP || keyCode == RIGHT) {
      game.choixPlayer.set(0, game.choixPlayer.get(0)+1);
      if (game.choixPlayer.get(0) > 2) {
        game.choixPlayer.set(0, 0);
      }
    }
    if (key == 's' || key == 'q' || key == 'S' || key == 'Q') {
      game.choixPlayer.set(1, game.choixPlayer.get(1)-1);
      if (game.choixPlayer.get(1) < 0) {
        game.choixPlayer.set(1, 2);
      }
    }
    if (key == 'z' || key == 'd' || key == 'Z' || key == 'D') {
      game.choixPlayer.set(1, game.choixPlayer.get(1)+1);
      if (game.choixPlayer.get(1) > 2) {
        game.choixPlayer.set(1, 0);
      }
    }
    if (key == ENTER) {
      menuSelect = !menuSelect;
    }
  } else {//apres menu select
    /*
    if (key == ENTER) {
     save("screenshot.png");
     println("screenshot");
     }*/
    if (key == ESC && !(game.players.get(0).isDead() && game.players.get(1).isDead())) {
      key=0; // Empêche de quitter le jeu avec ESCAPE
      if (pause) {
        clock.unpause();
        pause = false;
      } else {
        clock.pause();
        pause = true;
      }
    }
    if (pause) {
      if (keyCode == DOWN) {
        game.button++;
        if (game.button > game.buttons.size()-1) {
          game.button = 0;
        }
      }
      if (keyCode == UP) {
        game.button--;
        if (game.button < 0) {
          game.button = game.buttons.size()-1;
        }
      }
      if (key == ENTER) { //Verouille
        game.lockMenu = true;
      }
    }
  }
}
