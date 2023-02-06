class Projectile extends ObjectEntity {
/** classe des projectiles **/

  int hitBoxRadius, damageRadius, chainRemaining, chainCooldown;
  boolean hit;
  AnimatedSprite endSprite;

  String prefix; //nessesaire pour copier le projectile via le constructeur par défaut

  Projectile(PVector position, PVector direction, float spd, float accl, int bounces, boolean team, int dmg, int dmgRd, int hbRd, String spriteString, int nbFrame, int nbEndFrame) {

    super(position, new AnimatedSprite("data/ressource/effects/" + spriteString, 4, 5), new AnimatedSprite("data/ressource/effects/" + spriteString, nbFrame, 5), team, 1);

    endSprite = new AnimatedSprite("data/ressource/effects/" + spriteString + "_End", nbEndFrame, 3);

    hitBoxRadius = hbRd;
    damageRadius = dmgRd;

    attackHitBox = new DamageArea("circle", team, dmgRd, 0, position, dmg);
    attackHitBox.isResolved = true;

    prefix = spriteString;
    hit = false;

    orientation = direction.copy();
    velocity    = orientation.copy();
    velocity.setMag(spd);
    acceleration= orientation.copy();
    acceleration.setMag(accl);

    chainRemaining = bounces;
    chainCooldown = 0;
  }

  Projectile copy() {
    /** méthode de copie du projectile dans son état courant **/
    return new Projectile(position, orientation, velocity.mag(), acceleration.mag(), chainRemaining, belongToPlayerTeam, attackHitBox.damage, damageRadius, hitBoxRadius, prefix, defaultSpriteRight.imgCount, endSprite.imgCount);
  }

  void run() {
    update();
    render();
  }

  void update() {
    
    /** les projectiles sont capables de rebondir un certain nombre de fois pour se réorienter vers une direction donnée (gérée par SystemGame) 
    Un projectile active sa zone de dégâts quand il touche, pour éviter qu'il touche plusieurs fois une cible qu'il traverse où rebondisse 
    plusieurs fois dans la même cible on le rend incapable de troucher pendant un certain nombre de cycles **/
    if (chainCooldown > 0) { 
      hit = false;
      chainCooldown --;
    }
    
    if (chainRemaining == 0 && (hit || isOutOfBound())) {
      HP = 0;
    }

    if (chainCooldown == 0) {
      attackHitBox.isResolved = false;
    }
    
    //(le code permétant de faire rebondir le projectile est principalement situé dans le SystemGame pour éviter de multiplier les pointeurs sur plusieurs niveaux)
    
    if (!isDead()) {
      velocity.add(acceleration);
      position.add(velocity);
    } else {
      velocity.setMag(0);
    }
    attackHitBox.position = position.copy();
  }

  void render() {
    if (isDead()) {
      endSprite.displayNoLoop(position.x, position.y);
    } else {
      float angle = PI + PVector.angleBetween(new PVector(0, -1), orientation);
      if (orientation.x < 0) { // la méthode PVector.angleBetween renvoie l'angle le plus faible entre les vecteurs, il ne dépassera donc jamais 180° on doit donc discriminer l'orientation droite/gauche 
        angle = -angle;
      }

      translate(position.x, position.y); // déplace le centre de la perspective sur les coordonnés de l'objet
      rotate(angle);                     // rotate pivote toute la perspective autour de son centre
      defaultSpriteRight.display(0, 0);  // on peut déssiner l'image dans l'angle courrant de la perspective
      rotate(-angle);                    // avant de la rétablir
      translate(-position.x, -position.y);
    }
  }

  boolean doesTouch(ObjectEntity target) { // renvoie si le centre d'un objet vivant et de la team adverse touche la hitbox du projectile 
    return (sqrt((target.position.x - position.x )*(target.position.x - position.x) + (target.position.y-position.y )*( target.position.y-position.y)) < hitBoxRadius && !target.isDead() && target.belongToPlayerTeam != belongToPlayerTeam);
  }
}
