{ This unit defines the structure of the model. There are four functions. The
  first function, called counts, defines the number, names, and units of the
  model, the state variables, the process variables, the driver variables and
  the parameters. The second function, called processes, is the actual equations
  which make up the model. The third function, derivs, calculates the
  derivatives of state variables. And the fourth function, parcount, is used to
  automatically number the parameters consecutively. 
    The state variables, driver variables, process variables and parameters are
  all stored in global arrays, called stat, drive, proc, and par, respectively.
  The function counts accesses the global arrays directly but the other functions
  operate on copies of the global arrays. }
unit equations;

interface

uses  stypes, math, sysutils;

PROCEDURE counts;
PROCEDURE processes(time:double; dtime:double; var tdrive:drivearray;
                       var tpar:paramarray; var tstat:statearray;
                       var tproc:processarray; CalculateDiscrete:Boolean);
PROCEDURE derivs(t, drt:double; var tdrive:drivearray; var tpar:paramarray;
             var statevalue:yValueArray; VAR dydt:yValueArray);
function ParCount(processnum:integer) : integer;

var
  tproc:processarray;
  tstat:statearray;
  sensflag:boolean;
  newyear:Boolean = false;
  DayofYear: double = 0;
  h: array[1..4,1..4] of double;

implementation

uses frontend, calculate, options;

           { Do not make modifcations above this line. }
{*****************************************************************************}

{ This procedure defines the model. The number of parameters, state, driver and
  process variables are all set in this procedure. The model name, version
  number and time unit are also set here. This procedure accesses the global
  arrays containing the the parameters, state, driver and process variables and
  the global structure ModelDef directly, to save memory space. }
PROCEDURE counts;
var
 i,npar,CurrentProc:integer;
begin
{ Set the modelname, version and time unit. }
ModelDef.modelname := 'interdependent resource';
ModelDef.versionnumber := '1.0.0';
ModelDef.timeunit := 'day';
ModelDef.contactperson := 'Ed';
ModelDef.contactaddress1 := 'Ecosystems';
ModelDef.contactaddress2 := 'MBL';
ModelDef.contactaddress3 := 'Woods Hole';

{ Set the number of state variables in the model. The maximum number of state
  variables is maxstate, in unit stypes. }
ModelDef.numstate := 23;

{ Enter the name, units and symbol for each state variable. The maximum length
  of the state variable name is 17 characters and the maximum length for units
  and symbol is stringlength (specified in unit stypes) characters. }
 
 
with stat[1] do
 begin
    name:='Plant C';  units:='g C m-2';  symbol:='BC';
 end;
 
with stat[2] do
 begin
    name:='Plant N';  units:='g N m-2';  symbol:='BN';
 end;
 
with stat[3] do
 begin
    name:='canopy water';  units:='mm';  symbol:='Wc';
 end;
 
with stat[4] do
 begin
    name:='Avail N';  units:='g N m-2';  symbol:='N';
 end;
 
with stat[5] do
 begin
    name:='soil water';  units:='mm';  symbol:='Ws';
 end;
 
with stat[6] do
 begin
    name:='Effort C';  units:='effort';  symbol:='VC';
 end;
 
with stat[7] do
 begin
    name:='Effort N';  units:='effort';  symbol:='VN';
 end;
 
with stat[8] do
 begin
    name:='sub effort light';  units:='effort';  symbol:='vCI';
 end;
 
with stat[9] do
 begin
    name:='sub effort CO2';  units:='effort';  symbol:='vCCa';
 end;
 
with stat[10] do
 begin
    name:='sub effort H2O';  units:='effort';  symbol:='vCW';
 end;
 
with stat[11] do
 begin
    name:='Int up C';  units:='g C m-2 day-1';  symbol:='UCbar';
 end;
 
with stat[12] do
 begin
    name:='Int up N';  units:='g N m-2 day-1';  symbol:='UNbar';
 end;
 
with stat[13] do
 begin
    name:='Int rec C';  units:='g C m-2 day-1';  symbol:='RCbar';
 end;
 
with stat[14] do
 begin
    name:='Int rec N';  units:='g N m-2 day-1';  symbol:='RNbar';
 end;
 
with stat[15] do
 begin
    name:='Cum UC';  units:='g C m-2';  symbol:='cumUC';
 end;
 
with stat[16] do
 begin
    name:='Cum UN';  units:='g N m-2';  symbol:='cumUN';
 end;
 
with stat[17] do
 begin
    name:='Cum TR';  units:='mm';  symbol:='CumTR';
 end;
 
with stat[18] do
 begin
    name:='Cum UW';  units:='mm';  symbol:='CumUW';
 end;
 
with stat[19] do
 begin
    name:='Cum runoff';  units:='g N m-2';  symbol:='cumRO';
 end;
 
with stat[20] do
 begin
    name:='Cum resp';  units:='g C m-2';  symbol:='CumRC';
 end;
 
