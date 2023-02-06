class clockTimer {
  /*
   start / stop ne doivent pas être utilisé en boucle
   running permet de changer le mode de comptage du timer
   */
  int startTime = 0, stopTime = 0, startPauseTime = 0, stopPauseTime = 0, pauseTime = 0;
  boolean running = false;

  void start() {
    startTime = millis();
    running = true;
  }

  void pause() {
    startPauseTime = millis(); // début de la pause
  }

  void unpause() {
    stopPauseTime = millis();// fin de la pause
    pauseTime = pauseTime + (stopPauseTime - startPauseTime); // cumul des pauses
  }

  void stop() { //
    stopTime = millis();
    running = false;
  }

  int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime - pauseTime);
    } else {
      elapsed = (stopTime - startTime - pauseTime);
      //elapsed = (stopTime - startTime);
    }
    return elapsed;
  }
  int second() {
    return (getElapsedTime() / 1000) % 60;
  }
  int minute() {
    return (getElapsedTime() / (1000*60)) % 60;
  }
  int hour() {
    return (getElapsedTime() / (1000*60*60)) % 24;
  }

  int timer() {
    return (getElapsedTime() / 1000);
  }
  int precision() {
    return (getElapsedTime() / 100) % 10;
  }
}
