/*Change log
101:
- introduced debugMode with possibility to choose which components to turn on
- name of file currently used for background is now displayed in the settings bar
- fixed Chrome not opening because of the path + space missing between command and URL
- fixed weather not returning to current from 5 days after 20 seconds
- implemented mute/unmute with differentiation between 0 volume and mute 

Backlog:
- make left-right?!?


  
Found bugs:
- touch area for sliding AP in and out not working
- nothing displayed after album finishes
- mute/unmute instead of pause in TuneIn?

*/
import java.nio.file.*;
import java.nio.file.Paths;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Calendar;
import http.requests.*;

String appVer="1.01";

//New AP variables
//AP: Graphics
PImage imgApBody;
PImage imgApDispShad;
PImage imgApDisp;
PImage imgApArt;
PImage imgApCart;
PImage imgApButtPwrG;
PImage imgApButtPwrR;
PImage imgApButtPwrO;
PImage imgApButtPwrB;
PImage[] imgApButtJog=new PImage[5];
int apW;
int apX;
int apX0;
int apX1;
int apAlpha=0;        //Player transparency
int apSrcAlpha=0;     //Source info transparency
int apArtistAlpha=0;  //Artist info transparency
int apTrackAlpha=0;   //Track info transparency
int apAlbumAlpha=0;   //Album info transparency
int apArtAlpha=0;     //Artwork transparency
int apCArtAlpha=0;    //Container art transparency


//AP: SoundTouch Data
int stStatus=0;  //0=Unreachable; 1=connecting; 2=standby; 3=tunein; 4=amazon; 5=local; 6=bluetooth; 7=alexa; 8=airplay; 9=invalid
String stSource;
String stArtist;
String stTrack;
String stAlbum;
String stCArt;
String stArt;
String fileCArt;
String fileArt;

//AP: Player Data
int apStatus=0;  //0=Unreachable; 1=connecting; 2=standby; 3=tunein; 4=amazon; 5=local; 6=bluetooth; 7=alexa; 8=airplay; 9=invalid
String apSource;
String apArtist;
String apTrack;
String apAlbum;
String apCArt;
String apArt;
PImage imgArt;
PImage imgCArt;

//AP: Behaviour
int apPowering=0;  //Powering status: 0=Not powering; 1=Powering up; 2=Powering down
int apHSlide=40;
int apVSlide=20;
boolean apHPullStatus=false;  //0=Not pulled; 1=Pulled

//AP: Presets
PImage[] pres=new PImage[6];
String[] presLoc={"<empty>","<empty>","<empty>","<empty>","<empty>","<empty>"};
String[] presName={"<empty>","<empty>","<empty>","<empty>","<empty>","<empty>"};
int presInitStat=0;  //0=not started; 1=started; 2=completed

//AP: Volume
int volNow=0;
int volDes=-1;        //Desired volume (-1 to init)
int volDrag=0;        //used for measuring mouseDrag in volume drag area
int volDragUnit=5;    //volume units to increment/decrement for each step
int volDragSteps=10;  //number of steps within the drag distance
int volDragLen;       //Length of a drag step
int volDisp=255;      //Transparency of volume OSD text
int volJog=0;         //Used for measuring mouseDrag by using the jog
int volDir=0;         //Stores direction of jog dragging: 0=Not moved; 1=moved up; -1=moved down
int volStartY=0;      //Start point of jog dragging, to identify change of direction
boolean isMute=false;
boolean desMute=false;