with stat[21] do
 begin
    name:='Cum C TO';  units:='g C m-2';  symbol:='CumTC';
 end;
 
with stat[22] do
 begin
    name:='Cum RC&TC';  units:='g C m-2';  symbol:='CumRCTC';
 end;
 
with stat[23] do
 begin
    name:='Cum N TO';  units:='g N m-2';  symbol:='CumTN';
 end;

{ Set the total number of processes in the model. The first numstate processes
  are the derivatives of the state variables. The maximum number of processes is
  maxparam, in unit stypes. }
ModelDef.numprocess := ModelDef.numstate + 28;

{ For each process, set proc[i].parameters equal to the number of parameters
  associated with that process, and set IsDiscrete to true or false. After each
  process, set the name, units, and symbol for all parameters associated with
  that process. Note that Parcount returns the total number of parameters in
  all previous processes. }
 
CurrentProc := ModelDef.numstate + 1;
With proc[CurrentProc] do
   begin
      name       := 'Light Ps';
      units       := 'g C m-2 hr-1';
      symbol       := 'UCI';
      parameters       := 4;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='max light Ps';  units:='g C m-2 hr-1';  symbol:='rhoI';
 end;
with par[npar + 2] do
 begin
    name:='quantun half sat';  units:='umol m-2 sec-1';  symbol:='eta';
 end;
with par[npar + 3] do
 begin
    name:='beers coef';  units:='m2 m-2';  symbol:='kI';
 end;
with par[npar + 4] do
 begin
    name:='specific leaf area';  units:='m2 g-1 C';  symbol:='lambda';
 end;
 
CurrentProc := ModelDef.numstate + 2;
With proc[CurrentProc] do
   begin
      name       := 'C Ps';
      units       := 'g C m-2 hr-1';
      symbol       := 'UCCa';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='max C Ps';  units:='g C m-2 hr-1';  symbol:='rhoC';
 end;
with par[npar + 2] do
 begin
    name:='CO2 half sat';  units:='ppm';  symbol:='kC';
 end;
 
CurrentProc := ModelDef.numstate + 3;
With proc[CurrentProc] do
   begin
      name       := 'PImax';
      units       := 'g C m-2 hr-1';
      symbol       := 'PImax';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 4;
With proc[CurrentProc] do
   begin
      name       := 'PCmax';
      units       := 'g C m-2 hr-1';
      symbol       := 'PCmax';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 5;
With proc[CurrentProc] do
   begin
      name       := 'LT';
      units       := 'm2 m-2';
      symbol       := 'LT';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 6;
With proc[CurrentProc] do
   begin
      name       := 'Water Ps';
      units       := 'g C m-2 hr';
      symbol       := 'UCw';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='UCw rate const';  units:='g C m-2 ppm-1 MPa-1 hr-1';  symbol:='PW';
 end;
with par[npar + 2] do
 begin
    name:='leaf wilt pot';  units:='MPa';  symbol:='psiw';
 end;
 
CurrentProc := ModelDef.numstate + 7;
With proc[CurrentProc] do
   begin
      name       := 'Photosynthesis';
      units       := 'g C m-2 hr-1';
      symbol       := 'UC';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='Ps scaler';  units:='none';  symbol:='PsS';
 end;
 
CurrentProc := ModelDef.numstate + 8;
With proc[CurrentProc] do
   begin
      name       := 'N up';
      units       := 'g N m-2 hr-1';
      symbol       := 'UN';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N up rate 1';  units:='g N g-1 C hr-1';  symbol:='gN';
 end;
with par[npar + 2] do
 begin
    name:='half sat 1';  units:='g N m-2';  symbol:='kN';
 end;
 
CurrentProc := ModelDef.numstate + 9;
With proc[CurrentProc] do
   begin
      name       := 'Water up';
      units       := 'mm hr-1';
      symbol       := 'UW';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='water up rate const';  units:='mm g-1 C Mpa-1 hr-1';  symbol:='gW';
 end;
 
CurrentProc := ModelDef.numstate + 10;
With proc[CurrentProc] do
   begin
      name       := 'Respiration';
      units       := 'g C m-2 hr-1';
      symbol       := 'RC';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='resp rate const';  units:='hr-1';  symbol:='rmC';
 end;
 
CurrentProc := ModelDef.numstate + 11;
With proc[CurrentProc] do
   begin
      name       := 'C turnover';
      units       := 'g C m-2 hr-1';
      symbol       := 'TC';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='C turnover rate const';  units:='hr-1';  symbol:='mC';
 end;
 
CurrentProc := ModelDef.numstate + 12;
With proc[CurrentProc] do
   begin
      name       := 'N turnover';
      units       := 'g N m-2 hr-1';
      symbol       := 'TN';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N turnover rate const';  units:='hr-1';  symbol:='mN';
 end;
 
CurrentProc := ModelDef.numstate + 13;
With proc[CurrentProc] do
   begin
      name       := 'transpiraton';
      units       := 'mm hr-1';
      symbol       := 'TR';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='tranpiration rate';  units:='mm MPa-2 m-2 hr-1';  symbol:='sigma';
 end;
