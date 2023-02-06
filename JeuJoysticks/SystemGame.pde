class SystemGame {
  int killCount, wave;
  ArrayList<PlayerCharacter> players;
  ArrayList<Mob> mobs;
  ArrayList<Projectile> projectiles;
  ArrayList<DamageArea> damageInstances;

  AnimatedSprite menuSprite1, menuSprite2, menuSprite3;

  StringList listCharacters; // listes des noms de personnages
  IntList choixPlayer; // numéro du choix du joueur

  StringList buttons; // listes des buttons disponibles (menu)
  int button; // boutton actuel
  boolean lock = false, lockMenu = false; // verouille choix des personnages
  boolean restart;

  boolean start = false; //permet d'avoir un timer plus précis (initialisé au debut de la partie)

  SystemGame() {
    players = new ArrayList<PlayerCharacter>();
    mobs = new ArrayList<Mob>();
    projectiles = new ArrayList<Projectile>();
    damageInstances = new ArrayList<DamageArea>();

    killCount = 0;
    wave = 0;
    restart = false;

    menuSprite1 = new AnimatedSprite("data/ressource/facingRight/Viking_Idle", 8, 5);
    menuSprite2 = new AnimatedSprite("data/ressource/facingRight/Fire_Warrior_Idle", 8, 5);
    menuSprite3 = new AnimatedSprite("data/ressource/facingRight/Elf_Archer_Idle", 4, 10);
  }

  void personnages() {
    if (controllers.size() >= 1) {
      for (int i = 0; i < 2; i++) {
        int pos;
        boolean num = boolean(i);
        if (num) {
          pos = -100;
        } else {
          pos = 100;
        }
        if (listCharacters.get(choixPlayer.get(i)) == "Viking") {
          players.add(new Viking(new PVector(width/2 + pos, height/2), i, controllers.get(i)));
        } else if (listCharacters.get(choixPlayer.get(i)) == "FireWarrior") {
          players.add(new FireWarrior(new PVector(width/2 + pos, height/2), i, controllers.get(i)));
        } else if (listCharacters.get(choixPlayer.get(i)) == "Archer") {
          players.add(new Archer(new PVector(width/2 + pos, height/2), i, controllers.get(i)));
        }
      }
    } else {
      for (int i = 0; i < 2; i++) {
        int pos;
        boolean num = boolean(i);
        if (num) {
          pos = -100;
        } else {
          pos = 100;
        }
        if (listCharacters.get(choixPlayer.get(i)) == "Viking") {
          players.add(new Viking(new PVector(width/2 + pos, height/2), i));
        } else if (listCharacters.get(choixPlayer.get(i)) == "FireWarrior") {
          players.add(new FireWarrior(new PVector(width/2 + pos, height/2), i));
        } else if (listCharacters.get(choixPlayer.get(i)) == "Archer") {
          players.add(new Archer(new PVector(width/2 + pos, height/2), i));
        }
      }
    }
  }

  void displayEndScreen() {
    if (clock.running) {
      clock.stop();
      ////println("Partie terminée en "+clock.timer() + "." + clock.precision()+"secondes.");
      ////println("vague : " + wave +", avec " + killCount + " kills.");
    }
    fill(#F7F23E);
    textSize((width+height)/10);
    String tmp = "END";
    float tmpWidth = textWidth(tmp);
    text(tmp, width/2-(tmpWidth/2), height/4);
    fill(#FFFFFF);
    textSize((width+height)/20);
    tmp = "Temps : " + clock.timer()+ "." + clock.precision()+"s";
    tmpWidth = textWidth(tmp);
    text(tmp, width/2-(tmpWidth/2), 3*height/8);
    tmp = "Vague : " + wave;
    tmpWidth = textWidth(tmp);
    text(tmp, width/2-(tmpWidth/2), 4.5*height/8);
    tmp = "Kills : " + killCount;
    tmpWidth = textWidth(tmp);
    text(tmp, width/2-(tmpWidth/2), 6*height/8);

    fill(#F7F23E);
    tmp = "Press R to restart";
    tmpWidth = textWidth(tmp);
    text(tmp, width/2-(tmpWidth/2), 7.5*height/8);


    if (keyPressed) {
      if (key == 'r' || key == 'R') {
        restart = true;
      }
    }
  }

  void characterSelect() {
    if (listCharacters == null) {
      init();
    }
    backgroundSelect();
  }

  void backgroundSelect() {
    String Text;
    float sizeText;
    strokeWeight(0);
    fill(#5350ff);
    rect(0, 0, width/3, height);
    fill(#ff5050);
    rect(width/3, 0, width/3, height);
    fill(#00D132);
    rect(2*width/3, 0, width/3, height);
    fill(0, 100);
    rect(0, 0.35*height/5, width, 1*height/5);
    
    tint(255, 155);
    menuSprite1.display(width/6, height/20 - 3);
    menuSprite2.display(width/2, height/20 - 3);
    menuSprite3.display(5*width/6, height/20 - 3);
    noTint();

    fill(255);
    textSize((width+height)/40);
    strokeWeight(6);
    for (int i = 0; i < 3; i++) {
      Text = listCharacters.get(i);
      if (Text.contains("Fire")) {
        Text = "Fire";
        sizeText = textWidth(Text);
        text(Text, ((i+0.5)*width/3)-(sizeText/2), height/6);
        Text = "Warrior";
        sizeText = textWidth(Text);
        text(Text, ((i+0.5)*width/3)-(sizeText/2), 1.4*height/6);
      } else {
        sizeText = textWidth(Text);
        text(Text, ((i+0.5)*width/3)-(sizeText/2), height/6);
      }
    }
    textSize((width+height)/30);
    for (int i = 0; i < 2; i++) { //Player
      //Text = "Player" + i;
      Text = String.valueOf(i+1);
      sizeText = textWidth(Text);
      fill(#000000);
      shape(manette, ((choixPlayer.get(i) +1.5))*width/3-(manette.width/2), (i+1.15)*height/3);
      fill(#FFFFFF);
      text(Text, ((choixPlayer.get(i) +0.5))*width/3-(sizeText/2), (i+1.5)*height/3);
    }
  }

  void afficheTimer() {
    fill(255);
    textSize((width+height)/60);
    //String timer= String.valueOf(clock.timer());
    String timer = clock.timer() + "." +clock.precision();
    float timerWidth = textWidth(timer);
    text(timer, width/2-(timerWidth/2), height/10);
  }

  void menu() {
    drawMenu();
    if (lockMenu) {
      switch(button) {
      case 0: // restart
        restart = true;
        break;
      case 1: // Exit
        exit();
        break;
      }
    }
  }

  void drawMenu() {
    fill(#FB8FBB);
    textSize((width+height)/12);
    String tmp = "Pause";
    float tmpTaille = textWidth(tmp);
    text(tmp, (width/2)-(tmpTaille/2), (1.2*height/4));
    // buttons
    textSize((width+height)/30);
    fill (255);
    for (int i = 0; i < buttons.size(); i++) {
      tmp = buttons.get(i);
      tmpTaille = textWidth(tmp);
      text(tmp, (width/2)-(tmpTaille/2), (((i*0.8)+2)*height/4));
    }
    fill (#FB8FBB);
    tmp = buttons.get(button);
    tmpTaille = textWidth(tmp);
    //////println(tmp);
    text(tmp, (width/2)-(tmpTaille/2), (((button*0.8)+2)*height/4));
  }

  void init() {
    listCharacters = new StringList();
    listCharacters.append("Viking");
    listCharacters.append("FireWarrior");
    listCharacters.append("Archer");

    buttons = new StringList();
    //buttons.append("0");
    buttons.append("Restart");
    buttons.append("Exit");

    choixPlayer = new IntList();
    for (int i=0; i < 2; i++) {
      choixPlayer.append(0);
    }
  }

  void run() {
    
    if (players.get(0).isDead() && players.get(1).isDead()) {//personnages mort
      displayEndScreen();
    } else {
      if (mobs.size() == 0) {
        spawnWave();

        for (PlayerCharacter p : players) { // heal de 30 pv à chaque début de vague
          if (!p.isDead()) {
            p.HP += 30;
            if (p.HP > p.HPMax) {
              p.HP = p.HPMax;
            }
          }
        }
      }

      for (int i = mobs.size()-1; i >= 0; i --) { // run des mobs
        mobs.get(i).run();
        for (Projectile pp : mobs.get(i).projectiles) {
          projectiles.add(pp);
        }
        if (mobs.get(i).targetedPlayer.isDead()) {
          //////println("retargeting");
          PlayerCharacter newTarget = players.get(0);
          for (PlayerCharacter p : players) {
            ////print("distance from p" + p.playerNumber + " : " + p.position.copy().sub(mobs.get(i).position).mag()); if(p.isDead())//print(" DEAD"); ////println("");
            if (!p.isDead() && (p.position.copy().sub(mobs.get(i).position).mag() < newTarget.position.copy().sub(mobs.get(i).position).mag()) || newTarget.isDead()) {
              newTarget = p;
            }
          }
          //////println("new target: p" + newTarget.playerNumber);
          mobs.get(i).targetedPlayer = newTarget;
        }
        if (!mobs.get(i).attackHitBox.isResolved) {
          damageInstances.add(mobs.get(i).attackHitBox);
        }
        if (mobs.get(i).corpseLifespawn <= 0) {
          mobs.remove(i);
          killCount ++;
          //////println("killCount :" + killCount);
        }
      }

      for (PlayerCharacter p : players) { // run des joueurs
        p.run();
        for (Projectile pp : p.projectiles) {
          projectiles.add(pp);
        }
        if (!p.attackHitBox.isResolved) {
          damageInstances.add(p.attackHitBox);
        }
      }

      for (int i = projectiles.size()-1; i >= 0; i--) { // run des projectiles (l'ArrayList est renouvelée à chaque cycle)
        boolean retarget = false;
        projectiles.get(i).run();
        projectiles.get(i).hit = false;

        for (Mob m : mobs) {
          if ( projectiles.get(i).doesTouch(m) && !projectiles.get(i).isDead() && projectiles.get(i).chainCooldown == 0) {
            projectiles.get(i).hit = true;
            damageInstances.add(projectiles.get(i).attackHitBox);
            if (projectiles.get(i).chainRemaining > 0) {
              retarget = true;
            }
          }
        }
        for (PlayerCharacter p : players) {
          if ( projectiles.get(i).doesTouch(p) && !projectiles.get(i).isDead()) {
            if (projectiles.get(i).chainCooldown == 0) {
              projectiles.get(i).hit = true;
              damageInstances.add(projectiles.get(i).attackHitBox);
            } else if (projectiles.get(i).chainCooldown == 9) {
              projectileRetarget(projectiles.get(i));
              retarget = true;
            }
          }
        }
        if (projectiles.get(i).chainRemaining > 0 && projectiles.get(i).hit) {
          projectiles.get(i).chainRemaining --;
          projectiles.get(i).chainCooldown = 10;
        }

        if ((retarget || (projectiles.get(i).isOutOfBound() && projectiles.get(i).chainRemaining > 0) && projectiles.get(i).chainCooldown == 0) && mobs.size() > 0) {
          projectileRetarget(projectiles.get(i));
        }

        projectiles.remove(i);
      }

      for (int i = damageInstances.size()-1; i >= 0; i--) {
        for (PlayerCharacter p : players) {
          damageInstances.get(i).applyDamage(p);
        }
        for (Mob m : mobs) {
          damageInstances.get(i).applyDamage(m);
        }
        damageInstances.get(i).isResolved = true;
        damageInstances.remove(i);
      }

      fill(255);
      textAlign(LEFT);
      textFont(liberationSans);
      textSize(16);
      text("Kills: " + killCount, width - 200, height -50);
      text("Wave: " + wave, width - 100, height -50);
      textFont(unbutton);
      afficheTimer();
    }
    if (!start) {
      clock.start();
      start = true;
    }
  }//endRUN

  void projectileRetarget(Projectile p) { 
  /** methode pour rediriger un projectile vers une cible la plus proche au dela d'une distance minimale**/
    //////println("projRetargeting:");

    p.chainCooldown = 10; // pendant 10 cycles le projectile ne pourra pas rebondir (pour s'assurer qu'il ne rebondisse pas en boucle dans un objet trop large)
    p.chainRemaining --;

    int i = 0;
    int j = 0;
    ObjectEntity currentTarget;
    if (p.belongToPlayerTeam) {
      currentTarget = mobs.get(0);
      for (Mob m : mobs) {
        if (!m.isDead() && (currentTarget.position.copy().sub(p.position).mag() < 100/p.velocity.mag() || (m.position.copy().sub(p.position).mag() > 100/p.velocity.mag() && m.position.copy().sub(p.position).mag() < currentTarget.position.copy().sub(p.position).mag()))) {
          currentTarget = m;
          j = i;
        }
        //////println("distance to target " + i + ": " + m.position.copy().sub(p.position).mag() + "  min dist is : " + 100);
        i++;
      }
    } else {
      currentTarget = players.get(0);
      for (PlayerCharacter n : players) {
        if (n.position.copy().sub(p.position).mag() > p.velocity.mag() && n.position.copy().sub(p.position).mag() < currentTarget.position.copy().sub(p.position).mag()) {
          currentTarget = n;
        }
      }
    }
    //////println("new target is target " + j);
    p.orientation = new PVector(currentTarget.position.x - p.position.x, currentTarget.position.y - p.position.y);
    p.velocity = p.orientation.copy().setMag(p.velocity.mag());
  }

  void spawnMob(String mobType, PVector pos) { 

    // cherche le joueur le plus proche de la position d'apparition pour l'envoyer en cible dans le constructeur
    PlayerCharacter newTarget = players.get(0);
    for (PlayerCharacter p : players) {
      if (!p.isDead() && p.position.copy().sub(pos).mag() < newTarget.position.copy().sub(pos).mag()) {
        newTarget = p;
      }
    }

    switch(mobType) { // selecteur de mobs, pour en ajouter un nouveau il suffit d'ajouter un case avec un nouveau constructeur
    case "Goblin":
      mobs.add(new Mob(pos, "Goblin", 100, 1.2, 10, 25, 40, newTarget, 4, 7, 12, 4));
      break;
    case "Goblin_Soldier":
      mobs.add(new Mob(pos, "Goblin_Soldier", 150, 1, 25, 25, 40, newTarget, 4, 7, 12, 4));
      break;
    case "Goblin_Spear":
      mobs.add(new Mob(pos, "Goblin_Spearman", 75, 1.2, 10, 500, 80, newTarget, 8, 8, 12, 4, "Spear", 4, 0, 6, 15, 15));
      break;
    case "Skeleton_Archer":
      mobs.add(new Mob(pos, "Skeleton_Archer", 100, 1, 15, 700, 60, newTarget, 8, 9, 9, 4, "Arrow", 4, 0, 12, 15, 15));
      break;
    case "Skeleton_Warrior":
      mobs.add(new Mob(pos, "Skeleton_Warrior", 150, 0.9, 25, 40, 40, newTarget, 8, 7, 9, 4));
    }
  }

  void spawnWave() {
    PVector[] entryPoints = {new PVector(50, 0.7*height), new PVector(50, 0.33*height), new PVector(0.15*width, 0.20*height), new PVector(0.458*width, 0.20*height), new PVector(width - 50, 0.33*height)}; // définit les positions où l'on veux que les mobs apparaissent
    int randomInt;
    int amountToSpawn;

    wave ++;

    if (killCount < 10) {
      amountToSpawn = 4;
    } else if (killCount < 20) {
      amountToSpawn = 6 + int(killCount/5);
    } else {
      amountToSpawn = 8 + int(killCount/5);
    }

    for (int i = 0; i< amountToSpawn; i++) {
      if (killCount < 10) {
        randomInt = 1;                   // spawn goblin uniquement
      } else if (killCount < 20) {
        randomInt = int(random(1, 2+1)); // spawn goblin où mobs de melée avancés
      } else {
        randomInt = int(random(1, 3+1)); // spawn goblin, mobs de melée avancés et mobs à distance
      }

      switch(randomInt) {
      case 1:
        spawnMob("Goblin", entryPoints[int(random(0, 5))].add(PVector.random2D().setMag(20)));
        break;
      case 2:
        int randomIntBis = int(random(0, 2));
        if (randomIntBis == 0) {
          spawnMob("Goblin_Soldier", entryPoints[int(random(0, 5))].add(PVector.random2D().setMag(20)));
        } else {
          spawnMob("Skeleton_Warrior", entryPoints[int(random(0, 5))].add(PVector.random2D().setMag(20)));
        }
        break;
      case 3:
        int randomIntTri = int(random(0, 2));
        if (randomIntTri == 0) {
          spawnMob("Goblin_Spear", entryPoints[int(random(0, 5))].add(PVector.random2D().setMag(20)));
        } else {
          spawnMob("Skeleton_Archer", entryPoints[int(random(0, 5))].add(PVector.random2D().setMag(20)));
        }
        break;
      }
    }
  }
}