//App variables
//App: debugging
boolean debugMode=true;
boolean[] modStat={true,true,false,false,true,true,false};
//Modules status - 0: News, 1: Rail, 2: Weather, 3: Calendar, 4: AP, 5: Background, 6: Ping
//false = OFF, true = ON
//Touch Areas: 0=weather 1=news ico 2=rail 3=AP ON/OFF 4=AP mute/unmute/volume 5=AP pull/push 6*=explicit switch 7*=presets icon 8=news article
//9=settings 10=devices 11=xapps; 12*=AP artwork; 13=MET Alerts; 14=Info
int[][] ta={{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
int[] tas={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};  //Touch areas status 1/0
int[] stas={0,0,0,1,0,1,0,0,0,0,0,0,0,0,0};  //which touch areas to show
boolean st=true;          //Show touch areas
boolean debug=false;       //Show debugging info


String[] logLines={">",">",">",">",">",">",">",">",">",">"};
int logY;    //Log Y position
String pathLogL;
String pathLogR;
String fileSessLog="session.log";
String fileAppLog="app.log";
String fileDevLog="devices.log";
boolean remLog=false;
boolean fullLog=false;
String[] appModUpd=new String[4];  //Module last updates: 0=News; 1=Trains; 2=Weather-daily; 3=Weather-hourly
String[] appCR;

//App: configuration
boolean cfgUseDefault=false;
String cfgFile="config.ini";
String[] cfgLines;

//App: graphics
String[] imgExt={".jpg",".jpeg",".png"};
int[] charFix1={8208};
char[] charFix2={'-'};
String bgDefault="data\\img\\bg.png";
String tmpPath="data\\temp\\";
PImage imgLogo;
PImage[] icoAlert=new PImage[3];
PImage appSetIco;
PImage appXApps;
PImage appDevIco;
PImage appInfoIco;

int edge;
int txtRows;
int osdAlpha;
int osdSize;      //OSD font size
float nwRatio=.6;  //Ratio of the screen width for the news module
int appIcoW;

//App: fonts
String fontSlmFile="data\\fonts\\AbadiMTStd-ExtraLight.otf";
String fontStFile="data\\fonts\\bahnschrift.ttf";
String fontRndBFile="data\\fonts\\tahomabd.ttf";
String fontRndFile="data\\fonts\\tahoma.ttf";
PFont fontSlm;
PFont fontSt;
PFont fontRndB;
PFont fontRnd;
float fr=1.477;  //Font size to real size ratio

//App: Connectivity
String st_prot="http";        //Soundtouch (ST) protocol
String st_ip1="192.168.1.89";  //ST IP Address  (LAN)
String st_ip2="192.168.1.99";  //ST IP Address 2 (WiFi)
String st_ip;                  //ST IP in use
String st_port="8090";        //ST Port
String newsURL1="https://www.bbc.co.uk/news";
String rssURL1="http://feeds.bbci.co.uk/news/rss.xml?edition=uk";
String awAK="3qfetMOfxdhGnxBwuwAJGG1kqOdpAkuS";  //AccuWeather Key

//App: behaviour
int appStatus=0;
//0=run querries, load background
//1=save reduced resolution background
//2=FULL
int appFade=0;  //0=normal; 1=fade-out; 2=fade-in
int appAlpha=0;
int dimStatus=0;  //0=not dimmed; 1=dimming in; 2=dimmed; 3=dimmming out;
boolean dimNight=true;
boolean dimAuto=false;
long lastTouch;

//XApps
int xaStat=0;     //Status of X Apps area: 0=not displayed; 1=displayed/creeping in;
int xaX;
int xaY;
int xaW;
int xaH;
int xaCount=0;
int xaAPR=8;    //Apps per row
int xaIcoW;
int xaRows;
PImage[] xaImg=new PImage[1];
String[] xaCmd=new String[1];
String[] xaName=new String[1];
int[] xaTAx=new int[1];
int[] xaTAy=new int[1];

//Info
int infoStat=0;  //Status of Info area: 0=not displayed; 1=displayed/creeping in
int infoX;
int infoY;
int infoW;
int infoH;

//Devices
int devStat=0;  //Status of Devices area: 0=not displayed; 1=displayed/creeping in;
int devX;
int devY;
int devW;
int devH;
int devCount=0;
int devAPR=8;    //Devices per row
int devIcoW;
int devRows;
String[] devKinds={"unknown","camera","nas","speaker","router","computer"};
PImage[] devIcons=new PImage[6];
int[] devType=new int[3];
String[] devName=new String[3];
boolean[] devIgnore=new boolean[3];
String[] devIP=new String[3];
boolean[] devOnline=new boolean[3];
boolean devAlert;
int[] devTAx=new int[3];
int[] devTAy=new int[3];
String[] devLastEv=new String[3];
int devDispEvent=0;

//App: counters
long appLUap=0;       //last update timer AP
long appLUnw=0;       //last update timer News
long appLUrl=0;       //last update timer Trains
long appLUwr=0;       //last update timer Weather
long appLUcal=0;      //last update calendar
long appLUpres=0;     //last get presets call
long appLUvol=0;      //last volume update
long ltt;             //Last touch millis
int appUTap=3;      //Update timer AP
int appUTnw=60;     //Update timer News
int appUTrl=60;     //Update timer Trains
int appUTpres=60;   //Update presets
int appUTcal=300;     //Update timer Calendar 
int appUTwr=1800;   //Update timer Weather
int lta;    //Last touch  action
int updateNow=0;

//App: interactivity
int keyHold=-1;      //Stores the key already pressed for key combinations 

//App: External apps
String xaChrome="\"C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe\" --kiosk"; 

//App: Background
String bgLocPath="\\data\\bg";       //BG local path
String bgRunPath="\\data\\run";      //BR run path
String bgRemPath="";           //BG remote path
PImage[] bgImg=new PImage[2];
String[] bgImgFiles;
String[] bgImgNames=new String[0];
boolean bgAuto=false;
boolean bgRemRun=false;
boolean bgInit=false;
boolean bgOn=true;
boolean bgFade=false;
boolean bgImgA=false;    //Active BG Image (0 or 1)
boolean bgSwap;
boolean bgDUpd=false;    //Daily BG Update
int bgTimer=1;
int bgCount;
int bgCurr=1;
int bgAlpha=0;
int[] bgImgFade={255,0};
int bgFadeSpeedA=10;
int bgFadeSpeedM=40;
int bgFadeSpeed=bgFadeSpeedA;
long bgLastBGSwap=0;  //Last BG auto swap


//App: Settings Space
int appSettH;         //Settings area height
int appSettStat=0;    //Status of settings area: 0=not displayed; 1=displayed
int appSettPull=0;    //ammount of pull down
int[][] appSettTa={{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
//Settings area touch areas: 0=Exit; 1=BG on/off; 2=Auto; 3=Prev BG; 4=Next BG; 5=Refresh; 6=Slideshow timer decrease; 7=Slideshow timer increase; 8=Auto Dim

//***********
//Time+date Module
Calendar cal;
String[] wday={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
String[] mon={"January","February","March","April","May","June","July","August","September","October","November","December"};
boolean isNight=false;

//Time+date: coordinates
int timeX;
int timeY;
int dateX;
int dateY;

//Time+date: text
int timeSize;
int dateSize;

//Time+date: Calendar
String[][] calEnt=new String[10][4];
int calCount;

//***********
//Weather Module
//Weather: data
int[][] wrData= new int[12][6];  //hour,temp, precip, wind, humid, ico
int[][] wrFcst= new int[5][9];   //DDMM, Day temp, day precip, day wind, day ico, night temp, night precip, night wind, night ico
String wrCurDesc;    //Current weather description
String rssMet="http://www.metoffice.gov.uk/public/data/PWSCache/WarningsRSS/Region/se";
String metURL="https://www.metoffice.gov.uk/public/weather/warnings/?regionName=se";
int metWarn=0;


//Weather: images
PImage[] wrHrIco=new PImage[12];
PImage[][] wrDlIco=new PImage[5][2];

//Weather: behaviour
int wrStat=0;    //0=current; 1=12 hours; 2=5 days
int wrFade=2;    //0=static; 1=fade-out; 2=fade-in
boolean wrHUpd=false;  //hourly update status
boolean wrDUpd=false;  //daily update status

//Weather: graphics
int wrX;
int wrY;
int wrW;
int wrHCur;
int wrHFor;
int wrH;

int wrAlpha=0;  //alpha index for weather fade
int wrIcoX0;
int wrIcoX1;
int wrIcoY0;
int wrIcoY1;

//***********
//News Module
//News: Configuration
int nwCount=5;      //Number of news articles
int nwTimer=10;     //Timer for news transitions (seconds)

//News: data
String[] nwTitle = new String[nwCount];
String[] nwDesc = new String[nwCount];
String[] nwLink = new String[nwCount];
String nwDispTitle;
String nwDispDesc;

//News: Pictures
PImage nwLogo;

//News: screen coordinates
int nwLogoH;         //News icon width
int nwX;
int nwY;
int nwW;
int nwH;

//News: text
int nwFontSize10=30;    //Title text size
int nwFontSize11=25;    //Title text size (min.)
int nwFontSize20=25;    //Article text size
int nwFontSize21=23;    //Article text size (min.)

//News: behaviour 
int nwCurr=5;          //News Item Currently Displayed
long nwDisp=0;         //last news transition timer
int nwStat=0;          //Status: 0=Fading in; 1=News Displayed; 2=Fading out; 3=Transition paused
int nwAlpha=0;         //Text transparency

//***********
//Rail Info module
//Rail: screen coordinates
int rlLogoH;
int rlX0;
int rlX;
int rlY;
int rlW;
int rlH;

//Rail: pictures
PImage rlLogo;

//Rail: data
String[][] rlInfo=new String[6][6];
String[] rlAlert=new String[3];
int rlAlerts;     //Number of alerts
int rlCount;      //Number of trains
int rlUpd=0;    //Marks Trains update: 0=Not updated/failed; 1=Pending Update; 2=Updated

//Rail: behaviour
int rlStat=3;      //Status: 0=Normal; 1=Fade-out; 2=Slide; 3=Fade-in; 4=No trains
int rlAlpha0=255;
int rlAlpha4=255;
int rlXOff;        //X offset for train info sliding



void setup() {
  fullScreen();
  background(20);
  
//Query config
  if (!cfgUseDefault) { checkCfg(); }
  loadCR(sketchPath() + "\\data\\copyright.txt");
  
  //Log files init
  pathLogL=getConfig("MAIN","loclog",pathLogL);
  remLog=boolean(getConfig("MAIN","remotelog",str(remLog)));
  fullLog=boolean(getConfig("MAIN","fulllog",str(fullLog)));
  if (remLog) {
    pathLogR=getConfig("MAIN","remlog",pathLogR);
    if (pathLogR.equals("")) {
      remLog=false;
    } else {
      File path=new File(pathLogR);
      if (!path.exists()) { remLog=false; }
    }
  }
  checkFile(sketchPath() + pathLogL + "\\" + fileAppLog);
  checkFile(sketchPath() + pathLogL + "\\" + fileDevLog);
  delFile(sketchPath() + pathLogL + "\\" + fileSessLog);
  checkFile(sketchPath() + pathLogL + "\\" + fileSessLog);
  if (remLog) {
    checkFile(pathLogR + "\\" + fileAppLog);
    checkFile(pathLogR + "\\" + fileDevLog);
    delFile(pathLogR + "\\" + fileSessLog);
    checkFile(pathLogR + "\\" + fileSessLog);
  }
  app2Log(fileAppLog,"=================================");
  app2Log(fileAppLog,"Application started");
  app2Log(fileAppLog,"*********************************");
  app2Log(fileDevLog,"=================================");
  app2Log(fileDevLog,"Application started");
  app2Log(fileDevLog,"*********************************");
  if (fullLog) {
    app2Log(fileAppLog,"Full log mode is on.");
    app2Log(fileSessLog,"=================================");
    app2Log(fileSessLog,"Application started");
    app2Log(fileSessLog,"*********************************");
  } else {
    app2Log(fileAppLog,"Full log mode is off.");
  }
  
  getXAs();
  getDevices();
  xaChrome=getConfig("MAIN","chromepath",xaChrome);
  
  //Background init
  bgAuto=boolean(getConfig("BACKGROUND","slideshow",str(bgAuto)));
  bgTimer=int(getConfig("BACKGROUND","slidetimer",str(bgTimer)));
  bgLocPath=getConfig("BACKGROUND","localrepo",bgLocPath);
  bgRunPath=getConfig("BACKGROUND","localrun",bgRunPath);
  bgRemRun=boolean(getConfig("BACKGROUND","remoterun",str(bgRemRun)));
  if (bgRemRun) {
    bgRemPath=getConfig("BACKGROUND","remoterepo",bgRemPath);
    if (bgRemPath.equals("")) {
      bgRemRun=false;
    } else {
      File path=new File(bgRemPath);
      if (!path.exists()) { bgRemRun=false; }
    }
  }
  imgLogo=loadImage("data\\ico\\logo.png");
  if (bgRemRun) { getBg(bgRemPath); } else { getBg(sketchPath() + bgLocPath); }
  bgCurr=1;
  //Modules init
  st_prot=getConfig("PLAYER","protocol",st_prot);
  st_ip1=getConfig("PLAYER","ip_address1",st_ip1);
  st_ip2=getConfig("PLAYER","ip_address2",st_ip2);
  st_ip=st_ip1;
  st_port=getConfig("PLAYER","port",st_port);
  newsURL1=getConfig("NEWS","url",newsURL1);
  rssURL1=getConfig("NEWS","rss",rssURL1);
  awAK=getConfig("WEATHER","awak",awAK);
  if (!debugMode || (debugMode && modStat[1])) { thread("qTrains"); }
  //App init
  eraseTemp();
  //Images init
  icoAlert[0]=loadImage("data\\ico\\alert_g.png");
  icoAlert[1]=loadImage("data\\ico\\alert_y.png");
  icoAlert[2]=loadImage("data\\ico\\alert_r.png");
  appSetIco=loadImage("data\\ico\\buttons\\settings.png");
  appXApps=loadImage("data\\ico\\buttons\\apps.png");
  appDevIco=loadImage("data\\ico\\buttons\\devices.png");
  appInfoIco=loadImage("data\\ico\\buttons\\info.png");
  app2Log(fileAppLog,"*** Icon images loaded.");
  
  //Fonts init
  fontSlm=createFont(fontSlmFile, 100);
  fontSt=createFont(fontStFile, 100);
  fontRndB=createFont(fontRndBFile,100);
  fontRnd=createFont(fontRndFile,100);
  app2Log(fileAppLog,"*** Fonts loaded.");
  
  //General Settings
  edge=int(width*.01);
  osdSize=int(height*.06);
  timeSize=int(height*.17);  //fost .25
  dateSize=int(timeSize*.2);  
  timeX=int(width*.025);
  timeY=int(timeSize+height*0.04);
  dateX=int(timeX*1.5);
  dateY=int(timeY*1.25);
  appIcoW=int(width*.04);
  appSettH=int(height*.2);
  
//XApps Window Init
xaX=int(width*.1);
xaW=width-xaX*2;
xaIcoW=(xaW-edge*2)/xaAPR-edge*2;
xaRows=ceil(xaCount/float(xaAPR));
xaH=edge*2+(xaIcoW+edge*3)*xaRows;
xaY=-xaH;

//Devices Window Init
devX=int(width*.1);
devW=width-devX*2;
devIcoW=(devW-edge*2)/devAPR-edge*2;
devRows=ceil(devCount/float(devAPR));
devH=edge*4+(devIcoW+edge*3)*devRows;
devY=-devH;
for (int i=0;i<devKinds.length;i++) {
  devIcons[i]=loadImage("data\\ico\\devices\\" + devKinds[i] + ".png");
}

//Info Windows init
infoX=int(width*.1);
infoW=width-infoX*2;
infoH=int(height*.3);
infoY=-infoH;

//Time init

  
//News init
  nwY=int(height*.86);
  nwW=int(width*nwRatio-edge*1.5);
  nwH=height-edge-nwY;
  nwX=edge;
  nwLogoH=int(nwH-edge*1.5);
  nwLogo=loadImage("data\\ico\\modules\\news_logo.png");
  
  //News icon touch area
  ta[1][0]=nwX;
  ta[1][1]=nwY;
  ta[1][2]=nwLogoH+edge;
  ta[1][3]=nwH;
  
  //News article touch area
  ta[8][0]=nwX+edge+nwLogoH;
  ta[8][1]=nwY;
  ta[8][2]=nwW-edge-nwLogoH;
  ta[8][3]=nwH;
  
//Rail init
  rlX0=edge*2+nwW;
  rlX=rlX0;
  rlY=nwY;
  rlW=int(width*(1-nwRatio)-edge*1.5);
  rlH=nwH;
  rlLogoH=nwLogoH;
  rlLogo=loadImage("data\\ico\\modules\\rail_logo.png");
  
  //Rail touch area
  ta[2][0]=rlX;
  ta[2][1]=rlY;
  ta[2][2]=rlW;
  ta[2][3]=rlH;

//Weather init
  wrX=edge;
  wrY=nwY-edge;
  wrW=int(width*.25);
  wrHFor=int(nwH*3.9);
  wrHCur=int(nwH*2.2);
  wrH=wrHCur;
  
  //Weather touch area
  ta[0][0]=wrX;
  ta[0][1]=int(wrY-wrH*1.5);
  ta[0][2]=wrW;
  ta[0][3]=int(wrH*1.5);
  //MET Alert touch area
  ta[13][0]=wrX+wrW-50;
  ta[13][1]=wrY-50;
  ta[13][2]=50;
  ta[13][3]=50;
        
//Audio Player Init
volDragLen=height/volDragSteps;
//AP Graphics
apW=rlW;
apX0=int(width-apW*.21);
apX1=rlX;
apX=apX0;

imgApBody=loadImage("data\\player\\front\\player.png");
imgApDispShad=loadImage("data\\player\\front\\scr_shad.png");
imgApDisp=loadImage("data\\player\\front\\scr_bg.png");
imgApArt=loadImage("data\\ap_temp\\art.png");
imgApCart=loadImage("data\\ap_temp\\cart.png");
imgApButtPwrG=loadImage("data\\player\\buttons\\butt_powg.png");
imgApButtPwrO=loadImage("data\\player\\buttons\\butt_powo.png");
imgApButtPwrR=loadImage("data\\player\\buttons\\butt_powr.png");
imgApButtPwrB=loadImage("data\\player\\buttons\\butt_powb.png");
imgApButtJog[0]=loadImage("data\\player\\buttons\\butt_jogG.png");
imgApButtJog[1]=loadImage("data\\player\\buttons\\butt_jogGU.png");
imgApButtJog[2]=loadImage("data\\player\\buttons\\butt_jogGD.png");
imgApButtJog[3]=loadImage("data\\player\\buttons\\butt_jogR.png");
imgApButtJog[4]=loadImage("data\\player\\buttons\\butt_jogRD.png");

  slog("Initialising. Please wait...");

//Pictures init
  app2Log(fileAppLog,"*** Icon images (2) loaded.");

  slog("Getting Audio Player status...");
  app2Log(fileAppLog,"*** Initialization completed. Starting...");
}

void draw() {
if (lta!=0 && millis()-ltt>500) { lta=0; }

switch(appStatus) {
  case 0:  //Background init 1
    background(50);
    imageMode(CENTER);
    image(imgLogo,width/2,height/2);
    if (!debugMode || (debugMode && modStat[4])) { getStStat(); }
    if (!debugMode || (debugMode && modStat[0])) { getNews(); }
    if (!debugMode || (debugMode && modStat[2])) {getWrDaily(false); }
    if (rlUpd==2 && (!debugMode || (debugMode && modStat[1]))) { getTrains(); }
    if (!debugMode || (debugMode && modStat[3])) { thread("getCal"); }
    app2Log(fileAppLog,"*** All initial queries completed. Moving to interim init.");
    appStatus++;
    break;
  case 1:  //Interim init
    appStatus++;
    lastTouch=millis();
    app2Log(fileAppLog,"*** Interim init completed. Entering normal run state.");
    break;
  case 2:
    background(50);
    fill(0,50);
    imageMode(CORNER);
    switch (appSettStat) {
      case 0:
        if (appSettPull>0) { appSettPull-=20; }
        if (appSettPull<=0) { appSettPull=0; }
        break;
      case 1:
        if (appSettPull<appSettH) { appSettPull+=20; }
        if (appSettPull>=appSettH) { appSettPull=appSettH; }
        break;
    }
    if (!bgOn && bgInit && (!debugMode || (debugMode && modStat[5]))) { if (bgRemRun) { getBg(bgRemPath); } else { getBg(sketchPath() + bgLocPath); } }
    
    if (appSettPull>0) {
      pushMatrix();
      translate(0,appSettPull);
      dispSettings();
    }
    if (!debugMode || (debugMode && modStat[5])) {
      if (!bgOn) {
        if (bgFade) {
          if (bgAlpha>0) { bgAlpha-=bgFadeSpeedM; }
          if (bgAlpha<=0) { bgAlpha=0; bgOn=true; bgFade=false; if (bgAuto) { bgLastBGSwap=millis(); } }
          image(bgImg[int(bgImgA)],0,0,width,height);
        }
        noStroke();
        fill(10,bgAlpha);
        rect(0,0,width,height);
        if (bgInit) {
          
        }
      } else {
        tint(255,bgImgFade[int(bgImgA)]);
        image(bgImg[int(bgImgA)],0,0,width,height);
        if (bgSwap) {
          tint(255,bgImgFade[int(!bgImgA)]);
          image(bgImg[int(!bgImgA)],0,0,width,height);
          if (bgImgFade[int(!bgImgA)]<255) { bgImgFade[int(!bgImgA)]+=bgFadeSpeed; bgImgFade[int(bgImgA)]-=bgFadeSpeed; }
          if (bgImgFade[int(!bgImgA)]>=255) {
            bgImgFade[int(!bgImgA)]=255;
            bgImgFade[int(bgImgA)]=0;
            bgImgA=!bgImgA;
            bgSwap=false;
            if (bgAuto && bgFadeSpeed==bgFadeSpeedA) {
              bgLastBGSwap=millis();
              if (bgCurr<bgCount) { bgCurr++; } else { bgCurr=1; }
              if (bgCount>2) { if (bgCurr<bgCount) { bgImg[int(!bgImgA)]=loadImage(bgImgFiles[bgCurr]); } else { bgImg[int(!bgImgA)]=loadImage(bgImgFiles[0]); } } 
            }
          } 
        }
        noTint();
        if (bgFade) {
          if (bgAlpha<255) { bgAlpha+=bgFadeSpeedM; }
          if (bgAlpha>=255) { bgAlpha=255; bgOn=false; bgFade=false; }
          noStroke();
          fill(10,bgAlpha);
          rect(0,0,width,height);
        }
      }
    }
    if (volDir!=0 && (millis()-appLUvol)>1000) {
      //Jog dragged up/down
      volDes+=volDir*volDragUnit;
      if (volDes>100) { volDes=100; }
      if (volDes<0) { volDes=0; }
      if (volDir==1 && volDes%5!=0) { volDes-=volDes%5; }
      if (volDir==-1 && volDes%5!=0) { volDes+=5-volDes%5; }
      appLUvol=millis();
      volDisp=300;
    }
    if (volNow!=volDes && volDes!=-1) { setVol(); }
    if (!debugMode || (debugMode && modStat[0])) { dispNews(); }
    if (!debugMode || (debugMode && modStat[1])) { dispRail(); }
    if (!debugMode || (debugMode && modStat[4])) { dispAudio(); }
    dispTime(true);
    if (wrStat==0 && (!debugMode || (debugMode && modStat[3]))) { dispCal(); }
    if (!debugMode || (debugMode && modStat[2])) { dispWeather(); }
    if (appSettPull==0) { dispTools(); }
    
    if (debug) { dispLog(); }
    noStroke();
    fill(0,appAlpha);
    rect(0,0,width,height);
    if (appFade==2) {
      //Fade-in
      if (appAlpha>0) { appAlpha-=20; }
      if (appAlpha<=0) { appAlpha=0; appFade=0; }
    }
    if (appFade==1) {
      //Fade-out
      if (appAlpha<255) { appAlpha+=20;}
      if (appAlpha>=255) { appAlpha=0; appStatus=3; appFade=2; app2Log(fileAppLog,"Full screen player started."); }
    }

    switch(xaStat) {
      case 0:
        if (xaY>-xaH) { xaY-=50; dispXApps(); }
        if (xaY<=-xaH) { xaY=-xaH; }
        break;
      case 1:
        if (xaY<0) { xaY+=50; }
        if (xaY>=0) { xaY=0; }
        dispXApps();
        break;
    }
    switch(devStat) {
      case 0:
        if (devY>-devH) { devY-=50; dispDevices(); }
        if (devY<=-devH) { devY=-devH; }
        break;
      case 1:
        if (devY<0) { devY+=50; }
        if (devY>=0) { devY=0; }
        dispDevices();
        break;
    }
    switch(infoStat) {
      case 0:
        if (infoY>-infoH) { infoY-=50; dispInfo(); }
        if (infoY<=-infoH) { infoY=-infoH; }
        break;
      case 1:
        if (infoY<0) { infoY+=50; }
        if (infoY>=0) { infoY=0; }
        dispInfo();
        break;
    }
    
    if (appSettPull>0) { popMatrix(); }
    break;
  case 3:
    background(0);
    if (volNow!=volDes && volDes!=-1) { setVol(); }
    dispTime(false);
    if (appFade==2) {
      //Fade-in
      if (appAlpha<255) { appAlpha+=20; }
      if (appAlpha>=255) { appAlpha=255; appFade=0; }
    }
    if (appFade==1) {
      //Fade-out
      if (appAlpha>0) { appAlpha-=20;}
      if (appAlpha<=255) { appAlpha=255; appStatus=2; appFade=2; app2Log(fileAppLog,"Full screen player ended."); }
    }
    break;
  }

  if (st) {
    noFill();
    strokeWeight(1);
    stroke(255);
    for (int i=0;i<ta.length;i++) {
      if (stas[i]==1 && tas[i]==1) {
        rect(ta[i][0],ta[i][1],ta[i][2],ta[i][3]);
      }
    }
  }
  
  if (millis()-appLUap>appUTap*1000 || updateNow>0) {
    updateNow--;
    if (!debugMode || (debugMode && modStat[4])) { thread("getStStat"); }
    appLUap=millis();
  }

  if (bgAuto && millis()-bgLastBGSwap>bgTimer*60000 ) { bgSwap=true; bgFadeSpeed=bgFadeSpeedA; } 
  
  if (millis()-appLUnw>appUTnw*1000) {
    appLUnw=millis();
    if (!debugMode || (debugMode && modStat[0])) { getNews(); }
    if (!debugMode || (debugMode && modStat[6])) { thread("checkDevices"); }
  }
  
  if (millis()-appLUrl>appUTrl*1000) {
    appLUrl=millis();
    rlUpd=1;
    if (!debugMode || (debugMode && modStat[1])) { thread("qTrains"); }
  }
  
  if (millis()-appLUrl>10000 && rlUpd==2) {
    if (!debugMode || (debugMode && modStat[1])) { getTrains(); }
    rlUpd=1;
  }
  
  if (millis()-appLUwr>appUTwr*1000) { appLUwr=millis(); }
  
  if (millis()-appLUcal>appUTcal*1000) { appLUcal=millis();
    if (!debugMode || (debugMode && modStat[3])) { thread("getCal"); }
  }
  
  if (presInitStat==2 && millis()-appLUpres>appUTpres*1000) {
    if (!debugMode || (debugMode && modStat[4])) {
      presInitStat=1; thread("getPresets");
    }
  }
  
  if (appSettPull>0 && millis()-lastTouch>20000) { appSettStat=0; }
  if (devY==0 && millis()-lastTouch>20000) { devStat=0; }
  if (infoY==0 && millis()-lastTouch>20000) { infoStat=0; }
  if (xaY==0 && millis()-lastTouch>20000) { xaStat=0; }
  if (wrStat!=0 && millis()-lastTouch>20000) { wrFade=3; }
  if (dimAuto && dimStatus==0 && appAlpha==0 && millis()-lastTouch>600*1000) { dimStatus=1; }

  switch(dimStatus) {
    case 1:
      launch("powershell (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(0,10)");
      dimStatus++;
      break;
    case 3:
      launch("powershell (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(0,100)");
      dimStatus=0;
      break;
  }
}

void mouseMoved() {
  lastTouch=millis();
  if (dimStatus==2) { dimStatus=3; }
}

void mouseReleased() {
  lastTouch=millis();
  if (dimStatus==2) { dimStatus=3; }
  if (volDrag>0) { volDrag=0; }
  if (volJog!=0) { volJog=0; volDir=0; volStartY=0; appLUvol=0;}
}

void mousePressed() {
  //println(mouseButton);
}

void mouseClicked() {
  lastTouch=millis();
  if (dimStatus==2) { dimStatus=3; }
  //37=right; 39=left (long touch)
  if (appSettPull>0) {
    if (mouseX>appSettTa[0][0] && mouseX<appSettTa[0][0]+appSettTa[0][2] && mouseY>appSettTa[0][1]+appSettPull && mouseY<appSettTa[0][1]+appSettTa[0][3]+appSettPull) {
      //Close settings button
      appSettStat=0;
    }
    if (mouseX>appSettTa[1][0] && mouseX<appSettTa[1][0]+appSettTa[1][2] && mouseY>appSettTa[1][1]+appSettPull && mouseY<appSettTa[1][1]+appSettTa[1][3]+appSettPull) {
      //Background on/off button
      bgFade=true;
    }
    if (bgOn && bgCount>1 && mouseX>appSettTa[2][0] && mouseX<appSettTa[2][0]+appSettTa[2][2] && mouseY>appSettTa[2][1]+appSettPull && mouseY<appSettTa[2][1]+appSettTa[2][3]+appSettPull) {
      //Background AUTO button
      bgAuto=!bgAuto;
      if (bgAuto) { bgLastBGSwap=millis(); }
    }
    if (bgOn && mouseX>appSettTa[3][0] && mouseX<appSettTa[3][0]+appSettTa[3][2] && mouseY>appSettTa[3][1]+appSettPull && mouseY<appSettTa[3][1]+appSettTa[3][3]+appSettPull) {
      //Prev bg button
      if (bgCurr>1) { bgCurr--; } else { bgCurr=bgCount; }
      bgImg[int(!bgImgA)]=loadImage(bgImgFiles[bgCurr-1]);
      bgSwap=true;
      bgFadeSpeed=bgFadeSpeedM;
    }
    if (bgOn && mouseX>appSettTa[4][0] && mouseX<appSettTa[4][0]+appSettTa[4][2] && mouseY>appSettTa[4][1]+appSettPull && mouseY<appSettTa[4][1]+appSettTa[4][3]+appSettPull) {
      //Next bg button
      if (bgCurr==bgCount) { bgCurr=1; } else { bgCurr++; }
      bgImg[int(!bgImgA)]=loadImage(bgImgFiles[bgCurr-1]);
      bgSwap=true;
      bgFadeSpeed=bgFadeSpeedM;
    }
    if (bgOn && mouseX>appSettTa[5][0] && mouseX<appSettTa[5][0]+appSettTa[5][2] && mouseY>appSettTa[5][1]+appSettPull && mouseY<appSettTa[5][1]+appSettTa[5][3]+appSettPull) {
      //BG REFRESH button pressed
      bgFade=true;
      bgInit=true;
    }
    if (bgOn && bgAuto && mouseX>appSettTa[6][0] && mouseX<appSettTa[6][0]+appSettTa[6][2] && mouseY>appSettTa[6][1]+appSettPull && mouseY<appSettTa[6][1]+appSettTa[6][3]+appSettPull) {
      //Timer decrease
      if (bgTimer>1) { if (bgTimer<=10) { bgTimer--; } else { if (bgTimer<=30) { bgTimer-=5; } else {bgTimer-=10; }}}
    }
    if (bgOn && bgAuto && mouseX>appSettTa[7][0] && mouseX<appSettTa[7][0]+appSettTa[7][2] && mouseY>appSettTa[7][1]+appSettPull && mouseY<appSettTa[7][1]+appSettTa[7][3]+appSettPull) {
      //Timer increase
      if (bgTimer<=80) { if (bgTimer<10) { bgTimer++; } else { if (bgTimer<30) { bgTimer+=5; } else { bgTimer+=10; }}}
    }
    if (mouseX>appSettTa[8][0] && mouseX<appSettTa[8][0]+appSettTa[8][2] && mouseY>appSettTa[8][1]+appSettPull && mouseY<appSettTa[8][1]+appSettTa[8][3]+appSettPull) {
      if (dimNight) { dimAuto=true; dimNight=false; } else { if (dimAuto) { dimAuto=false; } else { dimNight=true; } }
    }
  }
  if (devY==0) {
    if (mouseX>devX && mouseX<devX+devW && mouseY<devH) {
      for (int i=0;i<devCount;i++) {
        if (mouseX>devTAx[i] && mouseX<devTAx[i]+devIcoW && mouseY>devTAy[i] && mouseY<devTAy[i]+xaIcoW) {
          devDispEvent=i+1;
        }
      }
    } else { devStat=0; devDispEvent=0; }
  }
  if (xaY==0) {
    if (mouseX>xaX && mouseX<xaX+xaW && mouseY<xaH) {
      for (int i=0;i<xaCount;i++) {
        if (mouseX>xaTAx[i] && mouseX<xaTAx[i]+xaIcoW && mouseY>xaTAy[i] && mouseY<xaTAy[i]+xaIcoW) {
          app2Log(fileAppLog,xaName[i] + " launched.");
          launch(xaCmd[i]);
        }
      }
    }
    xaStat=0;
  }
  if (infoY==0 && !(mouseX>infoX && mouseX<infoX+infoW && mouseY<infoH)) { infoStat=0; }

  if (appSettPull==0 && devY!=0 && xaY!=0) {
    if (mouseX>ta[8][0] && mouseX<ta[8][0]+ta[8][2] && mouseY>ta[8][1] && mouseY<ta[8][1]+ta[8][3] && appStatus==2) {
      if (nwTitle[0]==null) {
        //Manually query news
        appLUnw=millis();
        getNews();
      } else {
        if (nwStat==3) { nwStat=0; nwDisp=millis(); } else { nwStat=3; }
      }
    }
    if (mouseX>ta[1][0] && mouseX<ta[1][0]+ta[1][2] && mouseY>ta[1][1] && mouseY<ta[1][1]+ta[1][3] && appStatus==2) {
      //Click on News Ico
      if (nwTitle[0]==null) {
        //Manually query news
        appLUnw=millis();
        getNews();
      } else {
        if (nwStat==3) {
          //Open current news article
          launch(xaChrome + " " + nwLink[nwCurr-1]);
        } else {
          //Open news webpage
          launch(xaChrome + " https://bbc.co.uk/news");
        }
      }
    }
    if (mouseX>ta[2][0] && mouseX<ta[2][0]+ta[2][2] && mouseY>ta[2][1] && mouseY<ta[2][1]+ta[2][3]) {
      //Click on Rail Module
      if (rlUpd==0) {
        //Manually query trains
        appLUrl=millis();
        rlUpd=1;
        thread("qTrains");
      } else {
        //Open trains website
        launch(xaChrome + " https://www.southwesternrailway.com/plan-my-journey?from=sns&to=wat");
      }
    }
    if (mouseX>ta[0][0] && mouseX<ta[0][0]+ta[0][2] && mouseY>ta[0][1] && mouseY<ta[0][1]+ta[0][3] && appStatus==2) {
      if (wrStat==0 && metWarn>0 && mouseX>ta[13][0] && mouseX<ta[13][0]+ta[13][2] && mouseY>ta[13][1] && mouseY<ta[13][1]+ta[13][3]) {
        //Click on MET Alert
        launch(xaChrome + " " + metURL);
      } else { 
      //Click of Weather
      wrFade=1;
      }
    }
    //AP Module
    if (mouseX>ta[3][0] && mouseX<ta[3][0]+ta[3][2] && mouseY>ta[3][1] && mouseY<ta[3][1]+ta[3][3] && appStatus==2) {
      //Power button press
      if (stStatus==0 && lta!=1) {
        stStatus=1;
        app2Log(fileAppLog,"Attempting connection to Soundtouch.");
        thread("getStStat");
        lta=1;
        ltt=millis();
      } else {
        if (apStatus==2 && lta!=2) {
          //Power ON
          slog("Power ON");
        launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"press\" sender=\"Gabbo\">POWER</key>\"");
        launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"release\" sender=\"Gabbo\">POWER</key>\"");
        updateNow=1;
        lta=2;
        ltt=millis();
        apPowering=1;
        } else {
          if (apStatus>2 && lta!=3) {
            //Power OFF
            slog("Power OFF");
            launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"press\" sender=\"Gabbo\">POWER</key>\"");
            launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"release\" sender=\"Gabbo\">POWER</key>\"");
            updateNow=1;
            lta=3;
            ltt=millis();
            apPowering=2;
          }
        }
      }
    }
    if (mouseX>ta[4][0] && mouseX<ta[4][0]+ta[4][2] && mouseY>ta[4][1] && mouseY<ta[4][1]+ta[4][3] && volDrag==0 && apX==apX1 && stStatus>=2) {
      //Volume jog press for mute/unmute
      if (isMute) {
        launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"press\" sender=\"Gabbo\">MUTE</key>\"");
        desMute=false;  
        if (volNow==0) { volDes=10; }
      } else {
        if (volNow==0) { volDes=10; } else {
          desMute=true;
          launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/key\" --data-raw \"<?xml version=1.0 ?><key state=\"press\" sender=\"Gabbo\">MUTE</key>\"");
        }
      }
      getVol();
      volDisp=300;
    }
    if (mouseX>ta[5][0] && mouseX<ta[5][0]+ta[5][2] && mouseY>ta[5][1] && mouseY<ta[5][1]+ta[5][3] && stStatus>=2) {
      apHPullStatus=!apHPullStatus;
    }
      
    if (mouseX>ta[9][0] && mouseX<ta[9][0]+ta[9][2] && mouseY>ta[9][1] && mouseY<ta[9][1]+ta[9][3] && appStatus==2) {
      //Click on Settings Ico
      if (appSettStat==0) { appSettStat=1; } else { appSettStat=0; }
    }
    if (mouseX>ta[10][0] && mouseX<ta[10][0]+ta[10][2] && mouseY>ta[10][1] && mouseY<ta[10][1]+ta[10][3] && appStatus==2) {
      //Click on Devices Ico
      if (devStat==0) { devStat=1; } else { devStat=0; }
    }
    if (mouseX>ta[11][0] && mouseX<ta[11][0]+ta[11][2] && mouseY>ta[11][1] && mouseY<ta[11][1]+ta[11][3] && appStatus==2) {
      //Click on External Apps Ico
      if (xaStat==0) { xaStat=1; } else { xaStat=0; }
    }
    if (mouseX>ta[14][0] && mouseX<ta[14][0]+ta[14][2] && mouseY>ta[14][1] && mouseY<ta[14][1]+ta[14][3] && appStatus==2) {
      //Click on Info Ico
      if (infoStat==0) { infoStat=1; } else { infoStat=0; }
    }
  }
}