with par[npar + 2] do
 begin
    name:='base VPD';  units:='MPa';  symbol:='V0';
 end;
 
CurrentProc := ModelDef.numstate + 14;
With proc[CurrentProc] do
   begin
      name       := 'N leach';
      units       := 'g N m-2 hr-1';
      symbol       := 'LN1';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='loss rate cosnt1';  units:='hr-1';  symbol:='tauN';
 end;
 
CurrentProc := ModelDef.numstate + 15;
With proc[CurrentProc] do
   begin
      name       := 'runoff';
      units       := 'mm hr-1';
      symbol       := 'RO';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='RO rate const';  units:='hr-1';  symbol:='tauw';
 end;
with par[npar + 2] do
 begin
    name:='field cap';  units:='mm';  symbol:='Wf';
 end;
 
CurrentProc := ModelDef.numstate + 16;
With proc[CurrentProc] do
   begin
      name       := 'PHI';
      units       := 'none';
      symbol       := 'PHI';
      parameters       := 3;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='acclim rate';  units:='day-1';  symbol:='a';
 end;
with par[npar + 2] do
 begin
    name:='sub acclim rate';  units:='day-1';  symbol:='omega';
 end;
with par[npar + 3] do
 begin
    name:='int const';  units:='day-1';  symbol:='rho';
 end;
 
CurrentProc := ModelDef.numstate + 17;
With proc[CurrentProc] do
   begin
      name       := 'psiC';
      units       := 'g C m-2 day-1';
      symbol       := 'psiC';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 18;
With proc[CurrentProc] do
   begin
      name       := 'psiN';
      units       := 'g N m-2 day-1';
      symbol       := 'psiN';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 19;
With proc[CurrentProc] do
   begin
      name       := 'soil potential';
      units       := 'MPa';
      symbol       := 'Psis';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='PSIs expon';  units:='none';  symbol:='b';
 end;
 
CurrentProc := ModelDef.numstate + 20;
With proc[CurrentProc] do
   begin
      name       := 'canopy potential';
      units       := 'MPa';
      symbol       := 'PsiL';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='Can capacitance';  units:='L MPa-1 m-2';  symbol:='c';
 end;
with par[npar + 2] do
 begin
    name:='not used';  units:='none';  symbol:='WC0';
 end;
 
CurrentProc := ModelDef.numstate + 21;
With proc[CurrentProc] do
   begin
      name       := 'allometry';
      units       := 'g C m-2';
      symbol       := 'S';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='alpha';  units:='m2 g-1 C';  symbol:='alpha';
 end;
with par[npar + 2] do
 begin
    name:='gamma';  units:='m2 g-1 C';  symbol:='gamma';
 end;
 
CurrentProc := ModelDef.numstate + 22;
With proc[CurrentProc] do
   begin
      name       := 'stoichiometry';
      units       := 'none';
      symbol       := 'THETA';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='opt C:N';  units:='g C g-1 N';  symbol:='qB';
 end;
 
CurrentProc := ModelDef.numstate + 23;
With proc[CurrentProc] do
   begin
      name       := 'beta';
      units       := 'none';
      symbol       := 'beta';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 24;
With proc[CurrentProc] do
   begin
      name       := 'max yield';
      units       := 'g C m-2 effort-1 hr-1';
      symbol       := 'ymax';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 25;
With proc[CurrentProc] do
   begin
      name       := 'yeild light';
      units       := 'g C m-2 effort-1 hr-1';
      symbol       := 'yCI';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 26;
With proc[CurrentProc] do
   begin
      name       := 'yeild CO2';
      units       := 'g C m-2 effort-1 hr-1';
      symbol       := 'yCCa';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 27;
With proc[CurrentProc] do
   begin
      name       := 'yeild H2O';
      units       := 'g C m-2 effort-1 hr-1';
      symbol       := 'yCW';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 28;
With proc[CurrentProc] do
   begin
      name       := 'Calibration';
      units       := 'none';
      symbol       := 'Calib';
      parameters       := 13;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='calibrate';  units:='none';  symbol:='calibrate';
 end;
with par[npar + 2] do
 begin
    name:='BC target';  units:='g C m-2';  symbol:='BCt';
 end;
with par[npar + 3] do
 begin
    name:='BN target';  units:='g N m-2';  symbol:='BNt';
 end;
with par[npar + 4] do
 begin
    name:='VC target';  units:='effort';  symbol:='VCt';
 end;
with par[npar + 5] do
 begin
    name:='vCi target';  units:='effert';  symbol:='vCIt';
 end;
with par[npar + 6] do
 begin
    name:='vCCa target';  units:='effort';  symbol:='vCCat';
 end;
with par[npar + 7] do
 begin
    name:='Ps target';  units:='g C m-2 day-1';  symbol:='UCt';
 end;
