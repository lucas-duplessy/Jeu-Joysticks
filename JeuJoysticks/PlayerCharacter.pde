class PlayerCharacter extends ObjectEntity {

  int playerNumber, mana, manaMax, breakedGuardCD, attackCombo, baseDamage, attackRange, skillManaCost, speedMod;
  AnimatedSprite moveSpriteRight, moveSpriteLeft, runSpriteRight, runSpriteLeft, blockSpriteRight, blockSpriteLeft, attackSpriteRight1, attackSpriteLeft1, attackSpriteRight2, attackSpriteLeft2, attackSpriteRight3, attackSpriteLeft3, spellSpriteRight, spellSpriteLeft, dieSpriteRight, dieSpriteLeft;
  SystemController controller;
  boolean isUsingGuard, isAttacking, isCasting, cannotMove, castLock;

  ArrayList<Projectile> projectiles;

  PlayerCharacter(PVector pos, String assetsPrefix, int snIdle, int number, int life, int damage, int range, Arduino inputShield) {

    super(pos, new AnimatedSprite("data/ressource/facingLeft/" + assetsPrefix + "_Idle", snIdle, 5), new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Idle", snIdle, 5), true, life);

    playerNumber = number;

    attackHitBox = new DamageArea("rect", true, 0, 0, new PVector(0, 0), 0);

    controller = new SystemController(inputShield);
    controller.initialize();

    cannotMove     = false;
    isUsingGuard   = false;
    castLock       = false;
    mana           = 200;
    manaMax        = 200;
    breakedGuardCD = 0;
    baseDamage     = damage;
    attackRange    = range;
    
    speedMod = 1;

    projectiles = new ArrayList<Projectile>();
  }

  PlayerCharacter(PVector pos, String assetsPrefix, int snIdle, int number, int life, int damage, int range) {

    super(pos, new AnimatedSprite("data/ressource/facingLeft/" + assetsPrefix + "_Idle", snIdle, 5), new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Idle", snIdle, 5), true, life);

    playerNumber = number;

    attackHitBox = new DamageArea("rect", true, 0, 0, new PVector(0, 0), 0);

    controller = new SystemController();

    cannotMove     = false;
    isUsingGuard   = false;
    castLock       = false;
    mana           = 200;
    manaMax        = 200;
    breakedGuardCD = 0;
    baseDamage     = damage;
    attackRange    = range;

    projectiles = new ArrayList<Projectile>();
  }

  void run() {
    controller.readInput();
    update();
    render();
  }

  void update() {

    if (!isDead()) {

      checkAction();

      manageBlockAction();

      manageAttackAction();

      manageCastAction();

      if (controller.rightReleased()) attackCombo = 0;
      if (controller.downReleased()) castLock = false;

      if (breakedGuardCD > 0) {
        breakedGuardCD --;
      }

      velocity.mult(0);
      if (controllers.size() >= 1) {
        if (!cannotMove) {
          velocity = controller.scalledJoystick.copy();
          if (controller.upButton && mana > 3) {
            velocity.mult(0.3);
            if (velocity.mag() > 2) {
              mana -= 2;
            }
          } else {
            velocity.mult(0.2 * speedMod);
          }
        }
      }
      if (mana<manaMax) {
        mana ++;
      }
      if (controller.joystick.x * orientation.x < 0) {
        relaseAttackAnimations();
      }
      if (controller.joystick.mag() != 0)orientation = controller.joystick.copy();

      velocity.add(acceleration);
      if (isOutOfBound(position.copy().add(velocity), 'x')) velocity.x = 0;
      if (isOutOfBound(position.copy().add(velocity), 'y')) velocity.y = 0;

      position.add(velocity);
      lastHP = HP;
    }
    for (int i = projectiles.size()-1; i >= 0; i--) {
      if (projectiles.get(i).endSprite.animationEnded()) {
        projectiles.remove(i);
      }
    }
  }

  void checkAction() {
    isUsingGuard = controller.leftButton && mana > 2 && breakedGuardCD == 0;
    isAttacking  = controller.rightButton && !isUsingGuard;
    isCasting    = controller.downButton && !isUsingGuard && !isAttacking && mana >= skillManaCost;

    cannotMove = isCasting || isAttacking || isUsingGuard;
  }

  void attack(boolean left, int damage) {
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
  void manageBlockAction() {
    if (tookDamage() && isUsingGuard && mana > ((lastHP - HP)*3)) {
      mana -= (lastHP - HP)*3;
      HP = lastHP;
    }
    if (mana < 0) {
      mana = 0;
    }
    if (isUsingGuard && mana < 4) {
      breakedGuardCD = 50;
    }
    if (isUsingGuard) {
      mana -=2;
    }
  }
  void manageAttackAction() {
    if (isAttacking) {
      if (attackSpriteLeft3.animationEnded() || attackSpriteRight3.animationEnded()) {
        if (orientation.x < 0 && attackCombo == 2) {
          attack(true, int(baseDamage));
        } else if (attackCombo == 2) {
          attack(false, int(baseDamage));
        }
        attackCombo = 3;
      } else
        if (attackSpriteLeft2.animationEnded() || attackSpriteRight2.animationEnded()) {
          if (orientation.x < 0 && attackCombo == 1) {
            attack(true, int(baseDamage));
          } else if (attackCombo == 1) {
            attack(false, int(baseDamage));
          }
          attackCombo = 2;
        } else
          if (attackSpriteLeft1.animationEnded() || attackSpriteRight1.animationEnded()) {
            if (orientation.x < 0 && attackCombo == 0) {
              attack(true, int(baseDamage));
            } else if (attackCombo == 0) {
              attack(false, int(baseDamage));
            }
            attackCombo = 1;
          }
    }
  }
  void manageCastAction() {
    ;
  }

  /** ======== RENDER ========================================================================================================================================== **/

  void render() {
    imageMode(CENTER);

    displayCastEffects();
    if (isDead()) {
      if (orientation.x >= 0) {
        dieSpriteRight.displayNoLoop(position.x, position.y);
      } else {
        dieSpriteLeft.displayNoLoop(position.x, position.y);
      }
    } else
      if (isAttacking) {
        animateAttack();
      } else
        if (isCasting) {
          animateCasting();
        } else
          if (isUsingGuard) {
            animateBlock();
          } else
            if (velocity.mag() == 0) {
              if (orientation.x >= 0) {
                defaultSpriteRight.display(position.x, position.y);
              } else {
                defaultSpriteLeft.display(position.x, position.y);
              }
            } else
              if (velocity.mag() < 2.1) {
                if (orientation.x >= 0) {
                  moveSpriteRight.display(position.x, position.y);
                } else {
                  moveSpriteLeft.display(position.x, position.y);
                }
              } else {
                if (orientation.x >= 0) {
                  runSpriteRight.display(position.x, position.y);
                } else {
                  runSpriteLeft.display(position.x, position.y);
                }
              }

    if (!isUsingGuard && blockSpriteLeft.frame != 0) {
      blockSpriteLeft.releaseAnimation();
    }
    if (!isUsingGuard && blockSpriteRight.frame != 0) {
      blockSpriteRight.releaseAnimation();
    }
    if (!controller.downButton && spellSpriteLeft.frame != 0) {
      spellSpriteLeft.releaseAnimation();
    }
    if (!controller.downButton && spellSpriteRight.frame != 0) {
      spellSpriteRight.releaseAnimation();
    }

    if (controller.rightReleased()) {
      relaseAttackAnimations();
    }
    if (!isDead()) {
      textFont(liberationSans);
      String pName = "Player "+(playerNumber+1);
      float pNameWidth;
      fill(255);
      textSize(14); //textSize((width+height)/120);
      pNameWidth = textWidth(pName);
      text(pName, int(position.x)-(pNameWidth/2), int(position.y) - defaultSpriteRight.getHeight()/1.8 - 10 );// -60
      textFont(unbutton);
      
      strokeWeight(2);
      stroke(255, 0, 0);
      noFill();
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, defaultSpriteRight.getWidth()+ 4, 5);
      fill(125, 0, 0);
      strokeWeight(0);
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, (defaultSpriteRight.getWidth() + 4)*lastHP/HPMax, 5);
      fill(255, 0, 0);
      strokeWeight(0);
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 2, (defaultSpriteRight.getWidth() + 4)*HP/HPMax, 5);
      fill(255, 180, 0);
      strokeWeight(0);
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 2, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 6, (defaultSpriteRight.getWidth() + 4)*mana/manaMax, 3);
      strokeWeight(1);
      stroke(0);
      noFill();
      rect(int(position.x) - defaultSpriteRight.getWidth()/2 - 3, int(position.y) - defaultSpriteRight.getHeight()/1.8 - 3, defaultSpriteRight.getWidth() + 6, 7);

      displaySpecialIcon();
    }
  }
  
  void displaySpecialIcon() {
  if (breakedGuardCD > 0) {
        imageMode(CENTER);
        image(findImg("data/ressource/effects/noShieldIcon"), int(position.x) + defaultSpriteRight.getWidth()/2 + 6, int(position.y - defaultSpriteRight.getHeight()/1.8 - 3));
      }
  }

  void animateAttack() {
    if (orientation.x >= 0) {
      switch(attackCombo) {
      case 0:
        attackSpriteRight1.displayNoLoop(position.x, position.y);
        break;
      case 1:
        attackSpriteRight2.displayNoLoop(position.x, position.y);
        break;
      case 2:
        attackSpriteRight3.displayNoLoop(position.x, position.y);
        break;
      case 3:
        attackCombo = 0;
        relaseAttackAnimations();
      }
    } else {
      switch(attackCombo) {
      case 0:
        attackSpriteLeft1.displayNoLoop(position.x, position.y);
        break;
      case 1:
        attackSpriteLeft2.displayNoLoop(position.x, position.y);
        break;
      case 2:
        attackSpriteLeft3.displayNoLoop(position.x, position.y);
        break;
      case 3:
        attackCombo = 0;
        relaseAttackAnimations();
      }
    }
  }

  void animateCasting() {
    if (orientation.x >= 0) {
      spellSpriteRight.displayNoLoop(position.x, position.y);
    } else {
      spellSpriteLeft.displayNoLoop(position.x, position.y);
    }
  }

  void animateBlock() {
    if (orientation.x >= 0) {
      blockSpriteRight.displayNoLoop(position.x, position.y);
    } else {
      blockSpriteLeft.displayNoLoop(position.x, position.y);
    }
    
    imageMode(CENTER);
    image(findImg("data/ressource/effects/shieldIcon"), int(position.x) + defaultSpriteRight.getWidth()/2 + 6, int(position.y - defaultSpriteRight.getHeight()/1.8 - 3));
  }

  void relaseAttackAnimations() {
    attackSpriteLeft1.releaseAnimation();
    attackSpriteLeft2.releaseAnimation();
    attackSpriteLeft3.releaseAnimation();
    attackSpriteRight1.releaseAnimation();
    attackSpriteRight2.releaseAnimation();
    attackSpriteRight3.releaseAnimation();
  }

  void displayCastEffects() {
    ;
  }
}