void mouseDragged() {
  if ((mouseX>ta[4][0] && mouseX<ta[4][0]+ta[4][2] && mouseY>ta[4][1] && mouseY<ta[4][1]+ta[4][3] && volDrag==0 && apX==apX1 && stStatus>=2) || volJog!=0) {
    if (volJog==0) { appLUvol=millis()-1000; }
    if (volStartY==0 || (volDir==1 && mouseY>volStartY) || (volDir==-1 && mouseY<volStartY)) {
      volStartY=mouseY;
      volDir=1;
      if (mouseY-pmouseY>0) { volDir=-1; }
    }
    volJog-=mouseY-pmouseY;
  }
  if (mouseX>width*.66 && volJog==0 && stStatus>=2) {
    //Volume drag
    int dir=1;
    if (mouseY-pmouseY>0) { dir=-1; }
    volDrag-=mouseY-pmouseY;
    if (abs(volDrag)>volDragLen) {
      volDes+=dir*volDragUnit;
      if (volDes>100) { volDes=100; }
      if (volDes<0) { volDes=0; }
      if (dir==1 && volDes%5!=0) { volDes-=volDes%5; }
      if (dir==-1 && volDes%5!=0) { volDes+=5-volDes%5; }
      volDrag=0;
      volDisp=300;
    }
  }
}
void keyPressed() {
  //println(keyCode);
  if (keyHold==-1) {
    keyHold=keyCode;
  }
  if (keyCode==87 && keyHold==17) {
    //CTRL+w
    slog("Weather Update (offline)");
    getWrDaily(false);
  }
  if (keyCode==69 && keyHold==17) {
    //CTRL+e
    slog("Weather Update (online)");
    getWrDaily(true);
  }
  if (keyCode==76 && keyHold==17) {
    //CTRL+l
    if (debug) { debug=false; } else { debug=true; }
  }
  //slog(str(keyCode));
}



void keyReleased() {
  keyHold=-1;
}

