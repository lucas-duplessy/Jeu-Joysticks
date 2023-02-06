class Mob extends ObjectEntity { // hérite de ObjectEntity
  /** 
  classe des personnages non joueurs des adversaires
  
  la stucture de cette classe permet en fonction du constructeur utilisé de créer des
  adversaires se battant au corps à corps ou à distance
  **/

  //arg:
  int attackRange,    // l'allonge de l'attaque si mob de CàC ou la portée de tir si mob de distance
    attackCooldown,   // valeur courante du temps de repos après attaque
    cooldownDuration, // durée de repos après une attaque
    attackDamage,     
    corpseLifespawn,  // durée pednant laquelle le mob sera affiché après sa mort avant d'être supprimé, défaut 200
    stunDuration;     // valeur courante du temps pendant lequel un enemi est étourdi

  float movementSpeed;

  PlayerCharacter targetedPlayer;
  PVector targetPosition; 
  
  AnimatedSprite moveSpriteRight, moveSpriteLeft, attackSpriteRight, attackSpriteLeft, dieSpriteRight, dieSpriteLeft, stunSpriteRight, stunSpriteLeft;

  Projectile projType; // contient un modèle de Projectile qui sera copié à chaque fois que le mob tire un projectile
  ArrayList<Projectile> projectiles; // liste des projectiles courrants

  boolean isAttacking, 
          isRanged;  // définit si le mob tire un projectile pour attaquer ou non

  //const:
  Mob(PVector pos, String assetsPrefix, int life, float speed, int damage, int range, int cooldown, PlayerCharacter target, int nsMove, int nsAttack, int nsDie, int nsStun) {
  // constructeur de mob de mélée
  
    super(pos, new AnimatedSprite("data/ressource/facingLeft/" + assetsPrefix + "_Idle", 4, 5), new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Idle", 4, 5), false, life); // super-constructeur du ObjectEntity

    moveSpriteRight  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", nsMove, 5);
    moveSpriteLeft   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", nsMove, 5);
    attackSpriteRight= new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack", nsAttack, 5);
    attackSpriteLeft = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack", nsAttack, 5);
    dieSpriteRight   = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", nsDie, 5);
    dieSpriteLeft    = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", nsDie, 5);
    stunSpriteRight  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Hit", nsStun, 2);
    stunSpriteLeft   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Hit", nsStun, 2);

    attackHitBox = new DamageArea("rect", false, 0, 0, new PVector(0, 0), 0);

    movementSpeed    = speed;
    targetedPlayer   = target;
    targetPosition   = target.position.copy();
    attackDamage     = damage;
    attackRange      = range;
    cooldownDuration = cooldown;
    attackCooldown   = 0;
    corpseLifespawn  = 200;
    stunDuration     = 0;

    isRanged = false;

    projectiles = new ArrayList<Projectile>();
  }

  Mob(PVector pos, String assetsPrefix, int life, float speed, int damage, int range, int cooldown, PlayerCharacter target, int nsMove, int nsAttack, int nsDie, int nsStun, String pString, int nsProj, int nsEndProj, int pHitBox, float pSpeed, int pDamageArea) {
  //constructeur de mob lancant des projectiles
    
    this(pos, assetsPrefix, life, speed, damage, range, cooldown, target, nsMove, nsAttack, nsDie, nsStun); // permet d'appeler un autre constructeur

    isRanged = true;
    projType = new Projectile((position.copy().add(orientation.setMag(15))), orientation, pSpeed, 0, 0, belongToPlayerTeam, attackDamage, pDamageArea, pHitBox, pString, nsProj, nsEndProj);
  }

  //methods:
  void run() {
    update(); //met à jour les donnés de jeu de l'entité
    render(); //affiche l'entité telle qu'elle doit l'être
  }

  void update() {
    if (isRanged) {
      // le modèle de projectile est en permanance ancré à la position de tir
      // (la seule différence entre le modèle de projectile et un véritable projectile est que le modèle n'est jamais "run")
      projType.position = position.copy().add(orientation.setMag(15));
      projType.orientation = orientation.copy();
    }

    if (tookDamage()) {
      stunDuration = 8;
    }

    if (!isDead() && !isAttacking && attackCooldown == 0 && sqrt((targetPosition.x - position.x)*(targetPosition.x - position.x)+(targetPosition.y - position.y)*(targetPosition.y - position.y)) <= attackRange) {
      isAttacking = true;
    }

    if (attackSpriteLeft.animationEnded() || attackSpriteRight.animationEnded()) {
      if (isRanged) {
        projectiles.add(projType.copy()); // l'attaque à distance est simplement une copie du modèle de projectile dans la liste des projectiles courants
      } else {
        if (orientation.x >= 0) {
          attack(false, 10);
        } else {
          attack(true, 10);
        }
      }
      attackSpriteLeft.releaseAnimation(); 
      attackSpriteRight.releaseAnimation();
      attackCooldown = cooldownDuration;
      isAttacking = false;
    }

    for (int i = projectiles.size()-1; i >= 0; i--) {
      if (projectiles.get(i).endSprite.animationEnded() || (projectiles.get(i)).isOutOfMap()) {
        //retire (et destruct) le projectile si son animation de touche se termine où si il sort de l'écran 
        projectiles.remove(i);
      }
    }

    if (attackCooldown > 0) {
      attackCooldown --;
    }

    if (isDead()) {
      velocity.mult(0); // même si l'on ne met pas à jour la position, on défini la vélocité théorique à zero au cas où on voudrait l'utiliser ailleurs
      corpseLifespawn --;
    } else if (isStunned() || isAttacking) {
      velocity.mult(0); // même si l'on ne met pas à jour la position, on défini la vélocité théorique à zero au cas où on voudrait l'utiliser ailleurs
    } else {
      position.add(velocity); // mise à jour de la position
    }
    
    if (! isDead() && !isStunned()) {
      targetPosition = targetedPlayer.position.copy(); // on utilise la méthode PVector.copy() pour éviter de créer un pointeur et modifier par erreur la position de la cible

      orientation.x = targetPosition.x - position.x;  //mise à jour de l'orientation pour que le mob fasse façe à sa cible
      orientation.y = targetPosition.y - position.y;
      
      if (! isAttacking && !(sqrt((targetPosition.x - position.x)*(targetPosition.x - position.x)+(targetPosition.y - position.y)*(targetPosition.y - position.y)) <= attackRange)) {
        velocity = orientation.copy().setMag(movementSpeed); // mise à jour de la vitesse
      }
    }

    if (stunDuration > 0) {
      stunDuration --;
    } else {
      stunSpriteLeft.releaseAnimation();
      stunSpriteRight.releaseAnimation();
    }

    lastHP = HP;
  }

  void attack(boolean left, int damage) {
    /** méthode manipulant la zone de dégâts pour éffectuer une attaque **/
    
    attackHitBox.isResolved = false;
    if (left) {
      attackHitBox.position.x = position.x - attackRange;
    } else {
      attackHitBox.position.x = position.x;
    }
    attackHitBox.position.y = position.y - 30;
    attackHitBox.areaWidth = attackRange;
    attackHitBox.areaHeight = 60;
    attackHitBox.damage = damage;
  }

  void render() {
    imageMode(CENTER);
    if (isDead()) {
      if (orientation.x >= 0 ) {
        dieSpriteRight.displayNoLoop(position.x, position.y);
      } else {
        dieSpriteLeft.displayNoLoop(position.x, position.y);
      }
    } else if (velocity.mag() > 0) {
      if (orientation.x >= 0 ) {
        moveSpriteRight.display(position.x, position.y);
      } else {
        moveSpriteLeft.display(position.x, position.y);
      }
    } else if (isAttacking) {
      if (orientation.x >= 0 ) {
        attackSpriteRight.displayNoLoop(position.x, position.y);
      } else {
        attackSpriteLeft.displayNoLoop(position.x, position.y);
      }
    } else if (isStunned()) {
      if (orientation.x >= 0 ) {
        stunSpriteRight.displayNoLoop(position.x, position.y);
      } else {
        stunSpriteLeft.displayNoLoop(position.x, position.y);
      }
    } else {
      if (orientation.x >= 0 ) {
        defaultSpriteRight.display(position.x, position.y);
      } else {
        defaultSpriteLeft.display(position.x, position.y);
      }
    }

    if (HP != HPMax && ! isDead()) { // dessin de la barre de vie
      strokeWeight(2);
      stroke(255, 0, 0);
      noFill();
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, defaultSpriteRight.getWidth() + 4, 5);
      fill(125, 0, 0);
      strokeWeight(0);
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, (defaultSpriteRight.getWidth() + 4)*lastHP/HPMax, 5);
      fill(255, 0, 0);
      strokeWeight(0);
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, (defaultSpriteRight.getWidth() + 4)*HP/HPMax, 5);
    }
  }

  boolean isStunned() {
    return(stunDuration > 0);
  }
}