class FireWarrior extends PlayerCharacter {

  int castIndicatorAlphaMask;

  FireWarrior(PVector pos, int pNumber, Arduino inputShield) {
    super(pos, "Fire_Warrior", 8, pNumber, 100, 25, 55, inputShield);
    String assetsPrefix = "Fire_Warrior";

    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 11, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 11, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Block", 6, 5);
    blockSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Block", 6, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteRight2  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteLeft2   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteRight3  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack3_", 4, 5);
    attackSpriteLeft3   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack3_", 4, 5);
    spellSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Spell", 9, 5);
    spellSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Spell", 9, 5);


    skillManaCost = 70;

    castIndicatorAlphaMask = 0;
  }

  FireWarrior(PVector pos, int pNumber) {
    super(pos, "Fire_Warrior", 8, pNumber, 100, 25, 55);
    String assetsPrefix = "Fire_Warrior";

    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 11, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 11, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Block", 6, 5);
    blockSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Block", 6, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteRight2  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteLeft2   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteRight3  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack3_", 4, 5);
    attackSpriteLeft3   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack3_", 4, 5);
    spellSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Spell", 9, 5);
    spellSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Spell", 9, 5);


    skillManaCost = 70;

    castIndicatorAlphaMask = 0;
  }

  void manageCastAction() {
    if (isCasting && !castLock && (spellSpriteLeft.animationGotToFrame(6) || spellSpriteRight.animationGotToFrame(6))) {
      mana -= skillManaCost;
      projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), orientation, 8, 0, 0, belongToPlayerTeam, 50, 40, 20, "Fireorb", 4, 28));
      castLock = true;
    }
  }

  void displayCastEffects() {
    if (isCasting && !spellSpriteLeft.animationEnded() && ! spellSpriteRight.animationEnded()) {
      float angle = PI + PVector.angleBetween(new PVector(0, -1), orientation);
      if (orientation.x < 0) {
        angle = -angle;
      }
      if (castIndicatorAlphaMask < 255) {
        castIndicatorAlphaMask += 10;
      }

      translate(position.x, position.y);
      rotate(angle);
      tint(255, castIndicatorAlphaMask);
      image(findImg("data/ressource/effects/orientationIndicatorRed"), 0, 0);
      noTint();
      rotate(-angle);
      translate(-position.x, -position.y);
    } else {
      castIndicatorAlphaMask = 0;
    }
  }
}