void dispSettings() {
  int butCloseW=int(width*.04);
  int settY=-appSettH+edge;
  int settX=edge;
  int txtW;
  
  stroke(255);
  strokeWeight(1);
  noFill();
  ellipseMode(CORNER);
  ellipse(width-edge-butCloseW,settY,butCloseW,butCloseW);
  line(width-edge-butCloseW*.7,settY+butCloseW*.3,width-edge-butCloseW*.3,settY+butCloseW*.7);
  line(width-edge-butCloseW*.7,settY+butCloseW*.7,width-edge-butCloseW*.3,settY+butCloseW*.3);
  appSettTa[0][0]=width-edge-butCloseW;
  appSettTa[0][1]=settY;
  appSettTa[0][2]=butCloseW;
  appSettTa[0][3]=butCloseW;
  
  //Background settings
  textFont(fontSt);
  textSize(25);
  textAlign(CENTER);
  
  if (bgOn) { stroke(0,200,0); } else { stroke(200,0,0); }
  noFill();
  strokeWeight(1);
  txtW=int(textWidth("BACKGROUND"));
  rect(settX,settY,txtW+edge,40,10);
  if (bgOn) { fill(0,200,0); } else { fill(200,0,0); }
  text("BACKGROUND",settX+(edge+txtW)/2,settY+27);
  appSettTa[1][0]=settX;
  appSettTa[1][1]=settY;
  appSettTa[1][2]=txtW+edge;
  appSettTa[1][3]=40;
  
  if (!bgOn ) { fill(60); } else { fill(200); }
  noStroke();
  settX+=edge*2+txtW;
  triangle(settX,settY+20,settX+20,settY,settX+20,settY+40);
  appSettTa[3][0]=settX;
  appSettTa[3][1]=settY;
  appSettTa[3][2]=70;
  appSettTa[3][3]=40;
  textAlign(CENTER);
  text("/",settX+80,settY+27);
  textAlign(RIGHT);
  text(bgCurr,settX+70,settY+27);
  textAlign(LEFT);
  text(bgCount,settX+90,settY+27);
  triangle(settX+140,settY,settX+140,settY+40,settX+160,settY+20);
  appSettTa[4][0]=settX+90;
  appSettTa[4][1]=settY;
  appSettTa[4][2]=70;
  appSettTa[4][3]=40;
  settX+=180;
  txtW=int(textWidth("REFRESH"));
  if (!bgOn) { stroke(60); } else { stroke(200); }
  noFill();
  rect(settX,settY,txtW+edge,40,10);
  if (!bgOn) { fill(60); } else { fill(200); }
  textAlign(CENTER);
  text("REFRESH",settX+(edge+txtW)/2,settY+27);
  appSettTa[5][0]=settX;
  appSettTa[5][1]=settY;
  appSettTa[5][2]=txtW+edge;
  appSettTa[5][3]=40;
  noFill();
  if (!bgOn || bgCount<2) { stroke(60); } else { if (bgAuto) { noStroke(); fill(200); } else { stroke(200); }}
  settX+=130+edge;
  txtW=int(textWidth("AUTO"));
  rect(settX,settY,txtW+edge,40,10);
  appSettTa[2][0]=settX;
  appSettTa[2][1]=settY;
  appSettTa[2][2]=txtW+edge;
  appSettTa[2][3]=40;
  if (!bgOn || bgCount<2) { fill(60); } else { if (bgAuto) { fill(60); } else { fill(200); }}
  text("AUTO",settX+(edge+txtW)/2,settY+27);
  settX+=80+edge;
  noStroke();
  if (!bgAuto || !bgOn ) { fill(60); } else { fill(200); }
  triangle(settX,settY+20,settX+20,settY,settX+20,settY+40);
  textAlign(CENTER);
  text(bgTimer+"'",settX+45,settY+27);
  triangle(settX+70,settY,settX+70,settY+40,settX+90,settY+20);
  appSettTa[6][0]=settX;
  appSettTa[6][1]=settY;
  appSettTa[6][2]=70;
  appSettTa[6][3]=40;
  appSettTa[7][0]=settX+70;
  appSettTa[7][1]=settY;
  appSettTa[7][2]=70;
  appSettTa[7][3]=40;
  
  txtW=int(textWidth("AUTO DIM: AT NIGHT"));
  if (dimNight) {
    stroke(0,200,0);
    noFill();
    strokeWeight(1);
    rect(edge,settY+edge+35,txtW+edge,40,10);
    fill(0,200,0);
    text("AUTO DIM: AT NIGHT",edge+(edge+txtW)/2,settY+edge+62);
  } else {
    if (dimAuto) {
      stroke(0,200,0);
      noFill();
      strokeWeight(1);
      rect(edge,settY+edge+35,txtW+edge,40,10);
      fill(0,200,0);
      text("AUTO DIM: ON",edge+(edge+txtW)/2,settY+edge+62);
    } else {
      stroke(200,0,0);
      noFill();
      strokeWeight(1);
      rect(edge,settY+edge+35,txtW+edge,40,10);
      fill(200,0,0);
      text("AUTO DIM: OFF",edge+(edge+txtW)/2,settY+edge+62);
    }
  }
  appSettTa[8][0]=edge;
  appSettTa[8][1]=settY+edge+35;
  appSettTa[8][2]=txtW+edge;
  appSettTa[8][3]=40;
  if (bgOn &&  bgCount>0 && bgImgNames.length>0) {
    fill(240,240,240);
    textAlign(CENTER);
    textSize(20);
    text(bgImgNames[bgCurr-1],width/2,-edge);
  }
  
  textAlign(RIGHT);
}

void dispTools() {   
  image(appSetIco,width-edge-appIcoW,edge,appIcoW,appIcoW);
  ta[9][0]=width-edge-appIcoW;
  ta[9][1]=edge;
  ta[9][2]=appIcoW;
  ta[9][3]=appIcoW;
  image(appDevIco,width-edge*2-appIcoW*2,edge,appIcoW,appIcoW);
  if (devAlert) { image(icoAlert[2],width-edge*2-appIcoW*2,edge+appIcoW*.6,appIcoW*.4,appIcoW*.4); }
  ta[10][0]=width-edge*2-appIcoW*2;
  ta[10][1]=edge;
  ta[10][2]=appIcoW;
  ta[10][3]=appIcoW;
  image(appXApps,width-edge*3-appIcoW*3,edge,appIcoW,appIcoW);
  ta[11][0]=width-edge*3-appIcoW*3;
  ta[11][1]=edge;
  ta[11][2]=appIcoW;
  ta[11][3]=appIcoW;
  image(appInfoIco,width-edge*4-appIcoW*4,edge,appIcoW,appIcoW);
  ta[14][0]=width-edge*4-appIcoW*4;
  ta[14][1]=edge;
  ta[14][2]=appIcoW;
  ta[14][3]=appIcoW;
}

void dispTime(boolean fullMode) {
  //Time
  String hr;
  String min;
  float minX;
  
  cal = Calendar.getInstance();
  
  if (hour()<10) { hr="0" + hour() ; } else { hr=str(hour()); }
  if (minute()<10) { min="0" + minute(); } else { min=str(minute()); }  
  
  isNight=false;
  if (hour()>20 || hour()<2) { isNight=true; }
  
  //weather update triggers
  if (hour()==5 && minute()==1 && !wrDUpd) {
    //daily update
    if (!debugMode || (debugMode && modStat[2])) { getWrDaily(true); }
    wrDUpd=true;
    wrHUpd=true;
    slog("Daily + hourly weather updated");
  }

  if (minute()==1 && !wrHUpd) {
    //hourly update
    if (!debugMode || (debugMode && modStat[2])) { getWrHourly(true); }
    wrHUpd=true;
    slog("Hourly weather updated");
  }
  
  if (hour()==0 && minute()==0 && !bgDUpd) {
    //Update backgrounds at midnight
    bgFade=true;
    bgInit=true;
    bgDUpd=true;
  }
  if (hour()==23 && minute()==0 && dimNight && !dimAuto) { dimAuto=true; }
  if (hour()==7 && minute()==0 && dimNight && dimAuto) { dimAuto=false; }
  
  if (hour()==0 && minute()==1 && bgDUpd) {
    bgDUpd=false;
  }
  
  if (minute()==2 && wrHUpd) {
    wrHUpd=false;
    wrDUpd=false;
  }
  textFont(fontSlm);
  if (fullMode) {
    textFont(fontSlm);
    textAlign(LEFT);
    textSize(timeSize*fr);
    minX=timeX + textWidth(hr + ":");
    if (second()%2==0) {
      fill(0);
      text(hr + ":",timeX+1,timeY+1);
      fill(255);
      text(hr + ":",timeX,timeY);
    } else {
      fill(0);
      text(hr + " ",timeX+1,timeY+1);
      fill(255);
      text(hr + " ",timeX,timeY);
    }
    fill(0);
    text(min,minX+1,timeY+1);
    fill(255);
    text(min,minX,timeY);
    textSize(dateSize*fr);
    fill(0);
    text(wday[cal.get(Calendar.DAY_OF_WEEK)-1]+ ", " + day() + " " + mon[month()-1],dateX+1,dateY+1);
    fill(255);
    text(wday[cal.get(Calendar.DAY_OF_WEEK)-1]+ ", " + day() + " " + mon[month()-1],dateX,dateY);
  } else {
    //Not full mode
    textSize(40);
    fill(100,appAlpha);
    /*if (second()%2==0) {
      textAlign(CENTER);
      text(":",width/2,edge+15);
    }*/
    textAlign(RIGHT);
    text(hr,width/2-3,edge+20);
    textAlign(LEFT);
    text(min,width/2+3,edge+20);
  }
}

void dispCal() {
  textAlign(LEFT);
  int calY0=dateY+20;
  int calX=edge*2;
  int calY=calY0;
  int calW=int(width*.4);
  int j=0;
  String calDate="";
  //fill(0,wrAlpha);
  strokeWeight(1);
  textFont(fontSlm);
  if (calCount==0) {
      stroke(0,wrAlpha);
      line(calX+1,calY+1,calW+1,calY+1);
      stroke(255,wrAlpha);
      line(calX,calY,calW,calY);
      calY+=30;
      textSize(30);
      fill(0,wrAlpha);
      text("No upcoming events",calX+11,calY+1);
      fill(255,wrAlpha);
      text("No upcoming events",calX+10,calY);
    //No upcoming events
  } else {
    while (j<calCount && calEnt[j][1].equals("Today")) {
      if (j==0) {
        stroke(0,wrAlpha);
        line(calX+1,calY+1,calW+1,calY+1);
        stroke(255,wrAlpha);
        line(calX,calY,calW,calY);
      }
      calY+=50;
      textSize(55);
      if (calEnt[j][2].equals("All day")) {
        fill(0,wrAlpha);
        if ((textWidth(calEnt[j][3])>calW*1.2)) {
          calEnt[j][3]=calEnt[j][3]+"...";
          while (textWidth(calEnt[j][3])>calW*1.2) {
            calEnt[j][3]=calEnt[j][3].substring(0,calEnt[j][3].length()-4)+"...";
          }
        }
        text(calEnt[j][3],calX+11,calY+1);
        fill(255,wrAlpha);
        text(calEnt[j][3],calX+10,calY);
      } else {
        if ((textWidth(calEnt[j][3])>calW*1.2-170)) {
          calEnt[j][3]=calEnt[j][3]+"...";
          while (textWidth(calEnt[j][3])>calW*1.2-170) {
            calEnt[j][3]=calEnt[j][3].substring(0,calEnt[j][3].length()-4)+"...";
          }
        }
        fill(0,wrAlpha);
        text(calEnt[j][2],calX+11,calY+1);
        text(calEnt[j][3],calX+171,calY+1);
        fill(255,wrAlpha);
        text(calEnt[j][2],calX+10,calY);
        text(calEnt[j][3],calX+170,calY);
      }
      j++;
      calY+=10;
    }
    if (j>0) { calY+=10; }
    stroke(0,wrAlpha);
    line(calX+1,calY+1,calW+1,calY+1);
    stroke(255,wrAlpha);
    line(calX,calY,calW,calY);
    while (j<calCount) {
      calY+=30;
      if (!calDate.equals(calEnt[j][1])) {
        calDate=calEnt[j][1];
        textSize(25);
        fill(0,wrAlpha);
        text(calEnt[j][1],calX+11,calY+1);
        fill(255,wrAlpha);
        text(calEnt[j][1],calX+10,calY);
      }
      fill(0,wrAlpha);
      if ((textWidth(calEnt[j][3])>calW-calX-240)) {
        calEnt[j][3]=calEnt[j][3]+"...";
        while (textWidth(calEnt[j][3])>calW-calX-240) {
          calEnt[j][3]=calEnt[j][3].substring(0,calEnt[j][3].length()-4)+"...";
        }
      }
      text(calEnt[j][2],calX+151,calY+1);
      text(calEnt[j][3],calX+241,calY+1);
      fill(255,wrAlpha);
      text(calEnt[j][2],calX+150,calY);
      text(calEnt[j][3],calX+240,calY);
      j++;
    }
  }
}