with par[npar + 8] do
 begin
    name:='resp target';  units:='g C m-2 day-1';  symbol:='RCt';
 end;
with par[npar + 9] do
 begin
    name:='C turnover target';  units:='g C m-2 day-1';  symbol:='TCt';
 end;
with par[npar + 10] do
 begin
    name:='N up target';  units:='g N m-2 day-1';  symbol:='UNt';
 end;
with par[npar + 11] do
 begin
    name:='N turnover target';  units:='g N m-2 day-1';  symbol:='TNt';
 end;
with par[npar + 12] do
 begin
    name:='water up target';  units:='mm day-1';  symbol:='UWt';
 end;
with par[npar + 13] do
 begin
    name:='transpiration target';  units:='mm day-1';  symbol:='TRt';
 end;

{ Set the total number of drivers in the model. The maximum number of drivers is
  maxdrive, in unit stypes. }
ModelDef.numdrive := 6;

{ Set the names, units, and symbols of the drivers. The maximum length for the
  name, units and symbol is 20 characters. }
 
with drive[1] do
 begin
    name:='irradiance';  units:='umol m-2 sec-1';  symbol:='I';
 end;
 
with drive[2] do
 begin
    name:='N input';  units:='g N m-2 hr-1';  symbol:='IN1';
 end;
 
with drive[3] do
 begin
    name:='CO2';  units:='ppm';  symbol:='Ca';
 end;
 
with drive[4] do
 begin
    name:='Ppt';  units:='mm hr-1';  symbol:='Ppt';
 end;
 
with drive[5] do
 begin
    name:='VPD';  units:='Mpa';  symbol:='VPD';
 end;
 
with drive[6] do
 begin
    name:='Days end';  units:='none';  symbol:='EOD';
 end;

{ The first numstate processes are the derivatives of the state variables. The
  code sets the names, units and symbols accordingly.}
for i:= 1 to ModelDef.numstate do proc[i].name:='d'+stat[i].name+'dt';
for i:= 1 to ModelDef.numstate do proc[i].units := stat[i].units + 't-1';
for i:= 1 to ModelDef.numstate do proc[i].symbol := 'd' + stat[i].symbol + 'dt';

{ Code to sum up the total number of parameters in the model. Do not change the
  next few lines. }
ModelDef.numparam := 0;
for i := 1 to ModelDef.NumProcess do
  ModelDef.numparam := ModelDef.numparam + proc[i].parameters;

end; // counts procedure


{ A procedure to calculate the value of all states and processes at the current
  time. This function accesses time, state variables and process variables by
  reference, ie it uses the same array as the calling routine. It does not use
  the global variables time, stat and proc because values calculated during
  integration might later be discarded. It does access the global variables par,
  drive and ModelDef directly because those values are not modified.

  The model equations are written using variable names which correspond to the
  actual name instead of using the global arrays (i.e. SoilWater instead of
  stat[7].value). This makes it necessary to switch all values into local
  variables, do all the calculations and then put everything back into the
  global variables. Lengthy but worth it in terms of readability of the code. }

// Choose either GlobalPs, ArcticPs, or none here so the appropriate Ps model is compiled below.
{$DEFINE none}

PROCEDURE processes(time:double; dtime:double; var tdrive:drivearray;
                       var tpar:paramarray; var tstat:statearray;
                       var tproc:processarray; CalculateDiscrete:Boolean);
{$IFDEF GlobalPs}
const
// Global Ps parameters
 x1 = 11.04;             x2 = 0.03;
 x5 = 0.216;             x6 = 0.6;
 x7 = 3.332;             x8 = 0.004;
 x9 = 1.549;             x10 = 1.156;
 gammastar = 0;          kCO2 = 995.4;  }
{$ENDIF}

// Modify constant above (line above "procedure processes..." line )to specify
// which Ps model and it's constants should be compiled. Choosing a Ps model
// automatically includes the Et and Misc constants (i.e. Gem is assumed).

{$IFDEF ArcticPs}
const
// Arctic Ps parameters
x1 = 0.192;	x2 = 0.125;
x5 = 2.196;	x6 = 50.41;
x7 = 0.161;	x8 = 14.78;
x9 = 1.146;
gammastar = 0.468;	kCO2 = 500.3;
{$ENDIF}

{$IFDEF ArcticPs OR GlobalPs}
//const
// General Et parameters
aE1 = 0.0004;    aE2 = 150;  aE3 = 1.21;   aE4 = 6.11262E5;

// Other constants
cp = 1.012E-9; //specific heat air MJ kg-1 oC-1
sigmaSB = 4.9e-9; //stefan-Boltzmann MJ m-2 day-1 K-4
S0 = 117.5; //solar constant MJ m-2 day-1
bHI1 =0.23;
bHI2 =0.48;
mw = 2.99; //kg h2o MJ-1
alphaMS = 2; //mm oC-1 day-1                                 }
{$ENDIF}