class Viking extends PlayerCharacter {

  int thunderStrikeTrigger;

  Viking(PVector pos, int pNumber, Arduino inputShield) {
    super(pos, "Viking", 8, pNumber, 120, 34, 35, inputShield);

    String assetsPrefix = "Viking";
    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 12, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 12, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Block", 6, 5);
    blockSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Block", 6, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteRight2  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteLeft2   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteRight3  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack3_", 4, 5);
    attackSpriteLeft3   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack3_", 4, 5);
    spellSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Spell", 9, 5);
    spellSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Spell", 9, 5);

    thunderStrikeTrigger = 0;
    skillManaCost = 130;
  }

  Viking(PVector pos, int pNumber) {
    super(pos, "Viking", 8, pNumber, 100, 34, 35);

    String assetsPrefix = "Viking";
    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 12, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 12, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Block", 6, 5);
    blockSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Block", 6, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack1_", 4, 5);
    attackSpriteRight2  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteLeft2   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack2_", 4, 5);
    attackSpriteRight3  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack3_", 4, 5);
    attackSpriteLeft3   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack3_", 4, 5);
    spellSpriteRight    = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Spell", 9, 5);
    spellSpriteLeft     = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Spell", 9, 5);

    thunderStrikeTrigger = 0;
    skillManaCost = 130;
  }

  void manageCastAction() {

    if (isCasting && !castLock && (spellSpriteLeft.animationGotToFrame(8) || spellSpriteRight.animationGotToFrame(8))) {
      mana -= skillManaCost;

      thunderStrikeTrigger = 10;

      attackHitBox.isResolved = false;
      attackHitBox.position.x = position.x - 100;
      attackHitBox.position.y = position.y - 50;
      attackHitBox.areaWidth = 200;
      attackHitBox.areaHeight = 100;
      attackHitBox.damage = 100;
      castLock = true;
    }
  }

  void displayCastEffects() {
    if (thunderStrikeTrigger > 0) {
      fill(0, 0, 0, 75);
      noStroke();
      rect(0, 0, width, height);
      imageMode(CENTER);
      if (thunderStrikeTrigger < 5) {
        image(findImg("data/ressource/effects/lightning1"), position.x + 20, position.y - 470);
      } else if (thunderStrikeTrigger >5) {
        image(findImg("data/ressource/effects/lightning2"), position.x + 80, position.y - 470);
      }
      fill(255, 255, 255, 20);
      noStroke();
      ellipseMode(CENTER);
      ellipse(position.x, position.y, 200, 100);
      thunderStrikeTrigger --;
    }
  }
}