void dispWeather() {
  textAlign(LEFT);
  imageMode(CORNER);
  switch(wrStat) {
    case 0:
    //Current weather
      if (wrFade==2) {
        //Fading in
        if (wrH>wrHCur) {wrH-=20; }
        if (wrH<=wrHCur) {
          wrH=wrHCur;
          if (wrAlpha<255) { wrAlpha+=20; }
          if (wrAlpha>=255) { wrAlpha=255; wrFade=0; ta[0][1]=int(wrY-wrH*1.5); ta[0][3]=int(wrH*1.5); }
        }
      }
      if (wrFade==1) {
        //Fading out
        if (wrAlpha>0) { wrAlpha-=20; }
        if (wrAlpha<=0) {
          wrAlpha=0;
          wrFade=2;
          wrStat++;
        }
      }
      if (wrFade==3) {
        //Time-out
        if (wrAlpha>0) { wrAlpha-=20; }
        if (wrAlpha<=0) {
          wrAlpha=0;
          wrFade=2;
          wrStat=0;
        }
      }
      rectMode(CORNER);
      noStroke();
      fill(80,140);
      rect(wrX,wrY-wrH,wrW,wrH,10);
      imageMode(CENTER);
      tint(255,wrAlpha);
      image(wrHrIco[0],wrX+wrW-wrHrIco[0].width*wrH*.4/wrHrIco[0].height+wrIcoX1,wrY-wrH,wrHrIco[0].width*wrH*.8/wrHrIco[0].height,wrH*.8);
      noTint();
      fill(255,map(wrAlpha,0,255,0,230));
      textFont(fontSt);
      textSize(200);
      text(wrData[0][1]+"°",wrX+edge,wrY-wrH+150+edge);
      int txtW0=50;
      int txtW1=35;
      int txtW=txtW0;
      textSize(txtW);
      while (textWidth(wrCurDesc)>wrW-edge*2 && txtW>=txtW1) {
        txtW--;
        textSize(txtW);
      }
      textAlign(LEFT,BOTTOM);
      text(wrCurDesc,wrX+edge,wrY-edge-100,wrW-edge*2,80);
      textAlign(LEFT);
      textFont(fontRnd);
      textSize(20);
      text("RAIN: " + wrData[0][2]+"% • WIND: " + wrData[0][3]+"mph • HUM: " + wrData[0][4]+"%",wrX+edge,wrY-edge);
      imageMode(CORNER);
      if (metWarn>0) {
        fill(255,0,0,map(wrAlpha,0,255,0,100));
        ellipseMode(CENTER);
        ellipse(wrX+wrW-30,wrY-25,40,40);
        fill(255,wrAlpha);
        textAlign(CENTER);
        textSize(26);
        text(metWarn,wrX+wrW-30,wrY-16);
      }
      break;
    case 1:
    //12H weather
      if (wrFade==2) {
        //Fading in
        if (wrH<wrHFor) { wrH+=20; }
        if (wrH>=wrHFor) {
          wrH=wrHFor;
          if (wrAlpha<255) { wrAlpha+=20; }
          if (wrAlpha>=255) { wrAlpha=255; wrFade=0; ta[0][1]=int(wrY-wrH); ta[0][3]=wrH; }
        }
      }
      if (wrFade==1) {
        //Fading out
        if (wrAlpha>0) { wrAlpha-=20; }
        if (wrAlpha<=0) {
          wrAlpha=0;
          wrFade=2;
          wrStat++;
        }
      }
      if (wrFade==3) {
        //Time-out
        if (wrAlpha>0) { wrAlpha-=20; }
        if (wrAlpha<=0) {
          wrAlpha=0;
          wrFade=2;
          wrStat=0;
        }
      }
      rectMode(CORNER);
      noStroke();
      fill(80,140);
      rect(wrX,wrY-wrH,wrW,wrH,10);
      stroke(150,wrAlpha);
      fill(255,map(wrAlpha,0,255,0,230));
      tint(255,wrAlpha);
      textFont(fontSt);
      textSize(18);
      textAlign(LEFT);
      text("TEMP.",wrX+edge*2+170,wrY-wrH+20);
      text("RAIN",wrX+edge*2+255,wrY-wrH+20);
      text("WIND",wrX+edge*2+345,wrY-wrH+20);
      textSize(24);
      for (int i=0;i<wrData.length;i++) {
        line(wrX+edge,wrY-wrH+25+40*i,wrX+wrW-edge*2,wrY-wrH+25+40*i);
        textAlign(RIGHT);
        if (wrData[i][0]<10) {
          text("0"+wrData[i][0]+":00",wrX+90,wrY-wrH+55+40*i);
        } else {
          text(wrData[i][0]+":00",wrX+90,wrY-wrH+55+40*i);
        }
        image(wrHrIco[i],wrX+edge*2+90,wrY-wrH+28+40*i,wrHrIco[0].width*40/wrHrIco[0].height,40);
        textAlign(LEFT);
        text(wrData[i][1]+"°",wrX+edge*2+180,wrY-wrH+55+40*i);
        text(wrData[i][2]+"%",wrX+edge*2+260,wrY-wrH+55+40*i);
        text(wrData[i][3]+"mph",wrX+edge*2+340,wrY-wrH+55+40*i);
      }
      noTint();
      break;
    case 2:
    //5 days weather
      if (wrFade==2) {
        //Fading in
        if (wrH<wrHFor) { wrH+=20; }
        if (wrH>=wrHFor) {
          wrH=wrHFor;
          if (wrAlpha<255) { wrAlpha+=20; }
          if (wrAlpha>=255) { wrAlpha=255; wrFade=0; }
        }
      }
      if (wrFade==1 || wrFade==3) {
        //Fading out
        if (wrAlpha>0) { wrAlpha-=20; }
        if (wrAlpha<=0) {
          wrAlpha=0;
          wrFade=2;
          wrStat=0;
        }
      }
      
      rectMode(CORNER);
      noStroke();
      fill(80,140);
      rect(wrX,wrY-wrH,wrW,wrH,10);
      stroke(150,wrAlpha);
      fill(255,map(wrAlpha,0,255,0,230));
      tint(255,wrAlpha);
      textAlign(LEFT);
      textFont(fontSt);
      textSize(18);
      text("TEMP.",wrX+edge*2+190,wrY-wrH+20);
      text("RAIN",wrX+edge*2+260,wrY-wrH+20);
      text("WIND",wrX+edge*2+345,wrY-wrH+20);
      line(wrX+edge,wrY-wrH+25,wrX+wrW-edge*2,wrY-wrH+25);
      textSize(24);
      if (isNight) {
        text("Tonight",wrX+edge,wrY-wrH+80);
        image(wrDlIco[0][1],wrX+edge*2+100,wrY-wrH+53,wrDlIco[0][1].width*45/wrDlIco[0][1].height,45);
        text(wrFcst[0][5]+"°",wrX+edge*2+200,wrY-wrH+80);
        text(wrFcst[0][6]+"%",wrX+edge*2+260,wrY-wrH+80);
        text(wrFcst[0][7]+"mph",wrX+edge*2+340,wrY-wrH+80);
      } else {
        text("Today",wrX+edge,wrY-wrH+55);
        image(wrDlIco[0][0],wrX+edge*2+100,wrY-wrH+28,wrDlIco[0][0].width*45/wrDlIco[0][0].height,45);
        image(wrDlIco[0][1],wrX+edge*2+100,wrY-wrH+78,wrDlIco[0][1].width*45/wrDlIco[0][1].height,45);
        text(wrFcst[0][1]+"°",wrX+edge*2+200,wrY-wrH+55);
        text(wrFcst[0][5]+"°",wrX+edge*2+200,wrY-wrH+105);
        text(wrFcst[0][2]+"%",wrX+edge*2+260,wrY-wrH+55);
        text(wrFcst[0][6]+"%",wrX+edge*2+260,wrY-wrH+105);
        text(wrFcst[0][3]+"mph",wrX+edge*2+340,wrY-wrH+55);
        text(wrFcst[0][7]+"mph",wrX+edge*2+340,wrY-wrH+105);
      }
      for (int i=1;i<wrFcst.length;i++) {
        if (i==1) {
          text("Tomorrow",wrX+edge,wrY-wrH+55+100*i);
        } else {
          if (cal.get(Calendar.DAY_OF_WEEK)+i-1>6) {
            text(wday[cal.get(Calendar.DAY_OF_WEEK)+i-8],wrX+edge,wrY-wrH+55+100*i);
          } else {
            text(wday[cal.get(Calendar.DAY_OF_WEEK)+i-1],wrX+edge,wrY-wrH+55+100*i);
          }
        }
        line(wrX+edge,wrY-wrH+25+100*i,wrX+wrW-edge*2,wrY-wrH+25+100*i);
        image(wrDlIco[i][0],wrX+edge*2+100,wrY-wrH+28+100*i,wrDlIco[i][0].width*45/wrDlIco[i][0].height,45);
        image(wrDlIco[i][1],wrX+edge*2+100,wrY-wrH+78+100*i,wrDlIco[i][1].width*45/wrDlIco[i][1].height,45);
        text(wrFcst[i][1]+"°",wrX+edge*2+200,wrY-wrH+55+100*i);
        text(wrFcst[i][5]+"°",wrX+edge*2+200,wrY-wrH+105+100*i);
        text(wrFcst[i][2]+"%",wrX+edge*2+260,wrY-wrH+55+100*i);
        text(wrFcst[i][6]+"%",wrX+edge*2+260,wrY-wrH+105+100*i);
        text(wrFcst[i][3]+"mph",wrX+edge*2+340,wrY-wrH+55+100*i);
        text(wrFcst[i][7]+"mph",wrX+edge*2+340,wrY-wrH+105+100*i);
      }
      noTint();
      break;
  }
}

void dispNews() {
  rectMode(CORNER);
  noStroke();
  fill(255,140);
  rect(nwX,nwY,nwW,nwH,20);
  image(nwLogo,nwX+edge/2,nwY+edge/2,nwLogoH,nwLogoH);
  if (nwTitle[0]==null) {
    noStroke();
    fill(150,0,0,255);
    textFont(fontRndB);
    textSize(nwFontSize10);
    textLeading(nwFontSize10+10);
    textAlign(CENTER,CENTER);
    text("Failed to query the news.\n" + "Site or Internet down?",nwX+nwLogoH,nwY,nwW-nwLogoH,nwH-edge);
  } else {
    textAlign(LEFT);
    if (millis()<nwDisp) { nwDisp=millis(); }    //reset display timer if millis reset
    
    switch(nwStat) {
      case 0:  //Fading in
        if (nwAlpha==0) {
          if (nwCurr==nwCount) { nwCurr=1; } else { nwCurr++; nwDisp=millis(); nwAlpha+=7; }
          nwDispTitle=nwTitle[nwCurr-1];
          nwDispDesc=nwDesc[nwCurr-1];
        } else {
          if (nwAlpha<255) { nwAlpha+=7; } else { nwAlpha=255; nwStat=1; }
        }
        fill(50,nwAlpha);
        break;
      case 1:  //
        if (millis()-nwDisp>=nwTimer*1000) { nwStat=2; }
        fill(50,255);
        break;
      case 2:
        if (nwAlpha>0) { nwAlpha-=10; } else { nwAlpha=0; nwStat=0; }
        fill(50,nwAlpha);
        break;
      case 3:
        if (nwAlpha<255) { nwAlpha+=25; } else { nwAlpha=255; }
        fill(0,0,150,nwAlpha);
        break;
    }
    noStroke();
    textFont(fontRndB);
    int nwFontSize=nwFontSize10;
    
    float lrW=splitRows(nwDispTitle,nwFontSize,int(nwW-edge*2-nwLogoH));
    int txtRows0=txtRows;
    
    if (txtRows0>1) {
      if (txtRows0<=3 && lrW<(nwW-edge*2-nwLogoH)*.2) {
        //Try and shrink to decrease one row
        while (txtRows>txtRows0-1 && nwFontSize>=nwFontSize11) {
          nwFontSize--;
          lrW=splitRows(nwDispTitle,nwFontSize,int(nwW-edge*2-nwLogoH));
        }
        if (txtRows>txtRows0-1) { nwFontSize=nwFontSize10; } else { txtRows0=txtRows; }
      }
      if (txtRows0>2) {
        while (txtRows>txtRows0-1 && nwFontSize>=nwFontSize11) {
          nwFontSize--;
          lrW=splitRows(nwDispTitle,nwFontSize,int(nwW-edge*2-nwLogoH));
        }
        if (txtRows>2) {
        //Cut text to fit onto 1 row
          String nwDispTitleP=nwDispTitle+"...";
          while (txtRows>2) {
            nwDispTitleP=nwDispTitleP.substring(0,nwDispTitleP.length()-4)+"...";
            lrW=splitRows(nwDispTitleP,nwFontSize,int(nwW-edge*2-nwLogoH));
          }
          nwDispTitle=nwDispTitleP;
        }
      }
    }
    textSize(nwFontSize);
    textLeading(nwFontSize);
    text(nwDispTitle,nwX+edge+nwLogoH,nwY+edge/2,nwW-edge*1.5-nwLogoH,70);
    
    int nwDescY=35;
    if (txtRows==2) { nwDescY=65; }
    textFont(fontRnd);
    nwFontSize=nwFontSize20;
    
    lrW=splitRows(nwDispDesc,nwFontSize,int(nwW-edge*2-nwLogoH));
    txtRows0=txtRows;
    
    if (txtRows0>1) {
      if (txtRows0<=3 && lrW<(nwW-edge*2-nwLogoH)*.2) {
        //Try and shrink to decrease one row
        while (txtRows>txtRows0-1 && nwFontSize>=nwFontSize21) {
          nwFontSize--;
          lrW=splitRows(nwDispDesc,nwFontSize,int(nwW-edge*2-nwLogoH));
        }
        if (txtRows>txtRows0-1) { nwFontSize=nwFontSize20; } else { txtRows0=txtRows; }
      }
      if (txtRows0>2) {
        while (txtRows>txtRows0-1 && nwFontSize>=nwFontSize21) {
          nwFontSize--;
          lrW=splitRows(nwDispDesc,nwFontSize,int(nwW-edge*2-nwLogoH));
        }
        if (txtRows>2) {
        //Cut text to fit onto 1 row
          String nwDispDescP=nwDispDesc+"...";
          while (txtRows>2) {
            nwDispDescP=nwDispDescP.substring(0,nwDispDescP.length()-4)+"...";
            lrW=splitRows(nwDispDescP,nwFontSize,int(nwW-edge*2-nwLogoH));
          }
          nwDispDesc=nwDispDescP;
        }
      }
    }      
    textSize(nwFontSize);
    textLeading(nwFontSize);
    text(nwDispDesc,nwX+edge+nwLogoH,nwY+edge/2+nwDescY,nwW-edge*1.5-nwLogoH,80);
  }
}  

void dispRail() {
  rectMode(CORNER);
  noStroke();
  fill(255,140);
  rect(rlX0,rlY,rlW,rlH,20);
  image(rlLogo,rlX0+edge/2,rlY+edge/2,rlLogoH,rlLogoH);
  
  if (rlUpd==0) {
    textAlign(CENTER,CENTER);
    noStroke();
    fill(150,0,0,255);
    textFont(fontRndB);
    textSize(nwFontSize10);
    textLeading(nwFontSize10+10);
    text("Failed to query the trains.\n"+"Site or Internet down?",rlX+rlLogoH,rlY,rlW-rlLogoH,rlH-edge);
  } else {
    textAlign(CORNER);
    if (rlInfo[0][0]==null || (rlCount==0 && rlStat==4)) {
      //display "No trains" + reason;
      int rlFontSize=30;
      fill(0,0,150);
      noStroke();
      textFont(fontRnd);
      textSize(rlFontSize);
      textLeading(rlFontSize*1.2);
      textAlign(CENTER,CENTER);
      text("No trains running from\n"+"Staines to London Waterloo",rlX+rlLogoH,rlY,rlW-rlLogoH,rlH-edge);
    } else {
      rectMode(CORNER);
      textAlign(CENTER);
      noStroke();
      int i=0;
      int j=0;
      switch (rlStat) {
        case 0:
          if (!rlInfo[0][0].equals(rlInfo[1][0])) { rlStat++; }
          break;
        case 1:
          if (rlAlpha0>0) { rlAlpha0-=20; }
          if (rlAlpha0<=0) { rlAlpha0=0; rlStat++; }
          break;
        case 2:
          if (rlX>rlX0-(rlLogoH+edge*.5)) { rlX-=10; }
          if (rlX<=rlX0-(rlLogoH+edge*.5)) {
            arrayCopy(rlInfo[1],rlInfo[0]);
            rlX=rlX0;
            rlStat++;
            rlAlpha4=0;
            rlAlpha0=255;
          }
          break;
        case 3:
          if (rlAlpha4<255) { rlAlpha4+=20; }
          if (rlAlpha4>=255) { rlAlpha4=255; rlStat=0; }
          break;
      }
      
      while (i<5 && i<=rlCount) {
        int rlAlpha;
        if (j==0 && rlInfo[j+1][0]!=null && rlInfo[j][0].equals(rlInfo[j+1][0])) { j++; }
        if (i==0)  {rlAlpha=rlAlpha0; } else { if (i==rlCount || i==4) { rlAlpha=rlAlpha4; } else { rlAlpha=255; } }
        switch (rlInfo[j][1]) {
          case "":
            break;
          case "Cancelled":
          case "Delayed":
            fill(250,0,0,map(rlAlpha,0,255,0,50));
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            noFill();
            stroke(0,map(rlAlpha,0,255,0,150));
            strokeWeight(2);
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            strokeWeight(1);
            line(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2+rlLogoH/2+7,rlX+edge*3+rlLogoH*(i+2)+edge*.5*i,rlY+edge/2+rlLogoH/2+7);
            
            noStroke();
            fill(0,map(rlAlpha,0,255,0,150));
            textFont(fontRnd);
            textSize(15);
            text(rlInfo[j][0],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2-30);
            textFont(fontRndB);
            textSize(20);
            if (rlInfo[j][1].equals("Cancelled")){
              text("CANCEL.",rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2-3);
            } else {
              text("DELAYED",rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2-3);
            }
            break;
          case "On time":
            fill(0,250,0,map(rlAlpha,0,255,0,50));
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            noFill();
            stroke(0,map(rlAlpha,0,255,0,150));
            strokeWeight(2);
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            strokeWeight(1);
            line(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2+rlLogoH/2+7,rlX+edge*3+rlLogoH*(i+2)+edge*.5*i,rlY+edge/2+rlLogoH/2+7);
          
            noStroke();
            fill(0,map(rlAlpha,0,255,0,150));
            textFont(fontRnd);
            textSize(15);
            text("ON TIME",rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2-30);
            textFont(fontRndB);
            textSize(29);
            text(rlInfo[j][0],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2);
            textFont(fontRnd);
            textSize(15);
            text(rlInfo[j][3] + " STOPS",rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2+27);
            text(rlInfo[j][4],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2+45);
            break;
          default:
            fill(250,200,0,map(rlAlpha,0,255,0,50));
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            noFill();
            stroke(0,map(rlAlpha,0,255,0,150));
            strokeWeight(2);
            rect(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2,rlLogoH,rlLogoH,20,20,20,20);
            strokeWeight(1);
            line(rlX+edge*3+rlLogoH*(i+1)+edge*.5*i,rlY+edge/2+rlLogoH/2+7,rlX+edge*3+rlLogoH*(i+2)+edge*.5*i,rlY+edge/2+rlLogoH/2+7);
          
            noStroke();
            fill(0,map(rlAlpha,0,255,0,150));
            textFont(fontRnd);
            textSize(15);
            text(rlInfo[j][0],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2-30);
            textFont(fontRndB);
            textSize(29);
            text(rlInfo[j][1],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2);
            textFont(fontRnd);
            textSize(15);
            text(rlInfo[j][3] + " STOPS",rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2+27);
            text(rlInfo[j][4],rlX+edge*3+rlLogoH*(i+1)+rlLogoH*.5+edge*.5*i,rlY+edge/2+rlLogoH/2+45);
        }
        i++;
        j++;
      }
    }
    if (rlAlerts>0) {
      fill(255,0,0);
      noStroke();
      ellipseMode(CORNER);
      ellipse(rlX0+rlLogoH,rlY+edge,edge*1.5,edge*1.5);
    }
  }
}

