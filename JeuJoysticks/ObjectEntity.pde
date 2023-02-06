class ObjectEntity {
  /**
  Classe fondamentale de toutes les entités de jeu
  
  extended by:  PlayerCharacter  Mob  Projectile
  **/
  //arg:
  PVector orientation, position, velocity, acceleration;
  AnimatedSprite  defaultSpriteRight, defaultSpriteLeft;
  DamageArea attackHitBox; // chaque entité possède une zone de dégâts 

  boolean belongToPlayerTeam;
  int     HP, HPMax, lastHP;

  //const:
  ObjectEntity(PVector pos, AnimatedSprite spriteL, AnimatedSprite spriteR, boolean team, int life) {
    position = pos.copy();
    orientation = new PVector(1, 0);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    defaultSpriteLeft = spriteL;      //il n'existe pas de methode pour renverser horizontalement une image donc on 
    defaultSpriteRight = spriteR;     //utilise deux AnimatedSprite pour gérer l'oritentation droite/gauche d'un sprite
    belongToPlayerTeam = team;        //défini l'appartenance ou non à l'équipe "joueur" et est utilisé pour les constructeurs des zones de dégats et projectiles de l'entité
    HPMax = life;
    HP = life;
    lastHP = life;
  }

  void run() {
    ;
  }

  boolean tookDamage() {
    return(lastHP > HP);
  }

  boolean isOutOfBound() {
    /** renvoie true si l'entité est en dehors de l'arène **/
    return (position.x < 32*resizeRatio.x || position.x > width - 32*resizeRatio.x || position.y < 180*resizeRatio.y || position.y > height);
  }

  boolean isOutOfBound(PVector pos, char xy) {
    /** détecte si une postion a ses coordonées x ou y en dehors de l'arène **/
    return (xy == 'x' && (pos.x < 32*resizeRatio.x || pos.x > width - 32*resizeRatio.x) || (xy == 'y' && (pos.y < 180*resizeRatio.y || pos.y > height - defaultSpriteRight.getHeight()/2)));
  }
  
  boolean isOutOfMap(){
    return (position.x > width + 20 || position.x < -20 || position.y > height + 20 || position.y < -20);
  }

  boolean isDead() {
    return(HP < 1);
  }
}
