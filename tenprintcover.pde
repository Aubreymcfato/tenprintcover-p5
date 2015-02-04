import http.requests.*;
import controlP5.*;

ControlP5 cp5;

String api  = "http://api.flickr.com/services/rest/?method=flickr.photos.search";
String flickrKey = "";

String photoUrl = "";

PImage img;

int screenWidth = 800;
int screenHeight = 400;

PFont titleFont;
PFont authorFont;
boolean refresh = true;
boolean autosave = false;

int minTitle = 2;
int maxTitle = 60;

int coverWidth = 200;
int coverHeight = 250;
int currentBook = 0;
int margin = 5;
int titleHeight = 55;
int authorHeight = 25;
int artworkStartX = 400;
int artworkStartY = 75;
int fontSize = 14;

color coverBaseColor = color(204, 153, 0);
color coverShapeColor = color(50);
color baseColor = coverBaseColor;
color shapeColor = coverShapeColor;

int baseVariation = 100;
int baseSaturation = 90;
int baseBrightness = 80;

int gridCount = 7;
int shapeThickness = 5;

String c64Letters = " qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlL:zZxXcCvVbBnNmM1234567890.";

String title = "";
String author = "";
String filename = "";
String[] bookList;


String[][] books = {
  {"Dante Alighieri","La Divina Commedia di Dante: Inferno"},
  {"Dante Alighieri","La Divina Commedia di Dante: Purgatorio"},
  {"Dante Alighieri","La Divina Commedia di Dante: Paradiso"},
  {"Dante Alighieri","La Divina Commedia di Dante"},
  {"Ariosto, Lodovico","Orlando Furioso"},
  {"Cantù, Cesare","Il Sacro Macello Di Valtellina"},
  {"Aragona, Tullia d'","Rime di Tullia d'Aragona, cortigiana del secolo XVI"},
  {"Socci, Ettore","Da Firenze a Digione: Impressioni di un reduce Garibaldino"},
  {"Garibaldi, Giuseppe","Clelia: Il governo dei preti - Romanzo storico politico"},
  {"Capuana, Luigi","Cardello"},
  {"Capuana, Luigi","Il Benefattore"},
  {"Schiaparelli, Giovanni Virginio","La Vita Sul Pianeta Marte"},
  {"De Gubernatis, Angelo","Alessandro Manzoni, Studio Biografico"},
  {"Arrighi, Cletto","Nanà a Milano"},
  {"Bazzero, Ambrogio","Ugo: Scene del secolo X"},
  {"Fontana, Ferdinando","Poesie e novelle in versi"},
  {"Anonimo","M'appari - Martha"},
  {"Rovani, Giuseppe","Manfredo Palavicino, o, I Francesi e gli Sforzeschi"},
  {"Autori vari","Sono Un Poeta"}
};


void setup() {
  size(screenWidth, screenHeight);
  background(0);
  noStroke();
  cp5 = new ControlP5(this);
  titleFont = loadFont("AvenirNext-Bold-" + fontSize + ".vlw");
  authorFont = loadFont("AvenirNext-Regular-" + fontSize + ".vlw");
  cp5.addSlider("gridCount")
    .setPosition(10,10)
    .setRange(1,20)
    .setSize(300,10)
    .setId(1)
    ;
  cp5.addSlider("shapeThickness")
    .setPosition(10,30)
    .setRange(1,15)
    .setSize(300,10)
    .setId(2)
    ;
  cp5.addSlider("baseVariation")
    .setPosition(10,50)
    .setRange(0,100)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addSlider("baseSaturation")
    .setPosition(10,70)
    .setRange(0,100)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addSlider("baseBrightness")
    .setPosition(10,90)
    .setRange(0,100)
    .setSize(300,10)
    .setId(3)
    ;
  String config[] = loadStrings("config.txt");
  flickrKey = config[0];
  loadData();
}

void draw() {
  if (refresh) {
    refresh = false;
    getCurrentBook();
    processColors();
    drawBackground();
    drawArtwork();
    drawText();
    if (autosave) {
      saveCurrent();
      currentBook++;
      // println("bookList:" + bookList.length);
      if (currentBook < bookList.length) {
        refresh = true;
      } else {
        autosave = false;
      }
    }
  }
}

void getCurrentBook() {
  JSONObject book = JSONObject.parse(bookList[currentBook]);
  title = book.getString("title");
  String subtitle = "";
  try {
    subtitle = book.getString("subtitle");
  }
  catch (Exception e) {
    println("book has no subtitle");
  }
  if (!subtitle.equals("")) {
    title += ": " + subtitle;
  }
  author = book.getString("authors");
  filename = book.getString("identifier") + ".png";
}

void drawBackground() {
  background(50);
  fill(255);
  rect(artworkStartX, 0, coverWidth, coverHeight);
}

