/*
 ///////////////////////////////////////////////////////
 Programa: Líquida V. 2.K
 Autores: Grupo de investigacion FuzzyGab.4 de la UCLM, España
 Programador: Joaku De Sotavento
 Musica: Julio Sanz-Vázquez
 Orquestación: Sylvia Molina y Joaku De Sotavento
 Curaduria: Javier Osona
 Idea: Sylvia Molina, Javier Osona, Julio Sanz-Vázquez
 Implementación Grabación: Fernando Ortega Gorrita
 Idea Vinculo Sentido: Catalina Bargas
 
 
 //////////////////////////////////////////////////////
 Instrucciones de instalacion:
 
 Requerimientos para instalar Líquida V.2.2.K
 
 Processing v. 2.2.1
 https://www.processing.org/download/
 
 SimpleOpenNI
 https://code.google.com/archive/p/simple-openni/
 
 
 En windows:
 
 Kinect SDK
 https://www.microsoft.com/en-us/download/details.aspx?id=40278
 
 Kinect development toolkits
 https://www.microsoft.com/en-us/download/details.aspx?id=36998
 
 En MAC: no hace falta instalar ningun driver.
 Si no funciona ir a este sitio y bajar instrucciones:
 https://github.com/processing/processing/issues/2201
 
 https://github.com/kronihias/head-pose-estimation
 
 ///////////////////////////////////////////////////
 Instrucciones Líquida V. Kinect.
 
 Teclas de control de camara (MAYUSCULAS):
 Q W E R T
 A S D F G
 
 Tecla de recarga: 1
 
 Teclas de grabacion:
 7 8 9 0
 U I O P
 J K L Ñ
 M , . -
 
 Teclas delay:
 Z X
 
 Teclas tamaño:
 C V
 
 
 NT. La profundidad del rastreo ayuda
 a que el programa no vea las cosas
 de una cierta distancia para allá.
 
 NT. Si la computadora no es muy
 potente bajar la resolucion
 
 
 */


// bibliotecas
import ddf.minim.*;
import java.util.Scanner;
import java.util.InputMismatchException;
import processing.opengl.*;
import SimpleOpenNI.*;

// variable de la maquina de estado
int estado = 1;

// biblioteca SimplepenNI
SimpleOpenNI kinect;

//clases de la biblioteca minim
Minim minim;
//AudioOutput out;

// inicializando el arreglo de sonidos
AudioSample[][] sonidosLiquidos;
//int cantSonidos = col*row;

//estos son los sonidos de efectos como la caminada

int cantFx = 4;
AudioPlayer[] fx;

// arreglo de strings de los nombres de los archivos de audio
String[][] tracks =
  {
  {
    "A4.wav", "B4.wav", "C4.wav", "D4.wav"
  }
  ,
  {
    "A3.wav", "B3.wav", "C3.wav", "D3.wav"
  }
  ,
  {
    "A2.wav", "B2.wav", "C2.wav", "D2.wav"
  }
  ,
  {
    "A1.wav", "B1.wav", "C1.wav", "D1.wav"
  }
};

String[] tracksFx = {
  "F1.wav", "F2.wav", "F3.wav", "F4.wav"
};

// arreglo de botones liquida
Hotpoint[][] botLiq;

int row = 4;
int col = 4;



////contrones de camara

float rotX = radians(165);
float rotY = radians(0);

// elevacion inicial
int elevacion =100;

// rango de aumento para ajustar la elevacion
int aumentoElev = 10;


//dimensiones del boton
int tamano = 550;

//distancia de la camara al inicio de la reticula
int distRet = 1000;

// pasos de juste de la reticula a liquida
int distRetAumento = 10;

// Zoom
float s = 0.90;

int pasos = 7;

int profundidad = 8000;

// Delay Z y X
int delay = 50;

AudioInput in;
AudioRecorder recorder;


void setup() {
  // se inicializa el back gorund y la kinect
  size(1024, 768, P3D);

  kinect = new SimpleOpenNI(this);
  if (kinect.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!");
    exit();
    return;
  }

  //espejea la imagen
  kinect.setMirror(true);

  //se autoriza la vision de profundidad
  kinect.enableDepth();

  // inicializand los minim
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  textFont(createFont("Arial", 30));
  recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"Test.wav");

  // inicializar los sonidos del arreglo

  sonidosLiquidos = new AudioSample [row][col];

  for (int i = 0; i < row; i++)
  {
    for (int j = 0; j < col; j++)
    {
      sonidosLiquidos[i][j] = minim.loadSample(tracks[i][j], 512);
      println("cargando sonidos " + tracks[i][j]);
    }
  }

  //sonidosLiquidos[0][0].play();
  //delay(sonidosLiquidos[0][0].length());
  // se inicilizan los fx

  fx = new AudioPlayer[cantFx];
  for (int i = 0; i < cantFx; i++)
  {
    fx[i] = minim.loadFile(tracksFx[i], 512);
    println("Cargando tracks Fx " + tracksFx[i]);
  }

  //fx[0].trigger();
  //delay(sonidosLiquidos[0][0].length());

  // se inicializan los botones

  botLiq = new Hotpoint[col][row];

  for (int k = 0; k < row; k++)
  {
    for (int l = 0; l < col; l++)
    {
      botLiq[k][l] = new Hotpoint((tamano*(col/2)-tamano/2)-(k*tamano), elevacion, distRet+l*tamano, tamano);
    }
  }
}

