function out=newifs(ifsName,varargin)
%NEWIFS Create new IFS.
%   IFS=NEWIFS(IFSNAME) creates a new Singleton-style IFS structure
%
%   IFS=NEWFIS(IFSNAME, INVAR, OUTVAR, NMF)
%   IFS=NEWFIS(IFSNAME, INVAR, OUTVAR, NMF, INVARTYPE)
%   creates a new sigleton-style IFS structure with name IFSNAME, 
%   INVAR inputs, OUTVAR outputs, and vector NMF defining the number
%   of membership functions. 
%   Optional parameter INVARTYPE defines the type of input membership functions
%
%   IFS=NEWFIS(IFSNAME, INSTRUCT, OUTSTRUCT) creates a new sigleton-style IFS structure
%   with name IFSNAME, and input and output structures INSTRUCT and OUTSTRUCT.
%
%   IFS=NEWIFS(IFSNAME, IFSTYPE) creates an IFS structure for a Singleton, Mamdani or 
%   Sugeno-style system with the name IFSNAME.
%   (Note: Still not supported)
%

%   Carlos-Andres Pena-Reyes, 13-11-2000
%   Logic Systems Laboratory
%   Swiss Federal Institute of Technology at Lausanne
%   E-mail: carlos.pena@epfl.ch

list=strvcat('ifsType','andMethod','orMethod',...
   'impMethod','aggMethod','defuzzMethod','invar','outvar','nmf','invartype');
if (nargin>=1), name=ifsName; end
ilist=1;
for iarg=1:nargin-1,
   argum=varargin{iarg};
   if not(isempty(argum)),
      if iarg==ilist & (isnumeric(argum) | isstruct(argum)),
         ilist=7;
      end
      command=[list(ilist,:),'= argum;'];
      eval(command);
   end
   ilist=ilist+1;
end

if not(exist('ifsType')), ifsType='singleton'; end
if not(exist('invartype')), invartype='trimf'; end

if strcmp(ifsType,'mamdani'),
    if not(exist('andMethod')), andMethod='min'; end
    if not(exist('orMethod')), orMethod='max'; end
    if not(exist('defuzzmethod')), defuzzMethod='centroid'; end
    outvartype='trimf';
end

if not(exist('impMethod')), impMethod='min'; end
if not(exist('aggMethod')), aggMethod='max'; end

if strcmp(ifsType,'sugeno'),
    if not(exist('andMethod')), andMethod='prod'; end
    if not(exist('orMethod')), orMethod='probor'; end
    if not(exist('defuzzmethod')), defuzzMethod='wtaver'; end
    outvartype='linear';
end

if strcmp(ifsType,'singleton'),
    if not(exist('andMethod')), andMethod='min'; end
    if not(exist('orMethod')), orMethod='max'; end
    if not(exist('defuzzmethod')), defuzzMethod='wtaver'; end
    outvartype='singleton';
end
 

out.name=name;
out.type=ifsType;
out.andMethod=andMethod;
out.orMethod=orMethod;
out.defuzzMethod=defuzzMethod;
out.impMethod=impMethod;
out.aggMethod=aggMethod;

if not(exist('invar')), 
   out.input=[]; 
elseif isstruct(invar),
   out.input=invar;
else
   for i=1:invar,
      out.input(i).name=['invar',int2str(i)];
      out.input(i).range=[0,1];
      out.input(i).mf_type=invartype;
      if exist('nmf'), mf=nmf(i); else mf=3; end
      if strcmp(invartype,'trapmf'), inpars=2*(mf-1); else inpars=mf; end
      params=linspace(0, 1, inpars+2);
      out.input(i).mf_params=params(2:end-1);
   end
end

if not(exist('outvar')), 
   out.output=[]; 
elseif isstruct(outvar),
   out.output=outvar;
else
   for i=1:outvar,
      out.output(i).name=['outvar',int2str(i)];
      out.output(i).range=[0,1];
      out.output(i).mf_type=outvartype;
      if exist('nmf'), mf=nmf(invar+i); else mf=3; end
      params=linspace(0, 1, mf);
      out.output(i).mf_params=params;
   end
end


out.rule=[];