void drawText() {
  //…
  fill(50);
  textFont(titleFont, fontSize);
  textLeading(14);
  text(title, artworkStartX+margin, margin+margin, coverWidth - (2 * margin), titleHeight);
  // fill(255);
  textFont(authorFont, fontSize);
  text(author, artworkStartX+margin, titleHeight, coverWidth - (2 * margin), authorHeight);
}

String c64Convert() {
  // returns a string with all the c64-letter available in the title or a random set if none
  String result = "";
  int i, len = title.length();
  char letter;
  for (i=0; i<len; i++) {
    letter = title.charAt(i);
    // println("letter:" + letter + " num:" + int(letter));
    if (c64Letters.indexOf(letter) == -1) {
      int anIndex = int(letter)%c64Letters.length();//floor(random(c64Letters.length()));
      letter = c64Letters.charAt(anIndex);
    }
    // println("letter:" + letter);
    result = result + letter;
  }
  // println("result:" + result);
  return result;
}

void drawArtwork() {
  breakGrid();
  int i,j,gridSize=coverWidth/gridCount;
  int item = 0;
  fill(baseColor);
  rect(artworkStartX, 0, coverWidth, margin);
  rect(artworkStartX, artworkStartY, coverWidth, coverWidth);
  String c64Title = c64Convert();
  // println("c64Title.length(): "+c64Title.length());
  for (i=0; i<gridCount; i++) {
    for (j=0; j<gridCount; j++) {
      char character = c64Title.charAt(item%c64Title.length());
      drawShape (character, artworkStartX+(j*gridSize), artworkStartY+(i*gridSize), gridSize);
      item++;
    }
  }
}

void breakGrid() {
  int len = title.length();
  // println("title length:"+len);
  if (len < minTitle) len = minTitle;
  if (len > maxTitle) len = maxTitle;
  gridCount = int(map(len, minTitle, maxTitle, 2, 11));
}

void processColors() {
  int counts = title.length() + author.length();
  int colorSeed = int(map(counts, 2, 80, 30, 260));
  colorMode(HSB, 360, 100, 100);
  // int rndSeed = colorSeed + int(random(baseVariation));
  // int darkOnLight = (floor(random(2))==0) ? 1 : -1;
  shapeColor = color(colorSeed, baseSaturation, baseBrightness-(counts%20));// 55+(darkOnLight*25));
  baseColor = color((colorSeed+180)%360, baseSaturation, baseBrightness);// 55-(darkOnLight*25));
  // println("inverted:"+(counts%10));
  // if length of title+author is multiple of 10 make it inverted
  if (counts%10==0) {
    color tmpColor = baseColor;
    baseColor = shapeColor;
    shapeColor = tmpColor;
  }
  println("baseColor:"+baseColor);
  println("shapeColor:"+shapeColor);
  colorMode(RGB, 255);
}

void processColorsFlickr() {
  photoUrl = getFlickrData(author.replace(' ','+') + "+" + title.replace(' ','+'));
  if (photoUrl != "") {
    try {
      PostRequest post = new PostRequest("http://labs.gaidi.ca/brandr/api.php");
      post.addData("image_url", photoUrl);
      post.send();
      String responseContent = post.getContent();
      println("responseContent: " + responseContent);
      if (responseContent.length()>0) {
        JSONObject colorsResponse = JSONObject.parse(responseContent);
        JSONArray colorsAccents = colorsResponse.getJSONArray("accents");
        println("size:"+colorsAccents.size());
        if (colorsAccents.size()>0) {
          try {
            JSONObject firstColorO = colorsAccents.getJSONObject(0);
            int firstColor = unhex("ff"+firstColorO.getString("color"));
            baseColor = color(firstColor);
          }
          catch (Exception ee) {
            JSONObject firstColorO = colorsAccents.getJSONObject(0);
            int firstColor = unhex("ff"+firstColorO.getInt("color"));
            baseColor = color(firstColor);
          }
        } else {
          baseColor = coverBaseColor;
        }
        println("baseColor: "+baseColor);
        if (colorsAccents.size()>1) {
          try {
            JSONObject secondColorO = colorsAccents.getJSONObject(1);
            int secondColor = unhex("ff"+secondColorO.getString("color"));
            shapeColor = color(secondColor);
          }
          catch (Exception ee) {
            JSONObject secondColorO = colorsAccents.getJSONObject(1);
            int secondColor = unhex("ff"+secondColorO.getInt("color"));
            shapeColor = color(secondColor);
          }
        } else {
          shapeColor = coverShapeColor;
        }
        println("shapeColor: "+shapeColor);
      } else {
        baseColor = coverBaseColor;
        shapeColor = coverShapeColor;
      }
    }
    catch (Exception e) {
      println ("There was an error loading the colors.");
    }
  } else {
    baseColor = coverBaseColor;
    shapeColor = coverShapeColor;
  }
}

