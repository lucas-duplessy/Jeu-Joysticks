class SystemController {
  /**
   classe faisant la liason entre la carte Arduino et les fonctions d'entrés que l'on veut utiliser
   **/

  //attributes:
  boolean upButton, rightButton, downButton, leftButton, joystickButton, upLast, rightLast, downLast, leftLast;
  PVector joystick, scalledJoystick;
  
  Arduino inputBoard;

  //const:
  SystemController(Arduino board) {

    inputBoard  = board;
    joystick    = new PVector(0, 0);
    upButton    = false;
    rightButton = false;
    downButton  = false;
    leftButton  = false;

    upLast      = false;
    rightLast   = false;
    downLast    = false;
    leftLast    = false;
  }

  SystemController() {

    joystick    = new PVector(0, 0);
    upButton    = false;
    rightButton = false;
    downButton  = false;
    leftButton  = false;

    upLast      = false;
    rightLast   = false;
    downLast    = false;
    leftLast    = false;
  }

  //methods:
  void initialize() {
    inputBoard.pinMode(8, Arduino.INPUT);
    inputBoard.pinMode(9, Arduino.INPUT);
    inputBoard.pinMode(12, Arduino.INPUT);
  }

  void readInput() {
    upLast    = upButton;    // on garde en mémoire le dernier état des bouttons pour pouvoir détecter des fronts montants/déscendants
    rightLast = rightButton;
    downLast  = downButton;
    leftLast  = leftButton;

    upButton       = inputBoard.digitalRead(8) == Arduino.LOW;
    leftButton     = inputBoard.digitalRead(9) == Arduino.LOW;
    rightButton    = inputBoard.digitalRead(12) == Arduino.LOW;
    downButton     = inputBoard.analogRead(1) < 1;
    joystickButton = inputBoard.analogRead(0) < 1;

    /** Le joystick de la manette est composé de deux potentiometres renvoyant une valeur allant de 0 à environ 1000
        en position d'équilibre la valeur de leurs pin analogique varie autour de 500, pour annuler ces variations on
        divise la valeur par 20 ce qui réduit le nombre de variations de position x et y de la position du joystick à
        50. La magnitude du vecteur joystick étant égale à sqrt(px²+py²) elle est plus importante quand il est en
        position diagonale, on crée donc un vecteur scalledJoystick dont la magnitude maximale n'évolue pas au dela de 
        px_max|py_max sans créer un espace vide dans les diagonales **/
  
    joystick.x = int(-(inputBoard.analogRead(3)-500)/30); 
    joystick.y = int((inputBoard.analogRead(2)-500)/30);
    int greaterMag = int(abs(joystick.x));
    if (abs(joystick.y) > greaterMag) {
      greaterMag = int(abs(joystick.y));
    }
    scalledJoystick = joystick.copy();
    scalledJoystick.setMag(greaterMag);
  }

  boolean upReleased() {
    return !upButton && upLast;
  }
  boolean rightReleased() {
    return !rightButton && rightLast;
  }
  boolean leftReleased() {
    return !leftButton && leftLast;
  }
  boolean downReleased() {
    return !downButton && downLast;
  }
}
