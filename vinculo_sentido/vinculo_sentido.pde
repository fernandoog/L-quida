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
 
 Teclas de control de camara (MAYUSCULAS):Q W E R T A S D F
 Teclas de estados:1 2 3
 Tecla de grabacion: Z
 
 
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

/// inicializando el arreglo de sonidos
AudioPlayer[][] sonidosLiquidos;
//int cantSonidos = col*row;

//estos son los sonidos de efectos como la caminada

int cantFx = 4;
AudioSample[] fx;

// arreglo de strings de los nombres de los archivos de audio
String[][] tracks =
  {
  {
    "A1.mp3", "A2.mp3", "A3.mp3", "A4.mp3"
  }
  ,
  {
    "B1.mp3", "B2.mp3", "B3.mp3", "B4.mp3"
  }
  ,
  {
    "C1.mp3", "C2.mp3", "C3.mp3", "C4.mp3"
  }
  ,
  {
    "D1.mp3", "D2.mp3", "D3.mp3", "D4.mp3"
  }
};

String[] tracksFx = {
  "F1.mp3", "F2.mp3", "F3.mp3", "F4.mp3"
};

// arreglo de botones liquida
Hotpoint[][] botLiq;

int row = 4;
int col = 4;



////contrones de camara

float rotX = radians(180);
float rotY = radians(0);




// ALTURA DE LA RETICULA
// lo manejamos con las letras 'U' e 'I'

// elevacion inicial
int elevacion = -300;

// rango de aumento para ajustar la elevacion
int aumentoElev = 100;


//dimensiones del boton
int tamano = 500;

//distancia de la camara al inicio de la reticula

// lo manejamos con las letras  'G' y 'H'
int distRet = 1200;

// pasos de juste de la reticula a liquida
int distRetAumento = 20;


// este es el control del zoom y se hace con "S" y "A"
float s = 1;

//resolucion de la nube de puntos "M" Y "N"
int pasos = 10;

// Se controla la profundidad de rastreo con "L" y "K"
int profundidad = 3000;

// Grabación