void dispXApps() {
  int xaCur=0;
  
  fill(0,200);
  noStroke();
  rectMode(CORNER);
  rect(xaX,xaY,xaW,xaH,0,0,20,20);
  
  textFont(fontSlm);
  textSize(28);
  textAlign(CENTER);
  fill(255);
  for (int i=0;i<xaRows;i++) {
    for (int j=0; j<xaAPR; j++) {
      if (xaCur<xaCount) {
        image(xaImg[xaCur],xaX+edge*2+(xaIcoW+edge*2)*j,xaY+edge*2+(xaIcoW+edge*3)*i,xaIcoW,xaIcoW);
        text(xaName[xaCur],xaX+edge*2+(xaIcoW+edge*2)*j+xaIcoW/2,xaY+xaIcoW+edge*2+35+(xaIcoW+edge*3)*i);
        xaTAx[xaCur]=xaX+edge*2+(xaIcoW+edge*2)*j;
        xaTAy[xaCur]=xaY+edge*2+(xaIcoW+edge*3)*i;
        xaCur++;
      }
    }
  }
  textAlign(LEFT);
}

void dispInfo() {
  fill(0,200);
  noStroke();
  rectMode(CORNER);
  rect(infoX,infoY,infoW,infoH,0,0,20,20);
  
  image(imgLogo,infoX+edge*2,infoY+edge, imgLogo.width*(infoH/2-edge)/imgLogo.height,infoH/2-edge);
  
  textFont(fontSt);
  textSize(28);
  textAlign(LEFT);
  fill(100);
  text("version " + appVer,infoX+edge*2,infoY+edge+infoH/2);
  int j=0;
  for (int i=0;i<appModUpd.length;i++) {
    if (appModUpd[i]!=null) { text(appModUpd[i],infoX+infoW*.25,infoY+edge+28+30*j); j++; }
  }
  fill(200);
  textSize(16);
  for (int i=0;i<appCR.length;i++) {
    text(appCR[i],infoX+edge*2,infoY+edge+infoH/2+40+18*i);
  }
}

void dispDevices() {
  int devCur=0;
  
  fill(0,200);
  noStroke();
  rectMode(CORNER);
  rect(devX,devY,devW,devH,0,0,20,20);
  
  
  textFont(fontSlm);
  textSize(28);
  textAlign(CENTER);
  for (int i=0;i<devRows;i++) {
    for (int j=0; j<devAPR; j++) {
      if (devCur<devCount) {
        if (devOnline[devCur]) { fill(0,150,0); } else { if (devIgnore[devCur]) { fill(150,150,0); } else { fill(150,0,0); } } 
        rect(devX+edge*2+(devIcoW+edge*2)*j,devY+edge*2+(devIcoW+edge*3)*i,devIcoW,devIcoW,20);
        image(devIcons[devType[devCur]],devX+edge*2+(devIcoW+edge*2)*j,devY+edge*2+(devIcoW+edge*3)*i,devIcoW,devIcoW);
        fill(255);
        text(devName[devCur],devX+edge*2+(devIcoW+edge*2)*j+devIcoW/2,devY+devIcoW+edge*2+30+(devIcoW+edge*3)*i);
        devTAx[devCur]=devX+edge*2+(devIcoW+edge*2)*j;
        devTAy[devCur]=devY+edge*2+(devIcoW+edge*3)*i;
        devCur++;
      }
    }
  }
  if (devDispEvent>0) {
    fill(255);
    if (devOnline[devDispEvent-1]) {
      text(devName[devDispEvent-1] + " online since: " + devLastEv[devDispEvent-1],devX,devY+devH-edge*2,devW,50);
    } else {
      text(devName[devDispEvent-1] + " last seen online: " + devLastEv[devDispEvent-1],devX,devY+devH-edge*2,devW,50);
    }
  }
  textAlign(LEFT);
} 

void slog(String txt) {
  for (int i=logLines.length-1;i>0;i--) {
    logLines[i]=logLines[i-1];
  }
  logLines[0]=">" + txt;
}

void dispLog() {
  int logY=int(height*.3);
  for (int i=0;i<logLines.length;i++) {
    textSize(20);
    fill(255);
    textAlign(LEFT);
    text(logLines[i],700,logY);
    logY+=20;
  }
}

void dispOSD(String txt, int alpha) {
  textSize(osdSize);
  fill(255,alpha);
  textAlign(RIGHT);
  text(txt,width*.99,edge*2+appIcoW+osdSize);
}

void getNews() {
  if (devOnline[0]) {
    String da;
    String hr;
    String mi;
    String se;
    
    XML root=loadXML(rssURL1);
    if (root!=null) {
      XML ch1=root.getChild("channel");
      XML[] ch2=ch1.getChildren("item");
      for (int i=0;i<nwCount;i++) {
        nwTitle[i]=ch2[i].getChild("title").getContent();
        nwDesc[i]=ch2[i].getChild("description").getContent();
        nwLink[i]=ch2[i].getChild("link").getContent();
      }
      app2Log(fileAppLog,"News query completed.");
      
      if (day() > 9) { da=str(day()); } else { da="0"+day(); }
      if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
      if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
      if (second() > 9) { se=str(second()); } else { se="0"+second(); }
      appModUpd[0]="News updated " + mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se;
    }
  }
}

void getWrHourly(boolean online) {
    
  JSONArray jsona;
  if (online && devOnline[0]) {
    jsona=loadJSONArray("http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/331059?apikey=" + awAK + "&details=true&metric=true");
    String da;
    String hr;
    String mi;
    String se;
    if (day() > 9) { da=str(day()); } else { da="0"+day(); }
    if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
    if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
    if (second() > 9) { se=str(second()); } else { se="0"+second(); }
    appModUpd[3]="Weather (12h) updated " + mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se;
    app2Log(fileAppLog,"Weather query (12 hour) completed.");
  } else {
    jsona=loadJSONArray("data\\wr\\acc_12hour.json");
  }
  wrCurDesc=jsona.getJSONObject(0).getString("IconPhrase");
  for (int i=0;i<jsona.size();i++) {
    wrData[i][0]=int(jsona.getJSONObject(i).getString("DateTime").substring(11,13));  //Txx time
    wrData[i][1]=round(jsona.getJSONObject(i).getJSONObject("Temperature").getFloat("Value"));
    wrData[i][2]=round(jsona.getJSONObject(i).getFloat("PrecipitationProbability"));
    wrData[i][3]=round(jsona.getJSONObject(i).getJSONObject("Wind").getJSONObject("Speed").getFloat("Value")/1.61);
    wrData[i][4]=round(jsona.getJSONObject(i).getFloat("RelativeHumidity"));
    wrData[i][5]=jsona.getJSONObject(i).getInt("WeatherIcon");
    if (wrData[i][5]<10) { wrHrIco[i]=loadImage("data\\wr\\0"+wrData[i][5]+"-s.png"); } else { wrHrIco[i]=loadImage("data\\wr\\"+wrData[i][5]+"-s.png"); } 
  }
  if (online) { saveJSONArray(jsona, "data\\wr\\acc_12hour.json"); }
  wrIcoX0=wrHrIco[0].width;
  wrIcoX1=0;
  wrIcoY0=wrHrIco[0].height;
  wrIcoY1=0;
  wrHrIco[0].loadPixels();
  for (int y=0;y<wrHrIco[0].height;y++) {
    for (int x=0;x<wrHrIco[0].width;x++) {
      if (wrHrIco[0].pixels[x+y*wrHrIco[0].width]!=16777215) {
        if (x<wrIcoX0) { wrIcoX0=x; }
        if (x>wrIcoX1) { wrIcoX1=x; }
        if (y<wrIcoY0) { wrIcoY0=y; }
        if (y>wrIcoY1) { wrIcoY1=y; }
        //wrIcoY0=wrHrIco[0].height-y;
      }
    }
  }
  getMET();
}

void getWrDaily(boolean online) {
  JSONObject jsono; 
  if (online && devOnline[0]) {
    String da;
    String hr;
    String mi;
    String se;
    jsono=loadJSONObject("http://dataservice.accuweather.com/forecasts/v1/daily/5day/331059?apikey=" + awAK + "&details=true&metric=true");
    if (day() > 9) { da=str(day()); } else { da="0"+day(); }
    if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
    if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
    if (second() > 9) { se=str(second()); } else { se="0"+second(); }
    appModUpd[2]="Weather (5d) updated " + mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se;
  } else {
    jsono=loadJSONObject("data\\wr\\acc_5day.json");
  }
  JSONArray jsona=jsono.getJSONArray("DailyForecasts");
  for (int i=0;i<jsona.size();i++) {
    //DDMM, Day temp, day precip, day wind, day ico, night temp, night precip, night wind, night ico
    wrFcst[i][0]=int(jsona.getJSONObject(i).getString("Date").substring(8,10)+jsona.getJSONObject(i).getString("Date").substring(5,7));
    wrFcst[i][1]=round(jsona.getJSONObject(i).getJSONObject("Temperature").getJSONObject("Maximum").getFloat("Value"));
    wrFcst[i][2]=jsona.getJSONObject(i).getJSONObject("Day").getInt("PrecipitationProbability");
    wrFcst[i][3]=round(jsona.getJSONObject(i).getJSONObject("Day").getJSONObject("Wind").getJSONObject("Speed").getInt("Value")/1.61);
    wrFcst[i][4]=jsona.getJSONObject(i).getJSONObject("Day").getInt("Icon");
    wrFcst[i][5]=round(jsona.getJSONObject(i).getJSONObject("Temperature").getJSONObject("Minimum").getFloat("Value"));
    wrFcst[i][6]=jsona.getJSONObject(i).getJSONObject("Night").getInt("PrecipitationProbability");
    wrFcst[i][7]=round(jsona.getJSONObject(i).getJSONObject("Night").getJSONObject("Wind").getJSONObject("Speed").getInt("Value")/1.61);
    wrFcst[i][8]=jsona.getJSONObject(i).getJSONObject("Night").getInt("Icon");
    if (wrFcst[i][4]<10) { wrDlIco[i][0]=loadImage("data\\wr\\0"+wrFcst[i][4]+"-s.png"); } else { wrDlIco[i][0]=loadImage("data\\wr\\"+wrFcst[i][4]+"-s.png"); }
    if (wrFcst[i][8]<10) { wrDlIco[i][1]=loadImage("data\\wr\\0"+wrFcst[i][8]+"-s.png"); } else { wrDlIco[i][1]=loadImage("data\\wr\\"+wrFcst[i][8]+"-s.png"); }
  }
  if (online && devOnline[0]) { saveJSONObject(jsono, "data\\wr\\acc_5day.json"); app2Log(fileAppLog,"Weather query (5 days) completed."); }
  getWrHourly(online);
}

void getMET() {
  if (devOnline[0]) {
    XML root=loadXML(rssMet);
    metURL=root.getChild("channel").getChild("link").getContent();
    XML ch[]=root.getChild("channel").getChildren();
    metWarn=0;
    for (int i=0;i<ch.length;i++) {
      if (ch[i].getName().equals("item")) {
        metWarn++;
      }
    }
    app2Log(fileAppLog,"MET Alerts query completed.");
  }
}

void qTrains() {
  //Query train information via SOAP POST
  if (devOnline[0]) {
    launch("curl --location --request POST \"https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx\" --header \"Content-Type: text/xml\" --data @" + sketchPath() + "\\data\\rail\\soapenv.xml --output " + sketchPath() + "\\data\\rail\\output.xml");
    rlUpd=2;
    app2Log(fileAppLog,"Trains query completed.");
  } else { rlUpd=0; }
}

void getTrains() {
  if (devOnline[0]) {
    String da;
    String hr;
    String mi;
    String se;
    File path=new File(sketchPath() + "\\data\\rail\\output.xml");
    if (path.exists()) {
      for (int i=0;i<rlAlert.length;i++) { rlAlert[i]=""; }
      rlAlerts=0;
      XML xmlroot=loadXML("\\data\\rail\\output.xml");
      XML[] sbr=xmlroot.getChild(0).getChild(0).getChild(0).getChildren();  //station board results
      for (int i=0;i<sbr.length;i++) {
        if (sbr[i].getName().equals("lt4:nrccMessages")) {
          XML[] srvNotice=sbr[i].getChildren();
          if (srvNotice.length>0) {
            int j=0;
            while (j<srvNotice.length && j<rlAlert.length) {
              rlAlerts++;
              rlAlert[j]=srvNotice[j].getContent();
              j++;
            }
          }
        }
        rlCount=0;
        if (sbr[i].getName().equals("lt7:trainServices")) {
          XML[] trainSrv=sbr[i].getChildren();
          for (int j=0;j<trainSrv.length;j++) {
            XML[] trainInfo=trainSrv[j].getChildren();
            for (int k=0;k<trainInfo.length;k++) {
              if (trainInfo[k].getName().equals("lt4:std")) {
                rlInfo[j+1][0]=trainInfo[k].getContent();    //Scheduled time
              }
              if (trainInfo[k].getName().equals("lt4:etd")) {
                rlInfo[j+1][1]=trainInfo[k].getContent();    //Estimated time
              }
              if (trainInfo[k].getName().equals("lt5:destination")) {
                rlInfo[j+1][2]=trainInfo[k].getChild(0).getChild(0).getContent();    //Destination name
              }
              if (trainInfo[k].getName().equals("lt7:subsequentCallingPoints")) {
                XML[] sCP=trainInfo[k].getChild(0).getChildren();
                rlInfo[j+1][3]=str(sCP.length);  //Total stops
                rlInfo[j+1][4]=sCP[sCP.length-1].getChild(2).getContent();  //Destination scheduled time
                rlInfo[j+1][5]=sCP[sCP.length-1].getChild(3).getContent();  //Destination estimated time (ignore if On time)
              }
            }
            rlCount=trainSrv.length;
            if (trainSrv.length<rlInfo.length-1) {
              for (int k=trainSrv.length;k<rlInfo.length-1;k++) {
                rlInfo[k+1][0]="";
                rlInfo[k+1][1]="";
              }
            }
          }
        }
      }
      if (rlInfo[0][0]==null) { arrayCopy(rlInfo[1],rlInfo[0]); }
      if (rlCount==0) { rlInfo[0][0]=null; }
    } 
    app2Log(fileAppLog,"Trains data extracted."); //<>//
    
    if (day() > 9) { da=str(day()); } else { da="0"+day(); }
    if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
    if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
    if (second() > 9) { se=str(second()); } else { se="0"+second(); }
    appModUpd[1]="Trains info updated " + mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se;
  }
}
  