class Archer extends PlayerCharacter {
  int orientationIndicatorAlphaMask, dashCD;

  Archer(PVector pos, int pNumber, Arduino inputShield) {
    super(pos, "Elf_Archer", 4, pNumber, 80, 34, 0, inputShield);

    String assetsPrefix = "Elf_Archer";
    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 8, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 8, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("", 0, 5);
    blockSpriteLeft     = new AnimatedSprite("", 0, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack", 10, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack", 10, 5);
    attackSpriteRight2  = new AnimatedSprite("", 0, 5);
    attackSpriteLeft2   = new AnimatedSprite("", 0, 5);
    attackSpriteRight3  = new AnimatedSprite("", 0, 5);
    attackSpriteLeft3   = new AnimatedSprite("", 0, 5);
    spellSpriteRight    = new AnimatedSprite("", 0, 5);
    spellSpriteLeft     = new AnimatedSprite("", 0, 5);

    skillManaCost = 100;
  }

  Archer(PVector pos, int pNumber) {
    super(pos, "Elf_Archer", 4, pNumber, 100, 34, 0);

    String assetsPrefix = "Elf_Archer";
    dieSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Death", 8, 5);
    dieSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Death", 8, 5);
    moveSpriteRight     = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Walk", 8, 5);
    moveSpriteLeft      = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Walk", 8, 5);
    runSpriteRight      = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Run", 8, 5);
    runSpriteLeft       = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Run", 8, 5);
    blockSpriteRight    = new AnimatedSprite("", 0, 5);
    blockSpriteLeft     = new AnimatedSprite("", 0, 5);
    attackSpriteRight1  = new AnimatedSprite("data/ressource/facingRight/" + assetsPrefix + "_Attack", 10, 5);
    attackSpriteLeft1   = new AnimatedSprite("data/ressource/facingLeft/"  + assetsPrefix + "_Attack", 10, 5);
    attackSpriteRight2  = new AnimatedSprite("", 0, 5);
    attackSpriteLeft2   = new AnimatedSprite("", 0, 5);
    attackSpriteRight3  = new AnimatedSprite("", 0, 5);
    attackSpriteLeft3   = new AnimatedSprite("", 0, 5);
    spellSpriteRight    = new AnimatedSprite("", 0, 5);
    spellSpriteLeft     = new AnimatedSprite("", 0, 5);
    
    skillManaCost = 100;
  }