var
{ List the variable names you are going to use here. Generally, this list
  includes all the symbols you defined in the procedure counts above. The order
  in which you list them does not matter. }
{States}
BC, dBCdt, 
BN, dBNdt, 
Wc, dWcdt, 
N, dNdt, 
Ws, dWsdt, 
VC, dVCdt, 
VN, dVNdt, 
vCI, dvCIdt, 
vCCa, dvCCadt, 
vCW, dvCWdt, 
UCbar, dUCbardt, 
UNbar, dUNbardt, 
RCbar, dRCbardt, 
RNbar, dRNbardt, 
cumUC, dcumUCdt, 
cumUN, dcumUNdt, 
CumTR, dCumTRdt, 
CumUW, dCumUWdt, 
cumRO, dcumROdt, 
CumRC, dCumRCdt, 
CumTC, dCumTCdt, 
CumRCTC, dCumRCTCdt, 
CumTN, dCumTNdt, 

{processes and associated parameters}
UCI, rhoI, eta, kI, lambda, 
UCCa, rhoC, kC, 
PImax, 
PCmax, 
LT, 
UCw, PW, psiw, 
UC, PsS, 
UN, gN, kN, 
UW, gW, 
RC, rmC, 
TC, mC, 
TN, mN, 
TR, sigma, V0, 
LN1, tauN, 
RO, tauw, Wf, 
PHI, a, omega, rho, 
psiC, 
psiN, 
Psis, b, 
PsiL, c, WC0, 
S, alpha, gamma, 
THETA, qB, 
beta, 
ymax, 
yCI, 
yCCa, 
yCW, 
Calib, calibrate, BCt, BNt, VCt, vCIt, vCCat, UCt, RCt, TCt, UNt, TNt, UWt, TRt, 

{drivers}
I, 
IN1, 
Ca, 
Ppt, 
VPD, 
EOD

{Other double}

:double; {Final double}

{Other integers}
npar, j, jj, kk, ll, tnum:integer;

{ Boolean Variables }


{ Functions or procedures }

begin
{ Copy the drivers from the global array, drive, into the local variables. }
I := tdrive[1].value;
IN1 := tdrive[2].value;
Ca := tdrive[3].value;
Ppt := tdrive[4].value;
VPD := tdrive[5].value;
EOD := tdrive[6].value;

{ Copy the state variables from the global array into the local variables. }
BC := tstat[1].value;
BN := tstat[2].value;
Wc := tstat[3].value;
N := tstat[4].value;
Ws := tstat[5].value;
VC := tstat[6].value;
VN := tstat[7].value;
vCI := tstat[8].value;
vCCa := tstat[9].value;
vCW := tstat[10].value;
UCbar := tstat[11].value;
UNbar := tstat[12].value;
RCbar := tstat[13].value;
RNbar := tstat[14].value;
cumUC := tstat[15].value;
cumUN := tstat[16].value;
CumTR := tstat[17].value;
CumUW := tstat[18].value;
cumRO := tstat[19].value;
CumRC := tstat[20].value;
CumTC := tstat[21].value;
CumRCTC := tstat[22].value;
CumTN := tstat[23].value;

{ And now copy the parameters into the local variables. No need to copy the
  processes from the global array into local variables. Process values will be
  calculated by this procedure.

  Copy the parameters for each process separately using the function ParCount
  to keep track of the number of parameters in the preceeding processes.
  npar now contains the number of parameters in the preceding processes.
  copy the value of the first parameter of this process into it's local
  variable }
npar:=ParCount(ModelDef.numstate + 1);
rhoI := par[npar + 1].value;
eta := par[npar + 2].value;
kI := par[npar + 3].value;
lambda := par[npar + 4].value;

npar:=ParCount(ModelDef.numstate + 2);
rhoC := par[npar + 1].value;
kC := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 6);
PW := par[npar + 1].value;
psiw := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 7);
PsS := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 8);
gN := par[npar + 1].value;
kN := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 9);
gW := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 10);
rmC := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 11);
mC := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 12);
mN := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 13);
sigma := par[npar + 1].value;
V0 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 14);
tauN := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 15);
tauw := par[npar + 1].value;
Wf := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 16);
a := par[npar + 1].value;
omega := par[npar + 2].value;
rho := par[npar + 3].value;
 
npar:=ParCount(ModelDef.numstate + 19);
b := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 20);
c := par[npar + 1].value;
WC0 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 21);
alpha := par[npar + 1].value;
gamma := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 22);
qB := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 28);
calibrate := par[npar + 1].value;
BCt := par[npar + 2].value;
BNt := par[npar + 3].value;
VCt := par[npar + 4].value;
vCIt := par[npar + 5].value;
vCCat := par[npar + 6].value;
UCt := par[npar + 7].value;
RCt := par[npar + 8].value;
TCt := par[npar + 9].value;
UNt := par[npar + 10].value;
TNt := par[npar + 11].value;
UWt := par[npar + 12].value;
TRt := par[npar + 13].value;
 