float splitRows(String txt, int txtH, int txtW) {
  float lrw;
  int epos0=0;
  int epos1=0;
  int bpos=0;
  txtRows=1;
  textSize(txtH);
  if (txt.indexOf(" ")>0) {
    while (txt.substring(epos1).indexOf(" ")>0) {
      epos1+=txt.substring(epos1).indexOf(" ")+1;
      if (textWidth(txt.substring(bpos,epos1-1))>txtW) {
        txtRows++;
        bpos=epos0;
        epos1=epos0;
      } else {
        epos0=epos1;
      }
    }
    if (textWidth(txt.substring(bpos,epos0-1))+textWidth(txt.substring(epos0))>txtW) {
      txtRows++;
      lrw=textWidth(txt.substring(epos0));
    } else {
      lrw=textWidth(txt.substring(bpos));
    }
  } else {
    if (txt.indexOf(".")>0) {
      while (txt.substring(epos1).indexOf(".")>0) {
        epos1+=txt.substring(epos1).indexOf(".")+1;
        if (textWidth(txt.substring(bpos,epos1-1))>txtW) {
          txtRows++;
          bpos=epos0;
          epos1=epos0;
        } else {
          epos0=epos1;
        }
      }
      if (textWidth(txt.substring(bpos,epos0-1))+textWidth(txt.substring(epos0))>txtW) {
        txtRows++;
        lrw=textWidth(txt.substring(epos0));
      } else {
        lrw=textWidth(txt.substring(bpos));
      }
    } else { lrw=textWidth(txt); }
  }
  return lrw;
}

void getCal() {
  Table calList;
  boolean bolFound;
  int j=0; 
  if (devOnline[1]) {
    File f=new File(sketchPath() + "\\data\\calendar.csv");
    if (f.exists()) { f.delete(); }
    Path oldFile=Paths.get("X:\\googleCal\\output.csv");
    Path newFile=Paths.get(f.getAbsolutePath());
    try { Files.copy(oldFile,newFile); } catch (IOException e) { e.printStackTrace(); }
  }

  calList=loadTable("data\\calendar.csv","csv");
  if (!calList.getString(0,0).equals("No upcoming events found.")) {
    for (int i=1;i<calList.getRowCount();i++) {
      bolFound=false;
      for (int k=0;k<j;k++) {
        if (calList.getString(i,0).indexOf("_")>0 && calEnt[k][0].equals(calList.getString(i,0).substring(0,calList.getString(i,0).indexOf("_"))) || calEnt[k][0].equals(calList.getString(i,0))) {
            bolFound=true;
        }
      }
      if (!bolFound) {
        if (calList.getString(i,0).indexOf("_")>0) {
          calEnt[j][0]=calList.getString(i,0).substring(0,calList.getString(i,0).indexOf("_"));
        } else {
          calEnt[j][0]=calList.getString(i,0);
        }
        calEnt[j][1]=calList.getString(i,1);
        calEnt[j][3]=calList.getString(i,2);
        j++;
        calCount=j;
      }
    }
    
    Calendar cal1=Calendar.getInstance();
    String yr="";
    String mo="";
    String da="";
  
    for (int i=0;i<calCount;i++) {
      if(calEnt[i][1].indexOf("-")>0) {
        if (calEnt[i][1].indexOf("T")>0) {
          calEnt[i][2]=calEnt[i][1].substring(calEnt[i][1].indexOf("T")+1,calEnt[i][1].indexOf("T")+6);
        } else {
          calEnt[i][2]="All day";
        }
        yr=calEnt[i][1].substring(0,4);
        mo=calEnt[i][1].substring(5,7);
        da=calEnt[i][1].substring(8,10);
        if(int(yr)==year() && int(mo)==month() && int(da)==day()) {
          calEnt[i][1]="Today";
        } else {
          if(int(yr)==year() && int(mo)==month() && int(da)==day()+1) {
            calEnt[i][1]="Tomorrow";
          } else {
            cal1.set(int(yr),int(mo)-1,int(da));
            calEnt[i][1]=wday[cal1.get(Calendar.DAY_OF_WEEK)-1].substring(0,3)+", "+ int(da) + " " + mon[int(mo)-1].substring(0,3);
          }
        }
      }
    }
  } else { calCount=0; }
  app2Log(fileAppLog,"Calendar query completed.");
}

void checkCfg() {
  File path=new File(sketchPath() + "\\data\\" + cfgFile);
  if (!path.exists()) {
    cfgUseDefault=true;
  } else {
    cfgLines=loadStrings("\\data\\" + cfgFile);
  }
}

String getConfig(String cfgSection, String cfgQuery, String cfgDef) {
  String val=cfgDef;
  if (!cfgUseDefault) {
    int i=0;
    boolean bolFound=false;
    while (!bolFound) {
      if (cfgLines[i].length()==cfgSection.length()+2 && cfgLines[i].equals("[" + cfgSection + "]")) { bolFound=true; }
      i++;
    }
    bolFound=false;
    while (i<cfgLines.length && !bolFound && cfgLines[i].length()>1 && !cfgLines[i].substring(0,1).equals("[")) {
      if (cfgLines[i].length()>=cfgQuery.length()+1 && cfgLines[i].substring(0,cfgQuery.length()+1).equals(cfgQuery + "=")) {
        val=cfgLines[i].substring(cfgLines[i].indexOf("=")+1);
        bolFound=true;
      }
      i++;
    }
  }
  return(val);
}

void eraseTemp() {  
  File path=new File(sketchPath() + "\\" + tmpPath);
  String[] fileNames=path.list();
  for (int i=0;i<fileNames.length;i++) {
    File tmpFile=new File(path.getAbsolutePath()+"\\"+fileNames[i]);
    if (tmpFile.exists()) { tmpFile.delete(); }
  }
  app2Log(fileAppLog,"*** Temp folder emptied.");
}

void getBg(String bgPath) {
  PImage bg;
  String leadz;
  String fname="";
  float imgR;
  int fileCount;
  int namesCount=0;
  
  app2Log(fileAppLog,"*** Background initialization started");
  //Clear run folder
  File runPath=new File(sketchPath() + bgRunPath);
  String[] runFiles1=runPath.list();
  for (int i=0;i<runFiles1.length;i++) {
    File delFile=new File(runPath.getAbsolutePath()+"\\"+runFiles1[i]);
    delFile.delete();
  }
  
  //Clear the images array
  if (bgImgFiles!=null && bgImgFiles.length>0) {
    while (bgImgFiles.length>0) {
      bgImgFiles=shorten(bgImgFiles);
    }
  }
  if (bgImgNames!=null && bgImgNames.length>0) {
    while (bgImgNames.length>0) {
      bgImgNames=shorten(bgImgNames);
    }
  }

  //Read bg repository
  //Check Day folder
  fileCount=0;
  File path=new File (bgPath + "\\" + month() + "\\" + day());
  if (path.exists()) {
    String[] fileNames=path.list();
    for (int i=0;i<fileNames.length;i++) {
      for (int j=0;j<imgExt.length;j++) {
        if (fileNames[i].length()>imgExt[j].length() && imgExt[j].equals(fileNames[i].substring(fileNames[i].length()-imgExt[j].length()).toLowerCase())) {
          fileCount++;
        }
      }
    }
  }
  if (fileCount==0) {
    //Check Month folder
    path=new File(bgPath + "\\" + month());
    if (path.exists()) {
      String[] fileNames=path.list();
      for (int i=0;i<fileNames.length;i++) {
        for (int j=0;j<imgExt.length;j++) {
          if (fileNames[i].length()>imgExt[j].length() && imgExt[j].equals(fileNames[i].substring(fileNames[i].length()-imgExt[j].length()).toLowerCase())) {
            fileCount++;
          }
        }
      }
    }
  }
  if (fileCount==0) {
    //Check BG folder
    path=new File(bgPath);
  }
  
  String[] fileNames=path.list();
  
  //Retrieve and prepare bg images
  for (int i=0;i<fileNames.length;i++) {
    boolean isImg=false;
    for (int j=0;j<imgExt.length;j++) {
      if (fileNames[i].length()>imgExt[j].length() && imgExt[j].equals(fileNames[i].substring(fileNames[i].length()-imgExt[j].length()).toLowerCase())) {
        isImg=true;
        fname=fileNames[i].substring(0,fileNames[i].length()-imgExt[j].length());
      }
    }
    if (isImg) {
      bg=loadImage(path.getPath() + "\\" + fileNames[i]);
      bgImgNames=expand(bgImgNames,namesCount+1);  //AICEA
      bgImgNames[namesCount]=fname;
      namesCount++;
      imgR=float(bg.width)/bg.height;
      if (imgR>0) {
        if (imgR<1.7) {
          image(bg,0,((bg.height*width/bg.width)-height)/-2,width,bg.height*width/bg.width);
        } else {
          image(bg,0,0,width,height);
        }
      }
      bg=get();
      leadz="";
      if (i<10) { leadz="00"; } else { if (i<100) { leadz="0"; } }
      bg.save(sketchPath() + bgRunPath + "\\" + "bg" + leadz + (i+1) + ".jpg");
    }
  }
  bgImgFiles=runPath.list();
  bgCount=bgImgFiles.length;
  for (int i=0;i<bgImgFiles.length;i++) {
    bgImgFiles[i]=sketchPath() + bgRunPath + "\\" + bgImgFiles[i];
  }
  if (bgCount>0) {
    bgImg[0]=loadImage(bgImgFiles[0]);
    if (bgCount>1) {
      bgImg[1]=loadImage(bgImgFiles[1]);
    }
  } else {
    //No images found. Load default
    bgCount=1;
    bg=loadImage(bgDefault);
    imgR=float(bg.width)/bg.height;
    if (imgR>0) {
      if (imgR<1.7) {
        image(bg,0,((bg.height*width/bg.width)-height)/-2,width,bg.height*width/bg.width);
      } else {
        image(bg,0,0,width,height);
      }
    }
    bg=get();
    bgImgFiles=expand(bgImgFiles,1);
    bgImgFiles[0]=sketchPath() + bgRunPath + "\\" + "bg001.jpg";
    bg.save(bgImgFiles[0]);
    bgImg[0]=loadImage(bgImgFiles[0]);
  }
  background(40);
  imageMode(CENTER);
  image(imgLogo,width/2,height/2);
  if (bgCount<2) { bgAuto=false; }
  if (bgAuto) { bgLastBGSwap=millis(); }
  bgOn=false;
  bgFade=true;
  bgInit=false;
  app2Log(fileAppLog,"*** Background initialization completed. " + bgCount + " image(s) found.");
}

void getXAs() {
  if(cfgLines.length>0) {
    int i=0;
    while (i<cfgLines.length) {
      if (cfgLines[i].equals("[APP]")) {
        if (xaCount>0) {
          xaImg=(PImage[]) expand(xaImg,xaImg.length+1);
          xaCmd=(String[]) expand(xaCmd,xaCmd.length+1);
          xaName=(String[]) expand(xaName,xaName.length+1);
          xaTAx=(int[]) expand(xaTAx,xaTAx.length+1);
          xaTAy=(int[]) expand(xaTAy,xaTAy.length+1);
        }
        xaName[xaCount]=cfgLines[i+1].substring(5);
        File icon=new File(sketchPath() + "\\data\\ico\\xapps\\" + cfgLines[i+2].substring(5));
        if (icon.exists()){
          xaImg[xaCount]=loadImage("\\data\\ico\\xapps\\" + cfgLines[i+2].substring(5));
        } else {
          xaImg[xaCount]=loadImage("\\data\\ico\\xapps\\blank.png");
        }
        xaCmd[xaCount]=cfgLines[i+3].substring(4);
        xaCount++;
        i+=4;
      } else {
        i++;
      }
    }
  }
}

void getDevices() {
  //Get router
  devType[0]=4;
  devName[0]=getConfig("ROUTER","name","Router");
  devIgnore[0]=false;
  devIP[0]=getConfig("ROUTER","ip_address","");
  //Get server
  devType[1]=5;
  devName[1]=getConfig("SERVER","name","Server");
  devIgnore[1]=false;
  devIP[1]=getConfig("SERVER","ip_address","");
  //Get audio player
  devType[2]=3;
  devName[2]=getConfig("PLAYER","name","Player");
  devIgnore[2]=false;
  devIP[2]=getConfig("PLAYER","ip_address1","");
  
  devCount=3;
  if(cfgLines.length>0) {
    int i=0;
    while (i<cfgLines.length) {
      if (cfgLines[i].equals("[DEVICE]")) {
        devType=(int[]) expand(devType,devType.length+1);
        devName=(String[]) expand(devName,devName.length+1);
        devIgnore=(boolean[]) expand(devIgnore,devIgnore.length+1);
        devIP=(String[]) expand(devIP,devIP.length+1);
        devOnline=(boolean[]) expand(devOnline,devOnline.length+1);
        devTAx=(int[]) expand(devTAx,devTAx.length+1);
        devTAy=(int[]) expand(devTAy,devTAy.length+1);
        devLastEv=(String[]) expand(devLastEv,devLastEv.length+1);
        devIP[devCount]=cfgLines[i+1].substring(11);
        devName[devCount]=cfgLines[i+2].substring(5);
        devType[devCount]=0;
        for (int j=1;j<devKinds.length;j++) {
          if (devKinds[j].equals(cfgLines[i+3].substring(5).toLowerCase())) {
            devType[devCount]=j;
          }
        }
        devIgnore[devCount]=boolean(cfgLines[i+4].substring(7));
        devCount++;
        i+=5;
        
      } else {
        i++;
      }
    }
  }
  thread("checkDevices");
}

void checkDevices() {
  String da;
  String hr;
  String mi;
  String se;
  if (day() > 9) { da=str(day()); } else { da="0"+day(); }
  if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
  if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
  if (second() > 9) { se=str(second()); } else { se="0"+second(); }
  
  devAlert=false;
  for (int i=0;i<devCount;i++) {
    if (isOnline(devIP[i])) {
      if (!devOnline[i]) {
        devOnline[i]=true;
        if (devLastEv[i]==null) {
          app2Log(fileAppLog,"Device \""+ devName[i] + "\" is online.");
          app2Log(fileDevLog,"Device \""+ devName[i] + "\" is online.");
        } else {
          app2Log(fileAppLog,"Device \""+ devName[i] + "\" is now online.");
          app2Log(fileDevLog,"Device \""+ devName[i] + "\" is now online.");
        }
        devLastEv[i]=mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se;
      }
    } else {
      if (devLastEv[i]==null) {
        devLastEv[i]="never";
        if (devIgnore[i]) {
          app2Log(fileAppLog,"Device \""+ devName[i] + "\" (ignorable) is NOT online.");
          app2Log(fileDevLog,"Device \""+ devName[i] + "\" (ignorable) is NOT online.");
        } else {
          app2Log(fileAppLog,"WARNING: Device \""+ devName[i] + "\" is NOT online.");
          app2Log(fileDevLog,"WARNING: Device \""+ devName[i] + "\" is NOT online.");
        }
      }
      if (devOnline[i]) { devLastEv[i]=mon[month()-1].substring(0,3) + "-" + da + " " + hr + ":" + mi + ":" + se; }
      if (!devIgnore[i]) { devAlert=true; }
      if (devOnline[i]) {
        if (devIgnore[i]) {
          app2Log(fileAppLog,"Device \""+ devName[i] + "\" (ignorable) no longer online.");
          app2Log(fileDevLog,"Device \""+ devName[i] + "\" (ignorable) no longer online.");
        } else {
          app2Log(fileAppLog,"WARNING: Device \""+ devName[i] + "\" no longer online.");
          app2Log(fileDevLog,"WARNING: Device \""+ devName[i] + "\" no longer online.");
        }
      }
      devOnline[i]=false;
      
    }
  }
  if (!devOnline[2]) {
    if (devIP[2].equals(st_ip1)) { devIP[2]=st_ip2; st_ip=st_ip2; } else { devIP[2]=st_ip1; st_ip=st_ip1; }
  }
}