void loadData() {
  bookList = loadStrings("covers.json2");
  println("bookList:" + bookList.length);
}

void drawShape(char k, int x, int y, int s) {
  ellipseMode(CORNER);
  fill(shapeColor);
  switch (k) {
    case 'q':
    case 'Q':
      ellipse(x, y, s, s);
      break;
    case 'w':
    case 'W':
      ellipse(x, y, s, s);
      s = s-(shapeThickness*2);
      fill(baseColor);
      ellipse(x+shapeThickness, y+shapeThickness, s, s);
      break;
    case 'e':
    case 'E':
      rect(x, y+shapeThickness, s, shapeThickness);
      break;
    case 'r':
    case 'R':
      rect(x, y+s-(shapeThickness*2), s, shapeThickness);
      break;
    case 't':
    case 'T':
      rect(x+shapeThickness, y, shapeThickness, s);
      break;
    case 'y':
    case 'Y':
      rect(x+s-(shapeThickness*2), y, shapeThickness, s);
      break;
    case 'u':
    case 'U':
      arc(x, y, s*2, s*2, PI, PI+HALF_PI);
      fill(baseColor);
      arc(x+shapeThickness, y+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, PI, PI+HALF_PI);
      break;
    case 'i':
    case 'I':
      arc(x-s, y, s*2, s*2, PI+HALF_PI, TWO_PI);
      fill(baseColor);
      arc(x-s+shapeThickness, y+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, PI+HALF_PI, TWO_PI);
      break;
    case 'o':
    case 'O':
      rect(x, y, s, shapeThickness);
      rect(x, y, shapeThickness, s);
      break;
    case 'p':
    case 'P':
      rect(x, y, s, shapeThickness);
      rect(x+s-shapeThickness, y, shapeThickness, s);
      break;
    case 'a':
    case 'A':
      triangle(x, y+s, x+(s/2), y, x+s, y+s);
      break;
    case 's':
    case 'S':
      triangle(x, y, x+(s/2), y+s, x+s, y);
      break;
    case 'd':
    case 'D':
      rect(x, y+(shapeThickness*2), s, shapeThickness);
      break;
    case 'f':
    case 'F':
      rect(x, y+s-(shapeThickness*3), s, shapeThickness);
      break;
    case 'g':
    case 'G':
      rect(x+(shapeThickness*2), y, shapeThickness, s);
      break;
    case 'h':
    case 'H':
      rect(x+s-(shapeThickness*3), y, shapeThickness, s);
      break;
    case 'j':
    case 'J':
      arc(x, y-s, s*2, s*2, HALF_PI, PI);
      fill(baseColor);
      arc(x+shapeThickness, y-s+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, HALF_PI, PI);
      break;
    case 'k':
    case 'K':
      arc(x-s, y-s, s*2, s*2, 0, HALF_PI);
      fill(baseColor);
      arc(x-s+shapeThickness, y-s+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, 0, HALF_PI);
      break;
    case 'l':
    case 'L':
      rect(x, y, shapeThickness, s);
      rect(x, y+s-shapeThickness, s, shapeThickness);
      break;
    case ':':
      rect(x+s-shapeThickness, y, shapeThickness, s);
      rect(x, y+s-shapeThickness, s, shapeThickness);
      break;
    case 'z':
    case 'Z':
      triangle(x, y+(s/2), x+(s/2), y, x+s, y+(s/2));
      triangle(x, y+(s/2), x+(s/2), y+s, x+s, y+(s/2));
      break;
    case 'x':
    case 'X':
      ellipseMode(CENTER);
      ellipse(x+(s/2), y+(s/3), shapeThickness*2, shapeThickness*2);
      ellipse(x+(s/3), y+s-(s/3), shapeThickness*2, shapeThickness*2);
      ellipse(x+s-(s/3), y+s-(s/3), shapeThickness*2, shapeThickness*2);
      ellipseMode(CORNER);
      break;
    case 'c':
    case 'C':
      rect(x, y+(shapeThickness*3), s, shapeThickness);
      break;
    case 'v':
    case 'V':
      rect(x, y, s, s);
      fill(baseColor);
      triangle(x+shapeThickness, y, x+(s/2), y+(s/2)-shapeThickness, x+s-shapeThickness, y);
      triangle(x, y+shapeThickness, x+(s/2)-shapeThickness, y+(s/2), x, y+s-shapeThickness);
      triangle(x+shapeThickness, y+s, x+(s/2), y+(s/2)+shapeThickness, x+s-shapeThickness, y+s);
      triangle(x+s, y+shapeThickness, x+s, y+s-shapeThickness, x+(s/2)+shapeThickness, y+(s/2));
      break;
    case 'b':
    case 'B':
      rect(x+(shapeThickness*3), y, shapeThickness, s);
      break;
    case 'n':
    case 'N':
      rect(x, y, s, s);
      fill(baseColor);
      triangle(x, y, x+s-shapeThickness, y, x, y+s-shapeThickness);
      triangle(x+shapeThickness, y+s, x+s, y+s, x+s, y+shapeThickness);
      break;
    case 'm':
    case 'M':
      rect(x, y, s, s);
      fill(baseColor);
      triangle(x+shapeThickness, y, x+s, y, x+s, y+s-shapeThickness);
      triangle(x, y+shapeThickness, x, y+s, x+s-shapeThickness, y+s);
      break;
    case '7':
      rect(x, y, s, shapeThickness*2);
      break;
    case '8':
      rect(x, y, s, shapeThickness*3);
      break;
    case '9':
      rect(x, y, shapeThickness, s);
      rect(x, y+s-(shapeThickness*3), s, shapeThickness*3);
      break;
    case '4':
      rect(x, y, shapeThickness*2, s);
      break;
    case '5':
      rect(x, y, shapeThickness*3, s);
      break;
    case '6':
      rect(x+s-(shapeThickness*3), y, shapeThickness*3, s);
      break;
    case '1':
      rect(x, y+(s/2)-(shapeThickness/2), s, shapeThickness);
      rect(x+(s/2)-(shapeThickness/2), y, shapeThickness, s/2+shapeThickness/2);
      break;
    case '2':
      rect(x, y+(s/2)-(shapeThickness/2), s, shapeThickness);
      rect(x+(s/2)-(shapeThickness/2), y+(s/2)-(shapeThickness/2), shapeThickness, s/2+shapeThickness/2);
      break;
    case '3':
      rect(x, y+(s/2)-(shapeThickness/2), s/2+shapeThickness/2, shapeThickness);
      rect(x+(s/2)-(shapeThickness/2), y, shapeThickness, s);
      break;
    case '0':
      rect(x+(s/2)-(shapeThickness/2), y+(s/2)-(shapeThickness/2), shapeThickness, s/2+shapeThickness/2);
      rect(x+(s/2)-(shapeThickness/2), y+(s/2)-(shapeThickness/2), s/2+shapeThickness/2, shapeThickness);
      break;
    case '.':
      rect(x+(s/2)-(shapeThickness/2), y+(s/2)-(shapeThickness/2), shapeThickness, s/2+shapeThickness/2);
      rect(x, y+(s/2)-(shapeThickness/2), s/2+shapeThickness/2, shapeThickness);
      break;
    default:
      fill(baseColor);
      rect(x, y, s, s);
      break;
  }
}