dBCdt := -999;
dBNdt := -999;
dWcdt := -999;
dNdt := -999;
dWsdt := -999;
dVCdt := -999;
dVNdt := -999;
dvCIdt := -999;
dvCCadt := -999;
dvCWdt := -999;
dUCbardt := -999;
dUNbardt := -999;
dRCbardt := -999;
dRNbardt := -999;
dcumUCdt := -999;
dcumUNdt := -999;
dCumTRdt := -999;
dCumUWdt := -999;
dcumROdt := -999;
dCumRCdt := -999;
dCumTCdt := -999;
dCumRCTCdt := -999;
dCumTNdt := -999;
UCI := -999;
UCCa := -999;
PImax := -999;
PCmax := -999;
LT := -999;
UCw := -999;
UC := -999;
UN := -999;
UW := -999;
RC := -999;
TC := -999;
TN := -999;
TR := -999;
LN1 := -999;
RO := -999;
PHI := -999;
psiC := -999;
psiN := -999;
Psis := -999;
PsiL := -999;
S := -999;
THETA := -999;
beta := -999;
ymax := -999;
yCI := -999;
yCCa := -999;
yCW := -999;
Calib := -999;
 
{ Enter the equations to calculate the processes here, using the local variable
  names defined above. }

Calib:=0;

S:=VC+VN;
VC:=VC/S;
VN:=1-VC;
S:=vCI+vCCa+vCW;
vCI:=vCI/S;
vCCa:=vCCa/S;
vCW:=1-vCI-vCCa;

S:=BC*((alpha*BC+1)/(gamma*BC+1));
LT:=lambda*S*VC*(vCCa+vCI);
psiS:=-0.01*power(Ws/Wf,-b);
PsiL:=psiw+Wc/c/LT;
THETA:=BC/qB/BN; 

PImax:=PsS*rhoI*vCI/(vCCa+vCI);
PCmax:=PsS*rhoC*vCCa/(vCCa+vCI);
UCI:=(PImax/kI)*ln((eta+I)/(eta+I*exp(-kI*LT)));
UCCa:=LT*PCmax*Ca/(kc+Ca);
UCw:=LT*PsS*PW*(psiL-Psiw)*Ca;
if UCw<0 then UCw:=0;
UC:=min(UCI,min(UCCa,UCw));
UN:=S*gN*N*VN/(kN+N);
UW:=S*gw*(psiS-PsiL)*VC*vCW;
RC:=rmC*THETA*BC;
TC:=mC*BC;
TN:=mN*BN/THETA;



TR:=sigma*UC*VPD/(Ca*(1+VPD/V0));

LN1:=tauN*N;
if Ws>Wf then RO:=tauW*(Ws-Wf) else RO:=0;
PHI:=power(UCbar/RCbar,VC)*power(UNbar/RNbar,VN);
psiC:=((rmC+mC)*BC)/THETA;
psiN:=mN*THETA*BN;
if UC=UCI then 
  begin
    yCI:=eta+I*exp(-kI*LT);
    yCI:=(rhoI*vCCa/kI/sqr(vCCa+vCI))*ln((eta+I)/yCI)+S*VC*PImax*I*exp(-kI*LT)/yCI; 
  end
else yCI:=0;
if UC=UCCa then yCCa:=UCCa/vCCa else yCCa:=0;

if UC=UCW then yCW:=Ca*(1+VPD/V0)*S*gw*(psiS-PsiL)*VC/(sigma*VPD) else yCW:=0;

ymax:=max(yCI,max(yCCa,yCW));
if ymax=0 then
  begin
    beta:=0;
    ymax:=1;
  end
else beta:=(yCI*vCI+yCCa*vCCa+yCW*vCW)/ymax;