boolean isOnline(String ip_address) {
  Runtime runtime = Runtime.getRuntime();
  boolean isOn=false;
  try {
    Process ipProcess = runtime.exec("ping " + ip_address + " -n 1");
    long start=millis();
    int exitValue = ipProcess.waitFor();
    //println(ip_address + ":" + (millis()-start)/100);
    if ((millis()-start)/100>5) {
      
      isOn=false;
    } else {
      isOn=true;
    }
  }
  catch (IOException e) { 
    e.printStackTrace();
  }
  catch (InterruptedException e) { 
    e.printStackTrace();
  }
  return(isOn);
}

void checkFile(String filename) {
  File f=new File(filename);
  
  if (!f.exists()) { try { f.createNewFile(); } catch (Exception e) { e.printStackTrace(); } }
}

void loadCR(String filename) {
  File f=new File(filename);
  if (f.exists()) { appCR=loadStrings(f); } else { appCR=new String[1]; appCR[0]="Error retrieving copyright file."; }
}

void app2Log(String filename, String text) {
  String mo;
  String da;
  String hr;
  String mi;
  String se;
  if (month() > 9) { mo=str(month()); } else { mo="0"+month(); }
  if (day() > 9) { da=str(day()); } else { da="0"+day(); }
  if (hour() > 9) { hr=str(hour()); } else { hr="0"+hour(); }
  if (minute() > 9) { mi=str(minute()); } else { mi="0"+minute(); }
  if (second() > 9) { se=str(second()); } else { se="0"+second(); }
  text="[" + year() + "-" + mo + "-" + da + "][" + hr + ":" + mi + ":" + se + "] " + text;
  File f=new File(sketchPath() + pathLogL + "\\" + filename);
  
  try {
    PrintWriter out=new PrintWriter(new BufferedWriter(new FileWriter(f,true)));
    out.println(text);
    out.close();
  } catch (IOException e) { e.printStackTrace(); }
  
  if (remLog) {
    File fr=new File(pathLogR + "\\" + filename);
    
    try {
      PrintWriter out=new PrintWriter(new BufferedWriter(new FileWriter(fr,true)));
      out.println(text);
      out.close();
    } catch (IOException e) { e.printStackTrace(); }
  }
}

void delFile(String filePath) {
  File f=new File(filePath);
  if (f.exists()) { f.delete(); }
}

String fixChars(String txt) {
  for (int i=0;i<charFix1.length;i++) {
    while (txt.indexOf(char(charFix1[i]))>0) {
      int pos=txt.indexOf(char(charFix1[i]));
      txt=txt.substring(0,pos) + charFix2[i] + txt.substring(pos+1);
    }
  }
  return txt;
}

void getVol() {
  if (volDes==volNow || volDes==-1) {
    XML xroot=loadXML(st_prot + "://" + st_ip + ":" + st_port + "/volume");
    if (volNow!=int(xroot.getChild("actualvolume").getContent())) {
      volNow=int(xroot.getChild("actualvolume").getContent());
      volDes=volNow;
    }
    isMute=boolean(xroot.getChild("muteenabled").getContent());
  }
}

void setVol() {
  int volStep=3;
  if (volDes>volNow) {
    if (volDes-volNow>volStep) {
      volNow+=volStep;
    } else {
      volNow=volDes;
    }
  } else {
    if (volNow-volDes>volStep) {
      volNow-=volStep;
    } else {
      volNow=volDes;
    }
  }
  launch("curl --location --request POST \"" + st_ip + ":" + st_port + "/volume\" --data-raw \"<?xml version=1.0 ?><volume>" + volNow + "</volume>\"");
  slog("Volume: " + volNow);
}

void dispAudio() {
  int dum;
  float apRat=float(apW)/imgApBody.width;
  int apH=int(imgApBody.height*apRat);
  int apY=rlY-edge-apH;
  int apCartX=int(apX+apW*.51-imgApDispShad.width*apRat/2+edge/2);
  int apCartH=imgApDispShad.height-edge/2;
  
  //apHPullStatus=true;
  //apStatus=1;
  
  switch(stStatus) {
    case 0:  //Unreachable/disconnected
      if (apStatus!=0) { osdAlpha=300; apStatus=0; apHPullStatus=false; }
      if (osdAlpha>0) { osdAlpha-=10; dispOSD("Speaker disconnected",osdAlpha); }
      if (apAlpha>0) { apAlpha-=7; }
      if (apSrcAlpha>0) { apSrcAlpha-=7; }
      if (apCArtAlpha>0) { apCArtAlpha-=7; }
      break;
    case 1:  //Connecting
      if (apStatus==0) { osdAlpha=300; apStatus=1; }
      if (osdAlpha>0) { osdAlpha-=10; dispOSD("Connecting...",osdAlpha); }
    case 2:  //Stand-by
      if (apStatus<2) { osdAlpha=300; apStatus=2; apAlpha=0; }
      if (apStatus>2) { apHPullStatus=false; apStatus=2; }
      if (osdAlpha>0) { osdAlpha-=10; dispOSD("Connected",osdAlpha); }
      if (apAlpha>0) { apAlpha-=10; }
      if (apSrcAlpha>0) { apSrcAlpha-=10; }
      if (apCArtAlpha>0) { apCArtAlpha-=10; }
      break;
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
      if (apStatus<3) { apHPullStatus=true; apAlpha=255; }
      apStatus=stStatus;
      break;
  }
  if (apHPullStatus) {
    if (apX>apX1) { apX-=apHSlide; }
    if (apX<=apX1) { apX=apX1; }
  } else {
    if (apX<apX0) { apX+=apHSlide; }
    if (apX>=apX0) { apX=apX0; }
  }
  image(imgApBody,apX,apY,apW,imgApBody.height*apRat);
  
  imageMode(CENTER);
  switch (apStatus) {
    case 0:  //Unreachable
      image(imgApButtPwrR,apX+apW*.117,apY+apH/2,imgApButtPwrR.width*apRat,imgApButtPwrR.height*apRat);
      break;
    case 1:  //Connecting
      if(int(millis()/1000)%2==1) {
        image(imgApButtPwrB,apX+apW*.117,apY+apH/2,imgApButtPwrB.width*apRat,imgApButtPwrB.height*apRat);
      } else {
        image(imgApButtPwrR,apX+apW*.117,apY+apH/2,imgApButtPwrR.width*apRat,imgApButtPwrR.height*apRat);
      }
      break;
    case 2:  //Stand-by
      if (apPowering==1 && int(millis()/100)%10>5) {
        image(imgApButtPwrG,apX+apW*.117,apY+apH/2,imgApButtPwrG.width*apRat,imgApButtPwrG.height*apRat);
      } else {
        image(imgApButtPwrB,apX+apW*.117,apY+apH/2,imgApButtPwrB.width*apRat,imgApButtPwrB.height*apRat);
      }
      break;
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
      if (apPowering==2 && int(millis()/100)%10>5) { 
        image(imgApButtPwrB,apX+apW*.117,apY+apH/2,imgApButtPwrB.width*apRat,imgApButtPwrB.height*apRat);
      } else {
        image(imgApButtPwrG,apX+apW*.117,apY+apH/2,imgApButtPwrG.width*apRat,imgApButtPwrG.height*apRat);
      }
      break;
  }
  if (apX<apX0) {
    //image(imgApDisp);
    if (volNow>0 && !isMute && !desMute) {
      if (volJog!=0) {
        if (volDir==1) {
          image(imgApButtJog[1],apX+apW*.9,apY+apH/2,imgApButtJog[1].width*apRat,imgApButtJog[1].height*apRat);
        } else {
          image(imgApButtJog[2],apX+apW*.9,apY+apH/2,imgApButtJog[2].width*apRat,imgApButtJog[2].height*apRat);
        }
      } else {
        image(imgApButtJog[0],apX+apW*.9,apY+apH/2,imgApButtJog[0].width*apRat,imgApButtJog[0].height*apRat);
      }
    } else {
      if (volJog!=0 && volDir==-1) {
        image(imgApButtJog[4],apX+apW*.9,apY+apH/2,imgApButtJog[4].width*apRat,imgApButtJog[4].height*apRat);
      } else {
        image(imgApButtJog[3],apX+apW*.9,apY+apH/2,imgApButtJog[3].width*apRat,imgApButtJog[3].height*apRat);
      }
    }
    image(imgApDisp,apX+apW*.51,apY+apH/2, imgApDisp.width*apRat, imgApDisp.height*apRat);
    tint(255,apAlpha);
    image(imgApCart,apCartX+imgApCart.width*apCartH/imgApCart.height/2,apY+apH/2, imgApCart.width*apCartH/imgApCart.height,apCartH);
    image(imgApDispShad,apX+apW*.51,apY+apH/2, imgApDispShad.width*apRat, imgApDispShad.height*apRat);
  }
  imageMode(CORNER);
  
  //AP Touch Areas
  //Power button
  ta[3][0]=int(apX+apW*.117-imgApButtPwrR.width*.4);
  ta[3][1]=apY;
  ta[3][2]=int(imgApButtPwrR.width*.8);
  ta[3][3]=apH;
  //Volume button
  ta[4][0]=int(apX+apW*.9-imgApButtPwrR.width/2);
  ta[4][1]=apY;
  ta[4][2]=imgApButtPwrR.width;
  ta[4][3]=apH;
  //Push/pull corner
  ta[5][0]=int(apX-apW*.05);
  ta[5][1]=int(apY-apW*.05);
  ta[5][2]=int(apW*.1);
  ta[5][3]=int(apW*.15);
  
  
  switch (apStatus) {
    case 0:
      break;
    case 1:
      break;
  }
  if (volDisp>0) {
    if (desMute) {
      dispOSD("Volume: MUTE",volDisp);
    } else {
      dispOSD("Volume: " + volDes,volDisp);
    }
    volDisp-=5;
  }
}

void getPresets() {
  if (devOnline[2]) {
    boolean found;
    slog("Getting presets...");
    XML xroot=loadXML(st_prot + "://" + st_ip + ":" + st_port + "/presets");
    XML[] xchild=xroot.getChildren();
    for (int i=0;i<pres.length;i++) {
      found=false;
      for (int j=0;j<xchild.length;j++) {
        if(int(xchild[j].getString("id"))==i+1) {
          found=true;
          if (!presLoc[i].equals(xchild[j].getChild("ContentItem").getString("location"))) {
            presLoc[i]=xchild[j].getChild("ContentItem").getString("location");
            presName[i]=xchild[j].getChild("ContentItem").getChild("itemName").getContent();
            //Check if the artwork actually exists
            GetRequest getR=new GetRequest(xchild[j].getChild("ContentItem").getChild("containerArt").getContent());
            getR.send();
            if (getR.getContent().substring(1,8).equals("\"error\"")) {
              switch (xchild[j].getChild("ContentItem").getString("source")) {
                case "LOCAL_MUSIC":
                  try { Files.copy(Paths.get(sketchPath() + "\\data\\player\\src\\itunes.png"),Paths.get(sketchPath() + "\\" + tmpPath + "\\Preset" + (i+1) + ".png")); } catch (IOException e) { e.printStackTrace(); }
                  break;
                default:
                  try { Files.copy(Paths.get(sketchPath() + "\\data\\player\\src\\void.png"),Paths.get(sketchPath() + "\\" + tmpPath + "\\Preset" + (i+1) + ".png")); } catch (IOException e) { e.printStackTrace(); } //<>//
                  break;
              } 
            } else {
              byte[] png=loadBytes(xchild[j].getChild("ContentItem").getChild("containerArt").getContent());
              saveBytes(tmpPath + "\\Preset" + (i+1) + ".png",png);
            }
            pres[i]=loadImage(tmpPath + "\\Preset" + (i+1) + ".png");
          }
        }
      }
      if (!found) {
        presLoc[i]="<empty>";
        pres[i]=loadImage("data\\img\\blank.png");    
      }
    }
    slog("Presets initalized");
    app2Log(fileAppLog,"Soundtouch presets initalization completed.");
    presInitStat=2;
    appLUpres=millis();
  }
}

void getStStat() {
  println("AP: " + apStatus + " / ST: " + stStatus);
  if(!devOnline[2]) {
    //Soundtouch is offline
    slog("Soundtouch offline...");
    app2Log(fileAppLog,"Soundtouch offline. Query not performed.");
    stStatus=0;
  } else {
    GetRequest get1 = new GetRequest(st_prot + "://" + st_ip + ":" + st_port);
    get1.send();
    if (get1.getContent()==null) {
      //Soundtouch unreachable
      slog("Soundtouch disconnected...");
      app2Log(fileAppLog,"Soundtouch query failure.");
      stStatus=0;
      devOnline[2]=false;
    } else {
      if (fullLog) { app2Log(fileSessLog,"Querying Soundtouch status."); }
      XML xroot=loadXML(st_prot + "://" + st_ip + ":" + st_port + "/now_playing");
      XML[] xchild=xroot.getChildren("ContentItem");
      XML[] xchild2;
      //Query presets
      if (presInitStat==0) {
        presInitStat=1;
        thread("getPresets");
      }
      switch(xchild[0].getString("source")) {
        case "STANDBY":
          stStatus=2;
          break;
        case "TUNEIN":
          stStatus=3;
          stSource=xroot.getChild("stationName").getContent();
          
          //Check Container Art (station's logo) change
          if (stCArt==null || stCArt.equals("") || !stCArt.equals(xchild[0].getChild("containerArt").getContent())) {
            stCArt=xchild[0].getChild("containerArt").getContent();
            fileCArt=stCArt;
          }
          //Check Artwork presence and change
          if (xroot.getChild("art").getString("artImageStatus").equals("IMAGE_PRESENT")) {
            if (stArt==null || stArt.equals("") || !stArt.equals(xroot.getChild("art").getContent())) {
              if (!stCArt.equals(xroot.getChild("art").getContent())) {
                fileArt=xroot.getChild("art").getContent();
              }
              stArt=xroot.getChild("art").getContent();
            }
          } else { stArt=stCArt; }
          break;
        case "LOCAL_MUSIC":
          stStatus=4;
          break;
        case "AMAZON":
          stStatus=5;
          break;
        case "BLUETOOTH":
          stStatus=6;
          break;
        case "ALEXA":
          stStatus=7;
          break;
        case "AIRPLAY":
          stStatus=8;
          break;
        case "INVALID_SOURCE":
          stStatus=9;
          break;
      }
      if (stStatus>=3 && stStatus<=9) {
        getVol();
      }
    }
  }
}

/* Deprecated stuff

*/