void draw() {
  kinect.update();
  PVector[] depthPoints = kinect.depthMapRealWorld();


  background(0);


  translate(width/2, height/2, -1000);
  rotateX(rotX);


  translate(0, 0, 1400);
  rotateY(rotY);

  translate(0, 0, s*-1000);
  scale(s);

  stroke(255);



  // beginShape(POINTS);

  // esta es la parte que dibuja todo
  // la nube de puntos y los botones hotPoint
  for (int i = 0; i < depthPoints.length; i+=pasos)
  {
    PVector currentPoint = depthPoints[i];
    // esta parte dibuja los puntos de la nube de puntos
    if (currentPoint.z < profundidad)
    {

      point(currentPoint.x, currentPoint.y, currentPoint.z);
      //vertex(currentPoint.x, currentPoint.y, currentPoint.z);
      // almacena el punto actual del arreglo de la nube de puntos


      // dibuja los hotPoints en columnas y filas
      for (int k = 0; k < row; k++)
      {
        for (int l = 0; l < col; l++)
        {
          botLiq[k][l].check(currentPoint);
        }
      }
    }
  }
  // endShape();

  // esta parte revisa si el boton esta siendo activado, dispara el sonido
  for (int k = 0; k < row; k++)
  {
    for (int l = 0; l < col; l++)
    {
      // en esta parte se activan los sonidos por su correspondiente posisicion
      // aqui se puede anexar un solo sonido que pueda corresponder a una accion constante como caminar
      if (botLiq[k][l].isHit())
      {
        delay(delay);
        sonidosLiquidos[k][l].trigger();
      }
    }
  }

  // aqui se borran los puntos dibujados y se limpia la informacion del current point
  for (int k = 0; k < row; k++)
  {
    for (int l = 0; l < col; l++)
    {
      botLiq[k][l].draw();
      botLiq[k][l].clear();
    }
  }
  //termina el switch
  // draw the kinect cam
  kinect.drawCamFrustum();
}


// detiene las funciones de sonido para que la tarjeta de audio no se quede ocupada
void stop() {

  minim.stop();
  super.stop();
}


