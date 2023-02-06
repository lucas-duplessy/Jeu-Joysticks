class DamageArea {
  /** classe utilisée pour définir les zones que couvrent les attaques **/
  
  String shape; //"rect" ou "circle"
  boolean isFromPlayer, isResolved;
  int areaWidth, areaHeight, damage;
  PVector position;

  DamageArea(String areaShape, boolean team, int aWidth, int aHeight, PVector pos, int dam) {
    shape = areaShape;
    position = pos.copy();
    areaWidth = aWidth;
    areaHeight = aHeight;
    isFromPlayer = team;
    isResolved = false;
    damage = dam;
  }

  boolean isInside(ObjectEntity target) {
    if (shape == "rect") {
      return(target.position.x > position.x) && (target.position.x < position.x + areaWidth) && (target.position.y > position.y) && (target.position.y < position.y + areaHeight);
    } else {
      return(sqrt((target.position.x - position.x )*(target.position.x - position.x) + (target.position.y-position.y )*( target.position.y-position.y)) < areaWidth);
    }
  }

  void applyDamage(ObjectEntity target) {
    if (isInside(target) && target.belongToPlayerTeam != isFromPlayer) {
      target.HP -= damage;
      if (target.HP < 0) {
        target.HP = 0;
      }
    }
  }
}
