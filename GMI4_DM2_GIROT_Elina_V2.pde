import processing.sound.*; //<>//

/////////////////////////////////////////////////////
//
// Asteroids
// DM2 "UED 131 - Programmation impérative" 2021-2022
// NOM         : GIROT
// Prénom      : Elina
// N° étudiant : 20210163
//
// Collaboration avec : 
//
/////////////////////////////////////////////////////



//===================================================
// les variables globales
//===================================================


//////////////////////
// Pour le vaisseau //

float shipX;
float shipY;
float shipAngle;
float shipSize;

float shipSpeedX = 3*cos(shipAngle);
float shipSpeedY = 3*sin(shipAngle);
float shipAccelereX;
float shipAccelereY;

boolean moteurON = false;

//////////////////////

//////////////////////
// Pour le missile  //

float[] posX;
float[] posY;
float[] vX;
float[] vY;
int nbBullets;
int nbBulletsMax;

//////////////////////

//////////////////////
// Pour l'astéroïde //

float[] x;
float[] y;
int[] tailleAsteroid;
float[] speedAsteX;
float[] speedAsteY;
float[] a;
int taille = 30;

int nbMax;
int nbInit;
int nbCourant;

//////////////////////
////////////////////////////
// Pour la gestion du jeu //
////////////////////////////

boolean res=false;
int  score=0;
boolean gameOver=false;
int multiple = 0;
int temporisation =0;

////////////////////////////////////
// Pour la gestion de l'affichage //
////////////////////////////////////

PFont cour1;
PFont cour2;
PFont cour3;
PFont initP;
boolean init = true;

//===================================================
// l'initialisation
//===================================================


void setup() {
  size(800, 800);
  background(0);
  displayInitScreen(); 
  initGame();
}

// -------------------- //
// Initialise le jeu    //
// -------------------- //

void initGame() {
  nbInit = 5;
  nbCourant = nbInit;
  nbMax = 100;
  tailleAsteroid = new int[nbMax];
  x = new float[nbMax];
  y = new float[nbMax];
  speedAsteX = new float[nbMax];
  speedAsteY = new float[nbMax];
  a = new float[nbMax];
  
  nbBullets = 0;
  nbBulletsMax = 100;
  posX = new float[nbBulletsMax];
  posY = new float[nbBulletsMax];
  vX = new float[nbBulletsMax];
  vY = new float[nbBulletsMax];
  
  initShip();
  initAsteroids(nbCourant);
}

//===================================================
// la boucle de rendu
//===================================================


void draw() {
  if(!init && !gameOver){
    background(0);
    displayShip();
    moveShip();
    displayAsteroids();
    moveAsteroids();
    displayBullets();
    moveBullets();
    
    displayScore();
    
    for(int i=0;i<nbCourant;i++){  //quand un astéroïde est touché par un missile
      shootAsteroid(i);
    }
    
    for(int i=0;gameOver==false && i<x.length;i++){                     // si le vaisseau est percuté par un astéroïde
      gameOver = collision(shipX,shipY,10,x[i],y[i],tailleAsteroid[i]);
      if(gameOver){
        displayGameOverScreen();
      }
    }
    
    if((score%10==0)&&(score!=multiple)&&(nbCourant!=nbMax)){
      nbCourant++;
      multiple = score;
      initAsteroid(nbCourant-1);
    }
    temporisation++;
  }
}


// -----------------------------------------//
//  Initialise le vaisseau et les missiles //
// -------------------------------------- //

void initShip() {
  shipX = width/2;
  shipY = height/2;
  shipAngle = 3*PI/2;
  shipSize = 10;
  
  for(int i=0;i<posX.length;i++){    // initialisation des missiles
    posX[i] = -100;
    posY[i] = -100;
    vX[i] = 0;
    vY[i] = 0;
  }
}

// --------------------- //
//  Deplace le vaisseau  //
// --------------------- //

void moveShip(){
  if(moteurON==true){
    shipSpeedX = shipAccelereX+3*cos(shipAngle);
    shipSpeedY = shipAccelereY+3*sin(shipAngle);
    shipX += shipSpeedX;
    shipY += shipSpeedY;
  
    // wraparound du vaisseau
    if(shipX>800+shipSize){
      shipX=0-shipSize;
    }else if(shipX<0-shipSize){
      shipX=800+shipSize;
    }else if(shipY>800 + shipSize){
      shipY = 0-shipSize;
    }else if(shipY<0-shipSize){
      shipY = 800 + shipSize;
    }
  }
}
    
  
// -------------------------- //
//  Crée un nouvel asteroïde  //
// -------------------------- //


void initAsteroids(int nbCreer){
  for(int i=0;i<nbCreer;i++){
    initAsteroid(i);
  }
}