if CalculateDiscrete then
   begin

 {calibrate}
      if (calibrate>-100) and (EOD=1) then
        begin
          IF CALIBRATE <0 THEN calibrate :=-calibrate*exp(-5e-6*time);


          if (VC<VCt) then qB:=qB*(1+calibrate)
          else             qB:=qB*(1-calibrate);

          if (CumUC<UCt) then PsS:=PsS*(1+calibrate)
          else                PsS:=PsS*(1-calibrate);

          if (CumUN<UNt) then gN:=gN*(1+0.5*calibrate)
          else                gN:=gN*(1-0.5*calibrate);

          if vCI<vCIt then rhoI:=rhoI*(1-calibrate)
          else             rhoI:=rhoI*(1+calibrate);

          if vCCa<vCCat then rhoC:=rhoC*(1-calibrate)
          else               rhoC:=rhoC*(1+calibrate);

          if vCW<1-vCIt-vCCat then PW:=PW*(1-calibrate)
          else                     PW:=PW*(1+calibrate);

          if cumUW>UWt then gW:=gW*(1-calibrate)
          else              gW:=gW*(1+calibrate);

          if cumTR>TRt then sigma:=sigma*(1-calibrate)
          else              sigma:=sigma*(1+calibrate);


          if cumRC>RCt then rmc:=rmc*(1-calibrate)
          else              rmc:=rmc*(1+calibrate);

          if cumTC>TCt then mc:=mc*(1-calibrate)
          else              mc:=mc*(1+calibrate);

          if cumTN>TNt then mn:=mn*(1-calibrate)
          else              mn:=mn*(1+calibrate);

          par[FmCalculate.GetArrayIndex(vtparameter,'PsS')].value:=PsS;  
          par[FmCalculate.GetArrayIndex(vtparameter,'qB')].value:=qB;
          par[FmCalculate.GetArrayIndex(vtparameter,'rhoI')].value:=rhoI;
          par[FmCalculate.GetArrayIndex(vtparameter,'rhoC')].value:=rhoC;
          par[FmCalculate.GetArrayIndex(vtparameter,'PW')].value:=PW;
          par[FmCalculate.GetArrayIndex(vtparameter,'gN')].value:=gN;
          par[FmCalculate.GetArrayIndex(vtparameter,'gW')].value:=gW;
          par[FmCalculate.GetArrayIndex(vtparameter,'rmC')].value:=rmC;
          par[FmCalculate.GetArrayIndex(vtparameter,'mC')].value:=mC;
          par[FmCalculate.GetArrayIndex(vtparameter,'mN')].value:=mN;
          par[FmCalculate.GetArrayIndex(vtparameter,'sigma')].value:=sigma;

        end;
   end;
if CalculateDiscrete then
begin
// Add any discrete processes here
end; //discrete processes


{ Now calculate the derivatives of the state variables. If the holdConstant
  portion of the state variable is set to true then set the derivative equal to
  zero. }