  void checkAction() {
    isUsingGuard = controller.leftButton && mana >= 10 && dashCD < 100;
    isAttacking  = controller.rightButton && !isUsingGuard;
    isCasting    = controller.downButton && !isUsingGuard && !isAttacking && mana >= skillManaCost;

    cannotMove = isCasting || isAttacking;
  }
  
  void manageBlockAction(){
    if(dashCD > 0){
      dashCD --;
    }
    
    if(isUsingGuard){
      dashCD += 20;
      mana -= 10;
      if(dashCD >= 100){
        dashCD =200;
      }
      speedMod = 10;
    }else{
      speedMod = 1;
    }
  }

  void manageAttackAction() {
    if (isAttacking && (attackSpriteRight1.animationGotToFrame(8) || attackSpriteLeft1.animationGotToFrame(8))) {
      if (orientation.y >=0 ) {
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(PVector.angleBetween(new PVector(1, 0), orientation)      ), 20, 0, 2, belongToPlayerTeam, baseDamage, 20, 15, "Arrow", 4, 0));
      } else {
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(-PVector.angleBetween(new PVector(1, 0), orientation)      ), 20, 0, 2, belongToPlayerTeam, baseDamage, 20, 15, "Arrow", 4, 0));
      }
    }
    if (controller.rightReleased()) {
      orientationIndicatorAlphaMask = 0;
      attackSpriteRight1.releaseAnimation();
      attackSpriteLeft1.releaseAnimation();
    }
  }

  void manageCastAction() {
    if (isCasting && (attackSpriteRight1.animationGotToFrame(8) || attackSpriteLeft1.animationGotToFrame(8))) {
      mana -= skillManaCost;
      if (orientation.y >=0 ) {
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(PVector.angleBetween(new PVector(1, 0), orientation)+ 0.25), 40, 0, 3, belongToPlayerTeam, 25, 20, 15, "ArrowBlue", 4, 0));
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(PVector.angleBetween(new PVector(1, 0), orientation)      ), 40, 0, 3, belongToPlayerTeam, 25, 20, 15, "ArrowBlue", 4, 0));
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(PVector.angleBetween(new PVector(1, 0), orientation)- 0.25), 40, 0, 3, belongToPlayerTeam, 25, 15, 15, "ArrowBlue", 4, 0));
      } else {
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(-PVector.angleBetween(new PVector(1, 0), orientation)+ 0.25), 40, 0, 3, belongToPlayerTeam, 25, 15, 15, "ArrowBlue", 4, 0));
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(-PVector.angleBetween(new PVector(1, 0), orientation)      ), 40, 0, 3, belongToPlayerTeam, 25, 20, 15, "ArrowBlue", 4, 0));
        projectiles.add(new Projectile((position.copy().add(orientation.setMag(30))), PVector.fromAngle(-PVector.angleBetween(new PVector(1, 0), orientation)- 0.25), 40, 0, 3, belongToPlayerTeam, 25, 15, 15, "ArrowBlue", 4, 0));
      }
    }
    if (controller.downReleased()) {
      orientationIndicatorAlphaMask = 0;
      attackSpriteRight1.releaseAnimation();
      attackSpriteLeft1.releaseAnimation();
    }
  }
  
  void displaySpecialIcon(){
    if(dashCD > 100){
    imageMode(CENTER);
    image(findImg("data/ressource/effects/noDashIcon"), int(position.x) + defaultSpriteRight.getWidth()/2 + 6, int(position.y - defaultSpriteRight.getHeight()/1.8 - 3));
    }
  }

  void animateAttack() {
    displayOrientationVector();

    if (orientation.x >= 0) {
      attackSpriteRight1.display(position.x, position.y);
    } else {
      attackSpriteLeft1.display(position.x, position.y);
    }
  }

  void animateCasting() {

    if (!attackSpriteRight1.animationEnded() && !attackSpriteLeft1.animationEnded()) {
      displayOrientationVector();
    }
    if (orientation.x >= 0) {
      attackSpriteRight1.displayNoLoop(position.x, position.y);
    } else {
      attackSpriteLeft1.displayNoLoop(position.x, position.y);
    }
  }

  void animateBlock() {
    if (orientation.x >= 0) {
      runSpriteRight.display(position.x, position.y);
    } else {
      runSpriteLeft.display(position.x, position.y);
    }
    
    imageMode(CENTER);
    image(findImg("data/ressource/effects/DashIcon"), int(position.x) + defaultSpriteRight.getWidth()/2 + 6, int(position.y - defaultSpriteRight.getHeight()/1.8 - 3));
  }

  void displayOrientationVector() {

    float angle = PI + PVector.angleBetween(new PVector(0, -1), orientation);

    if (orientation.x < 0) {
      angle = -angle;
    }
    if (orientationIndicatorAlphaMask < 255) {
      orientationIndicatorAlphaMask += 10;
    }

    translate(position.x, position.y);
    rotate(angle);
    tint(255, orientationIndicatorAlphaMask);
    image(findImg("data/ressource/effects/orientationIndicatorGreen"), 0, 0);
    noTint();
    rotate(-angle);
    translate(-position.x, -position.y);
    if (attackSpriteRight1.animationGotToFrame(9) || attackSpriteLeft1.animationGotToFrame(9)) {
      orientationIndicatorAlphaMask = 0;
    }
  }
}