void keyPressed() {

  //controles de la nube de puntos

  // resolucion
  if (key == 't') {
    pasos++;
    println("resolucion + " + pasos);
  }

  if (key == 'g') {
    if (pasos<=1) {
      pasos = 1;
      println("resolucion - " + pasos);
    }

    pasos--;
  }

  // Profundidad del rastreo de puntos

  if (key == 'r') {
    profundidad =  profundidad+= 100;
    println("prof + " + profundidad);
  }
  if (key == 'f') {
    profundidad =  profundidad-= 100;
    println("prof - " + profundidad);
  }

  // controles de ubicacion de los botones


  // estos son para subir y bajar la reticula
  if (key == 'e')
  {
    for (int k = 0; k < col; k++)
    {
      for (int l = 0; l < row; l++)
      {
        botLiq[k][l].center.y += aumentoElev;
        println("subir " + botLiq[k][l].center.y);
      }
    }
  }
  if (key == 'd')
  {
    for (int k = 0; k < col; k++)
    {
      for (int l = 0; l < row; l++)
      {
        botLiq[k][l].center.y -= aumentoElev;
        println("bajar " + botLiq[k][l].center.y);
      }
    }
  }

  // estos son para alejarla y acercarla a liquida

  if (key == 'w')
  {
    distRet += 100;
    for (int k = 0; k < col; k++)
    {
      for (int l = 0; l < row; l++)
      {
        botLiq[k][l].center.z += distRetAumento;
        println("alejar " + botLiq[k][l].center.z);
      }
    }
  }
  if (key == 's')
  {
    distRet -= 100;
    for (int k = 0; k < col; k++)
    {
      for (int l = 0; l < row; l++)
      {
        botLiq[k][l].center.z -= distRetAumento;
        println("acercar " + botLiq[k][l].center.z);
      }
    }
  }

  //controles de camara

  // zoom
  if (key == 'q') {
    s = s+ 0.01;
    println("zoom + " + s);
  }

  if (key == 'a') {

    s = s - 0.01;
    println("zoom - " + s);
  }

  if (key == '1') {
    println("Recargando + " + estado);
    reload();
  }

  // Loop

  if (key == 'z') {
    delay = delay - 10;
    println("Delay + " + delay);
  }
  if (key == 'x') {
    delay = delay + 10;
    println("Delay + " + delay);
  }

  // Loop

  if (key == 'c') {
    tamano = tamano - 10;
    println("Tamaño + " + tamano);

    botLiq = new Hotpoint[col][row];

    for (int k = 0; k < row; k++)
    {
      for (int l = 0; l < col; l++)
      {
        botLiq[k][l] = new Hotpoint((tamano*(col/2)-tamano/2)-(k*tamano), elevacion, distRet+l*tamano, tamano);
      }
    }
  }
  if (key == 'v') {
    tamano = tamano + 10;
    println("Tamaño + " + tamano);
   
    botLiq = new Hotpoint[col][row];

    for (int k = 0; k < row; k++)
    {
      for (int l = 0; l < col; l++)
      {
        botLiq[k][l] = new Hotpoint((tamano*(col/2)-tamano/2)-(k*tamano), elevacion, distRet+l*tamano, tamano);
      }
    }
  }



  // Grabación
  // A
  if ( key == '7')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"A1.wav");
    recorder.beginRecord();
  }
  if ( key == '8')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"A2.wav");
    recorder.beginRecord();
  }
  if ( key == '9')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"A3.wav");
    recorder.beginRecord();
  }

  if ( key == '0')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"A4.wav");
    recorder.beginRecord();
  }

  // B
  if ( key == 'u')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"B1.wav");
    recorder.beginRecord();
  }
  if ( key == 'i')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"B2.wav");
    recorder.beginRecord();
  }
  if ( key == 'o')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"B3.wav");
    recorder.beginRecord();
  }

  if ( key == 'p')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"B4.wav");
    recorder.beginRecord();
  }

  //C
  if ( key == 'j')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"C1.wav");
    recorder.beginRecord();
  }
  if ( key == 'k')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"C2.wav");
    recorder.beginRecord();
  }
  if ( key == 'l')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"C3.wav");
    recorder.beginRecord();
  }
  if ( key == 'ñ')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"C4.wav");
    recorder.beginRecord();
  }

  //D
  if ( key == 'm')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"D1.wav");
    recorder.beginRecord();
  }
  if ( key == ',')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"D2.wav");
    recorder.beginRecord();
  }
  if ( key == '.')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"D3.wav");
    recorder.beginRecord();
  }
  if ( key == '-')
  {
    recorder = minim.createRecorder(in, "data"+ System.getProperty("file.separator")+"D4.wav");
    recorder.beginRecord();
  }
}

void keyReleased() {

  // Grabación
  // A
  if ( key == '7')
  {
    recorder.endRecord();
    recorder.save();
    println("Save A1");
  }
  if ( key == '8')
  {
    recorder.endRecord();
    recorder.save();
    println("Save A2");
  }
  if ( key == '9')
  {
    recorder.endRecord();
    recorder.save();
    println("Save A3");
  }

  if ( key == '0')
  {
    recorder.endRecord();
    recorder.save();
    println("Save A4");
  }

  // B
  if ( key == 'u')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B1");
  }
  if ( key == 'i')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B2");
  }
  if ( key == 'o')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B3");
  }

  if ( key == 'p')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B4");
  }

  //C
  if ( key == 'j')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C1");
  }
  if ( key == 'k')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C2");
  }
  if ( key == 'l')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C3");
  }
  if ( key == 'ñ')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C4");
  }

  //D
  if ( key == 'm')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D1");
  }
  if ( key == ',')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D2");
  }
  if ( key == '.')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D3");
  }
  if ( key == '-')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D4");
  }
}

// control del paneo y tilt de la camara
void mouseDragged() {


  if ((mouseY-pmouseY) <= 0) {
    rotY-=0.001;
    rotX-=0.001;
  } else {
    rotY+=0.001;
    rotX+=0.001;
  }

  if ((mouseX-pmouseX) >= 0) {
    rotY-=0.001;
    rotX-=0.001;
  } else {
    rotY+=0.001;
    rotX+=0.001;
  }
   println("Vista " + rotX + " " + rotY);
}

void reload() {
  sonidosLiquidos = new AudioSample [row][col];

  for (int i = 0; i < row; i++)
  {
    for (int j = 0; j < col; j++)
    {
      sonidosLiquidos[i][j] = minim.loadSample(tracks[i][j], 512);
      println("cargando sonidos " + tracks[i][j]);
    }
  }

  fx = new AudioPlayer[cantFx];
  for (int i = 0; i < cantFx; i++)
  {
    fx[i] = minim.loadFile(tracksFx[i], 512);
    println("Cargando tracks Fx " + tracksFx[i]);
  }
}