void initAsteroid(int idx){         // astéroïdes créés sur le bord gauche de la fenêtre
  tailleAsteroid[idx] = taille;
  a[idx] = random(361);
  x[idx] = 0;
  y[idx] = random(height);
  speedAsteX[idx] = 3*cos(a[idx]);
  speedAsteY[idx] = 3*sin(a[idx]);
  taille += 30;
  if(taille>90){
    taille = 30;
  }
}




// --------------------- //
//  Deplace l'asteroïde  //
// --------------------- //

void moveAsteroids() { 
  for(int i =0;i<nbCourant;i++){
    x[i] += speedAsteX[i];
    y[i] += speedAsteY[i];
    
    if(x[i]>width+tailleAsteroid[i]/2){
      x[i] = -tailleAsteroid[i]/2;
    }else if(x[i]<-tailleAsteroid[i]/2){
      x[i] = width + tailleAsteroid[i]/2;
    }else if(y[i]>800 + tailleAsteroid[i]/2){
      y[i] = -tailleAsteroid[i]/2;
    }else if(y[i]<-tailleAsteroid[i]/2){
      y[i] = height + tailleAsteroid[i]/2;
    }
  }
}

// ------------------------ //
//  Détecte les collisions  //
// ------------------------ //
// o1X, o1Y : les coordonnées (x,y) de l'objet1
// o1D      : le diamètre de l'objet1 
// o2X, o2Y : les coordonnées (x,y) de l'objet2
// o2D      : le diamètre de l'objet2 
//


boolean collision(float o1X, float o1Y, float o1D, float o2X, float o2Y, float o2D) {
  if(dist(o1X,o1Y,o2X,o2Y)<=(o1D+o2D)/2){
    return true;
  }else{
    return false;
  }
}


// ----------------- //
//  Tire un missile  //
// ----------------- //


void shoot(){
  posX[nbBullets] = shipX;
  posY[nbBullets] = shipY;
  vX[nbBullets] = 5*cos(shipAngle);
  vY[nbBullets] = 5*sin(shipAngle);
  
  nbBullets++;
  
  // son du missile
  SoundFile shoot;
  shoot = new SoundFile(this, "fire.mp3");
  shoot.play();
}


// ------------------------------------------- //
//  Calcule la trajectoire du ou des missiles  //
// ------------------------------------------- //

void moveBullets(){
  for(int i=0;i<nbBullets;i++){
    posX[i] += vX[i];
    posY[i] += vY[i];
    if(posX[i]==width || posX[i]==0 || posY[i]==0 || posY[i]==height){
      deleteBullet(i);
    }
  }
}

// --------------------- //
//  Supprime un missile  //
// --------------------- //
// idx : l'indice du missile à supprimer
//

void deleteBullet(int idx){
  posX[idx] = posX[nbBullets-1];
  posY[idx] = posY[nbBullets-1];
  vX[idx] = vX[nbBullets-1];
  vY[idx] = vY[nbBullets-1];
  nbBullets -= 1;
}



// --------------------- //
//  touche un astéroïde  //
// --------------------- //
// idx    : l'indice de l'atéroïde touché
// vx, vy : le vecteur vitesse du missile
//


void shootAsteroid(int idx) {
  for(int j=0;j<nbBullets;j++){
    res = collision(x[idx],y[idx],tailleAsteroid[idx],posX[j],posY[j],0);
    if(res){
      SoundFile col;
      col = new SoundFile(this, "bangSmall.mp3");
      col.play();
      deleteBullet(j);
      if(tailleAsteroid[idx]==30){
        deleteAsteroid(idx);
      }else{
        nbCourant++;                                                          // on ajoute un astéroïde, vu qu'il est scindé en deux
        a[idx] = atan2(vX[j],vY[j])+random(-PI/2,PI/2);
        a[nbCourant-1] = atan2(vX[j],vY[j]) + random(-PI/2,PI/2);
        x[nbCourant-1] = x[idx];                                              // ils sont crées à l'endroit où l'astéroïde d'indice idx a été touché
        y[nbCourant-1] = y[idx];
        speedAsteX[idx] = 3*cos(a[idx]);
        speedAsteY[idx] = 3*sin(a[idx]);
        speedAsteY[nbCourant-1] = 3*cos(a[nbCourant-1]);
        speedAsteY[nbCourant-1] = 3*sin(a[nbCourant-1]);
        if(tailleAsteroid[idx]==60){
          tailleAsteroid[idx] = tailleAsteroid[nbCourant-1] = 30;
        }else{
          tailleAsteroid[idx] = tailleAsteroid[nbCourant-1] = 60;
        } 
      }
      score += 1;
    }
  }
}



// ----------------------- //
//  supprime un astéroïde  //
// ----------------------- //
// idx    : l'indice de l'atéroïde touché