AudioInput in;
AudioRecorder recorder;
recorder = minim.createRecorder(in, "Init.wav");


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
  kinect.setMirror(false);

  //se autoriza la vision de profundidad
  kinect.enableDepth();

  // inicializand los minim
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 44100);
  textFont(createFont("Arial", 30));

  /// inicializar los sonidos del arreglo

  sonidosLiquidos = new AudioPlayer [row][col];

  for (int i = 0; i < row; i++)
  {
    for (int j = 0; j < col; j++)
    {
      sonidosLiquidos[i][j] = minim.loadFile(tracks[i][j], 512);
    }
  }

  // se inicilizan los fx

  fx = new AudioSample[cantFx];
  for (int i = 0; i < cantFx; i++)
  {
    fx[i] = minim.loadSample(tracksFx[i], 512);
  }


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
  background(0);


  translate(width/2, height/2, -1000);
  rotateX(rotX);


  translate(0, 0, 1400);
  rotateY(rotY);

  translate(0, 0, s*-1000);
  scale(s);

  stroke(255);

  PVector[] depthPoints = kinect.depthMapRealWorld();

  switch(estado) {

    // Grabar
  case 1:

    background(0);
    stroke(255);

    if ( recorder.isRecording() )
    {
      text("Currently recording...", 5, 15);
    } else
    {
      text("Not recording.", 5, 15);
    }

    break;

    // Calibar
  case 2:

    for (int i = 0; i < depthPoints.length; i+=pasos) {
      PVector currentPoint = depthPoints[i];
      if (currentPoint.z < profundidad)
        point(currentPoint.x, currentPoint.y, currentPoint.z);
      //vertex(currentPoint.x, currentPoint.y, currentPoint.z);
    }

    for (int i = 0; i < row; i++)
    {
      for (int j = 0; j < col; j++)
      {
        sonidosLiquidos[i][j].mute();
      }
    }

    break;

    // Play
  case 3:


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
          //sonidosLiquidos[k][l].loop();
          if (sonidosLiquidos[k][l].isMuted() )
          {
            sonidosLiquidos[k][l].unmute();
          } else
          {
            // simply call loop again to resume playing from where it was paused
            sonidosLiquidos[k][l].mute();
          }


          fx[0].trigger();
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


    break;


    // cualquier otra entrada solo sigue dibujando la nube de puntos
  default:

    for (int i = 0; i < depthPoints.length; i+=pasos) {
      PVector currentPoint = depthPoints[i];
      if (currentPoint.z < profundidad)
        point(currentPoint.x, currentPoint.y, currentPoint.z);
      //vertex(currentPoint.x, currentPoint.y, currentPoint.z);
    }


    break;

    //termina el switch
  }

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
  if (key == 'T') {
    pasos++;
    println("resolucion + " + pasos);
  }

  if (key == 'G') {
    if (pasos<=3) {
      pasos = 3;
      println("resolucion - " + pasos);
    }

    pasos--;
  }

  //PROFUNDIDAD DEL RASTREO DE PUNTOS

  if (key == 'R') {
    profundidad =  profundidad+= 100;
    println("profundidad + " + profundidad);
  }
  if (key == 'F') {
    profundidad =  profundidad-= 100;
    println("profundidad - " + profundidad);
  }

  // controles de ubicacion de los botones


  // estos son para subir y bajar la reticula
  if (key == 'E')
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
  if (key == 'D')
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

  if (key == 'W')
  {
    distRet += 50;
    for (int k = 0; k < col; k++)
    {
      for (int l = 0; l < row; l++)
      {
        botLiq[k][l].center.z += distRetAumento;
        println("alejar " + botLiq[k][l].center.z);
      }
    }
  }
  if (key == 'S')
  {
    distRet -= 50;
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
  if (key == 'A') {
    s = s+ 0.01;
    println("zoom + " + s);
  }

  if (key == 'Q') {

    s = s - 0.01;
    println("zoom - " + s);
  }

  //controles de los estados
  if (key == '1') {
    estado = 1;
    println("Grabar + " + estado);
  }

  if (key == '2') {
    estado = 2;
    println("Calibrar + " + estado);
  }

  if (key == '3') {
    estado = 3;
    println("Play + " + estado);
  }

  if (key == 'Z') {
    noLoop();
  }
  if (key == 'X') {
    loop();
  }


  // Grabación
  // A
  if ( key == '7')
  {
    recorder = minim.createRecorder(in, "A1.wav");
    recorder.beginRecord();
  }
  if ( key == '8')
  {
    recorder = minim.createRecorder(in, "A2.wav");
    recorder.beginRecord();
  }
  if ( key == '9')
  {
    recorder = minim.createRecorder(in, "A3.wav");
    recorder.beginRecord();
  }

  if ( key == '0')
  {
    recorder = minim.createRecorder(in, "A4.wav");
    recorder.beginRecord();
  }

  // B
  if ( key == 'Y')
  {
    recorder = minim.createRecorder(in, "B1.wav");
    recorder.beginRecord();
  }
  if ( key == 'U')
  {
    recorder = minim.createRecorder(in, "B2.wav");
    recorder.beginRecord();
  }
  if ( key == 'I')
  {
    recorder = minim.createRecorder(in, "B3.wav");
    recorder.beginRecord();
  }

  if ( key == 'O')
  {
    recorder = minim.createRecorder(in, "B4.wav");
    recorder.beginRecord();
  }

  //C
  if ( key == 'H')
  {
    recorder = minim.createRecorder(in, "C1.wav");
    recorder.beginRecord();
  }
  if ( key == 'J')
  {
    recorder = minim.createRecorder(in, "C2.wav");
    recorder.beginRecord();
  }
  if ( key == 'K')
  {
    recorder = minim.createRecorder(in, "C3.wav");
    recorder.beginRecord();
  }
  if ( key == 'L')
  {
    recorder = minim.createRecorder(in, "C4.wav");
    recorder.beginRecord();
  }

  //D
  if ( key == 'N')
  {
    recorder = minim.createRecorder(in, "D1.wav");
    recorder.beginRecord();
  }
  if ( key == 'M')
  {
    recorder = minim.createRecorder(in, "D2.wav");
    recorder.beginRecord();
  }
  if ( key == ';')
  {
    recorder = minim.createRecorder(in, "D3.wav");
    recorder.beginRecord();
  }
  if ( key == ':')
  {
    recorder = minim.createRecorder(in, "D4.wav");
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
  if ( key == 'Y')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B1");
  }
  if ( key == 'U')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B2");
  }
  if ( key == 'I')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B3");
  }

  if ( key == 'O')
  {
    recorder.endRecord();
    recorder.save();
    println("Save B4");
  }

  //C
  if ( key == 'H')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C1");
  }
  if ( key == 'J')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C2");
  }
  if ( key == 'K')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C3");
  }
  if ( key == 'L')
  {
    recorder.endRecord();
    recorder.save();
    println("Save C4");
  }

  //D
  if ( key == 'N')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D1");
  }
  if ( key == 'M')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D2");
  }
  if ( key == ';')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D3");
  }
  if ( key == ':')
  {
    recorder.endRecord();
    recorder.save();
    println("Save D4");
  }
}