void saveCurrent() {
  PImage temp = get(artworkStartX, 0, coverWidth, coverHeight);
  if (filename.equals("")) {
    temp.save("output/cover_" + currentBook + ".png");
  } else {
    temp.save("output/" + filename);
  }
}

void keyPressed() {
  if (key == ' ') {
    refresh = true;
    currentBook++;
  } else if (key == 's') {
    saveCurrent();
  }
  if (key == CODED) {
    refresh = true;
    if (keyCode == LEFT) {
      currentBook--;
    } else if (keyCode == RIGHT) {
      currentBook++;
    }
  }
  if (currentBook >= bookList.length) {
    currentBook = 0;
  }
  if (currentBook < 0) {
    currentBook = bookList.length-1;
  }
}

void controlEvent(ControlEvent theEvent) {
  refresh = true;
  // println("got a control event from controller with id "+theEvent.getController().getId());

  // switch(theEvent.getController().getId()) {
  //   default :
  //   println(theEvent.getController().getValue());
  //   break;
  // }
}

String getFlickrData(String name) {
  String url = "";
  String request = api + "&text=" + name + "&per_page=1&format=json&nojsoncallback=1&content_type=1&api_key=" + flickrKey;
  // println("--- request ---");
  // println(request);
  try {
    JSONObject flickrData = loadJSONObject(request);
    // println("--- data ---");
    // println( flickrData );
    JSONObject main = flickrData.getJSONObject("photos");
    JSONArray photos = main.getJSONArray("photo");
    // println("--- photos ---");
    // println(photos);
    JSONObject photo = photos.getJSONObject(0);
    // println("--- photo ---");
    // println(photo);
    String photoId = photo.getString("id");
    String secret = photo.getString("secret");
    Integer farmId = photo.getInt("farm");
    String serverId = photo.getString("server");
    url = "https://farm" + farmId + ".staticflickr.com/" + serverId + "/" + photoId + "_" + secret + "_n.jpg";
    println("--- url ---");
    println(url);
  }
  catch (Exception e) {
    println ("There was an error parsing the JSONObject.");
  }
  return url;
}