void deleteAsteroid(int idx) {
  initAsteroid(idx);
}



//===================================================
// Gère les affichages
//===================================================

// ------------------- //
// Ecran d'accueil     //
// ------------------- //

void displayInitScreen() {
  fill(255);
  textAlign(CENTER,CENTER);
  cour3 = createFont("courier new",80);
  textFont(cour3);
  text("ASTEROIDS",400,150);
  initP = createFont("courier new",20);
  textFont(initP);
  text("Vous êtes confrontrés à des champs d'astéroïdes.",400,340);
  text("Le but est de survivre le plus longtemps possible",400,360);
  text("en évitant les astéroïdes et en les détruisants.",400,380);
  textAlign(LEFT,CENTER);
  text("**COMMANDES**",50,460);
  text("RIGHT = tourner sur la droite",70,490);
  text("LEFT = tourner sur la gauche",70,510);
  text("ESPACE = tirer",70,530);
  text("ENTER = téléporter le vaisseau",70,550);
  text("UP = démarrer le vaisseau",70,570);
  textAlign(CENTER,BOTTOM);
  text("*** Taper sur ENTRER pour débuter l'aventure ***",400,760);

}
  
  
// -------------- //
//  Ecran de fin  //
// -------------- //

void displayGameOverScreen(){
  fill(255);
  textAlign(CENTER,CENTER);
  cour2 = createFont("courier new",100);
  textFont(cour2);
  text("GAME OVER",400,400);
  
  textFont(initP);
  textAlign(CENTER,BOTTOM);
  text("*** Taper sur ENTRER pour rejouer ***",400,760);
  
  SoundFile col2;
  col2 = new SoundFile(this, "bangLarge.mp3");
  col2.play();
}

// --------------------- //
//  Affiche le vaisseau  //
// --------------------- //

void displayShip() {
  translate(shipX,shipY);
  rotate(shipAngle);
  if(moteurON==true){
    fill(0);
    stroke(255,0,0);
    beginShape();
    vertex(-15,0);
    vertex(-5,5);
    vertex(-5,-5);
    endShape(CLOSE);
  }
  stroke(255);
  fill(0);
  beginShape();
  vertex(10,0);
  vertex(-7,7);
  vertex(-5,0);
  vertex(-7,-7);
  endShape(CLOSE);
  resetMatrix();
}


// ------------------------ //
//  Affiche les asteroïdes  //
// ------------------------ //

void displayAsteroids() {
  for(int i=0;i<nbCourant;i++){
    noFill();
    ellipse(x[i],y[i],tailleAsteroid[i],tailleAsteroid[i]);
  }
}

// ---------------------- //
//  Affiche les missiles  //
// ---------------------- //

void displayBullets() {
  for(int i=0;i<nbBullets;i++){
    line(posX[i],posY[i],posX[i]+vX[i],posY[i]+vY[i]);
  }
}



// ------------------- //
//  Affiche le score   //
// ------------------- //


void displayScore(){
  textAlign(RIGHT,TOP);
  cour1 = createFont("courier new",20);
  fill(255);
  textFont(cour1);
  text("SCORE : "+score,750,40);
}




//===================================================
// Gère l'interaction clavier
//===================================================

// ------------------------------- //
//  Quand une touche est enfoncée  //
// ------------------------------- //
// flèche droite  = tourne sur droite
// flèche gauche  = tourne sur la gauche
// flèche haut    = accélère
// barre d'espace = tire
// entrée         = téléportation aléatoire



void keyPressed() {
  if((keyCode == RIGHT)&&(!gameOver)){
    shipAngle += radians(5);
    
  }else if((keyCode == LEFT)&&(!gameOver)){
    shipAngle -= radians(5);
    
  }else if((temporisation%5!=0)&&(key==' ')&&(!gameOver)){
    shoot();
    
  }else if((key==ENTER)&&(gameOver)){
    background(0);
    initGame();
    gameOver = false;
    score = 0;
    
  }else if((key==ENTER)&&(init)){
    init = false;
    
  }else if((key==ENTER)&&(!gameOver)){
    shipX = random(801);
    shipY = random(801);
    
  }else if((keyCode==UP)&&(!moteurON)&&(!gameOver)){
    moteurON = true;
    shipAccelereX = 0.25*cos(shipAngle);
    shipAccelereY = 0.25*sin(shipAngle);
    SoundFile file;
    file = new SoundFile(this,"thrust.mp3");
    file.play();
  }
}


// ------------------------------- //
//  Quand une touche est relâchée  //
// ------------------------------- //
void keyReleased(){
  if((keyCode==UP)&&(moteurON)){
    shipX -= shipAccelereX;
    shipY -= shipAccelereY;
    moteurON = false;
  }    
}