if (tstat[1].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dBCdt := 0
else
 dBCdt := 0.1*(UC-TC-RC);
 
if (tstat[2].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dBNdt := 0
else
 dBNdt := 0.1*(UN-TN);
 
if (tstat[3].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dWcdt := 0
else
 dWcdt := 0.1*(UW-TR);
 
if (tstat[4].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dNdt := 0
else
 dNdt := 0.1*(IN1-UN-LN1);
 
if (tstat[5].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dWsdt := 0
else
 dWsdt := 0.1*(Ppt-UW-RO);
 
if (tstat[6].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dVCdt := 0
else
 dVCdt := 0.1*(a*ln(PHI*RCbar/UCbar)*VC);
 
if (tstat[7].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dVNdt := 0
else
 dVNdt := 0.1*(a*ln(PHI*RNbar/UNbar)*VN);
 
if (tstat[8].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dvCIdt := 0
else
 dvCIdt := 0.1*(omega*(yCI/ymax-beta)*vCI);
 
if (tstat[9].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dvCCadt := 0
else
 dvCCadt := 0.1*(omega*(yCCa/ymax-beta)*vCCa);
 
if (tstat[10].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dvCWdt := 0
else
 dvCWdt := 0.1*(omega*(yCW/ymax-beta)*vCW);
 
if (tstat[11].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dUCbardt := 0
else
 dUCbardt := 0.1*(rho*(UC-UCbar));
 
if (tstat[12].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dUNbardt := 0
else
 dUNbardt := 0.1*(rho*(UN-UNbar));
 
if (tstat[13].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dRCbardt := 0
else
 dRCbardt := 0.1*(rho*(psiC-RCbar));
 
if (tstat[14].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dRNbardt := 0
else
 dRNbardt := 0.1*(rho*(psiN-RNbar));
 
if (tstat[15].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dcumUCdt := 0
else
 dcumUCdt := 0.1*(UC);
 
if (tstat[16].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dcumUNdt := 0
else
 dcumUNdt := 0.1*(UN);
 
if (tstat[17].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumTRdt := 0
else
 dCumTRdt := 0.1*(TR);
 
if (tstat[18].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumUWdt := 0
else
 dCumUWdt := 0.1*(UW);
 
if (tstat[19].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dcumROdt := 0
else
 dcumROdt := 0.1*(RO);
 
if (tstat[20].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumRCdt := 0
else
 dCumRCdt := 0.1*(RC);
 
if (tstat[21].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumTCdt := 0
else
 dCumTCdt := 0.1*(TC);
 
if (tstat[22].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumRCTCdt := 0
else
 dCumRCTCdt := 0.1*(RC+TC);
 
if (tstat[23].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dCumTNdt := 0
else
 dCumTNdt := 0.1*(TN);
 

{ Now that the calculations are complete, assign everything back into the arrays
  so the rest of the code can access the values calculated here. (Local variables
  are destroyed at the end of the procedure).

  Put the state variables back into the global arrays in case the state variable
  was manually changed in this procedure (e.g. discrete state variables or steady state
  calculations).   }
tstat[1].value := BC;
tstat[2].value := BN;
tstat[3].value := Wc;
tstat[4].value := N;
tstat[5].value := Ws;
tstat[6].value := VC;
tstat[7].value := VN;
tstat[8].value := vCI;
tstat[9].value := vCCa;
tstat[10].value := vCW;
tstat[11].value := UCbar;
tstat[12].value := UNbar;
tstat[13].value := RCbar;
tstat[14].value := RNbar;
tstat[15].value := cumUC;
tstat[16].value := cumUN;
tstat[17].value := CumTR;
tstat[18].value := CumUW;
tstat[19].value := cumRO;
tstat[20].value := CumRC;
tstat[21].value := CumTC;
tstat[22].value := CumRCTC;
tstat[23].value := CumTN;

{  Put all process values into process variable array. The first numstate
  processes are the derivatives of the state variables (Calculated above).}
tproc[1].value := dBCdt;
tproc[2].value := dBNdt;
tproc[3].value := dWcdt;
tproc[4].value := dNdt;
tproc[5].value := dWsdt;
tproc[6].value := dVCdt;
tproc[7].value := dVNdt;
tproc[8].value := dvCIdt;
tproc[9].value := dvCCadt;
tproc[10].value := dvCWdt;
tproc[11].value := dUCbardt;
tproc[12].value := dUNbardt;
tproc[13].value := dRCbardt;
tproc[14].value := dRNbardt;
tproc[15].value := dcumUCdt;
tproc[16].value := dcumUNdt;
tproc[17].value := dCumTRdt;
tproc[18].value := dCumUWdt;
tproc[19].value := dcumROdt;
tproc[20].value := dCumRCdt;
tproc[21].value := dCumTCdt;
tproc[22].value := dCumRCTCdt;
tproc[23].value := dCumTNdt;

{ Now the remaining processes. Be sure to number the processes the same here as
  you did in the procedure counts above. }
tproc[ModelDef.numstate + 1].value := UCI;
tproc[ModelDef.numstate + 2].value := UCCa;
tproc[ModelDef.numstate + 3].value := PImax;
tproc[ModelDef.numstate + 4].value := PCmax;
tproc[ModelDef.numstate + 5].value := LT;
tproc[ModelDef.numstate + 6].value := UCw;
tproc[ModelDef.numstate + 7].value := UC;
tproc[ModelDef.numstate + 8].value := UN;
tproc[ModelDef.numstate + 9].value := UW;
tproc[ModelDef.numstate + 10].value := RC;
tproc[ModelDef.numstate + 11].value := TC;
tproc[ModelDef.numstate + 12].value := TN;
tproc[ModelDef.numstate + 13].value := TR;
tproc[ModelDef.numstate + 14].value := LN1;
tproc[ModelDef.numstate + 15].value := RO;
tproc[ModelDef.numstate + 16].value := PHI;
tproc[ModelDef.numstate + 17].value := psiC;
tproc[ModelDef.numstate + 18].value := psiN;
tproc[ModelDef.numstate + 19].value := Psis;
tproc[ModelDef.numstate + 20].value := PsiL;
tproc[ModelDef.numstate + 21].value := S;
tproc[ModelDef.numstate + 22].value := THETA;
tproc[ModelDef.numstate + 23].value := beta;
tproc[ModelDef.numstate + 24].value := ymax;
tproc[ModelDef.numstate + 25].value := yCI;
tproc[ModelDef.numstate + 26].value := yCCa;
tproc[ModelDef.numstate + 27].value := yCW;
tproc[ModelDef.numstate + 28].value := Calib;

end;  // End of processes procedure


       { Do not make any modifications to code below this line. }
{****************************************************************************}


{This function counts the parameters in all processes less than processnum.}
function ParCount(processnum:integer) : integer;
var
 NumberofParams, counter : integer;
begin
  NumberofParams := 0;
  for counter := ModelDef.numstate + 1 to processnum - 1 do
         NumberofParams := NumberofParams + proc[counter].parameters;
  ParCount := NumberofParams;
end; // end of parcount function

{ This procedure supplies the derivatives of the state variables to the
  integrator. Since the integrator deals only with the values of the variables
  and not there names, units or the state field HoldConstant, this procedure
  copies the state values into a temporary state array and copies the value of
  HoldConstant into the temporary state array and passes this temporary state
  array to the procedure processes. }
PROCEDURE derivs(t, drt:double; var tdrive:drivearray; var tpar:paramarray;
             var statevalue:yValueArray; VAR dydt:yValueArray);
var
   i:integer;
   tempproc:processarray;
   tempstate:statearray;
begin
   tempstate := stat;  // Copy names, units and HoldConstant to tempstate
  // Copy current values of state variables into tempstate
   for i := 1 to ModelDef.numstate do tempstate[i].value := statevalue[i];
  // Calculate the process values
   processes(t, drt, tdrive, tpar, tempstate, tempproc, false);
  // Put process values into dydt array to get passed back to the integrator.
   for i:= 1 to ModelDef.numstate do dydt[i]:=tempproc[i].value;
end;  // end of derivs procedure

end.
