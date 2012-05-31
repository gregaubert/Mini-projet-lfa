function fis = fis2ifs(fis)
%FIS2IFS   Transform from FIS Toolbox systems to interpretable fuzzy systems
%
%   fis = fis2ifs(fis)
%
%   FIS = Fuzzy inference system in the Fuzzy Toolbox form
%
%   IFS = Interpretable fuzzy system   
%
%   See also:
%       ifseval

%   Carlos-Andres Pena-Reyes, 4-11-2000
%   Logic Systems Laboratory
%   Swiss Federal Institute of Technology at Lausanne
%   E-mail: carlos.pena@epfl.ch


if (nargin < 1)
    error('Need a FIS structure as an input argument');
end

% Conversion of Mamdani-type system to Sugeno-type.
% It will be changed when ifseval support mamdani-type systems
if strcmp(fis.type, 'mamdani'),
   fis = mam2sug(fis);
end

fis.type='singleton';	%it will be changed when ifseval support sugeno-type systems

in_n = length(fis.input);
out_n = length(fis.output);
rule_n = length(fis.rule);

% Extract and remove default rule: variable and rule
% Given that Fuzzy Toolbox does not support default rule, it is approximated using a 
% variable called 'defrulevar' with an "alwaystrue' membership function.
defrulevarindex = find(strcmp({fis.input.name},'defrulevar'));
if not(isempty(defrulevarindex)),
   % remove the default-rule variable from all rules
   for i=1:rule_n,
        fis.rule(i).antecedent(defrulevarindex)=[];
   end
   fis.input(defrulevarindex)=[];
   %search for rules with no antecedent
   for i=rule_n:-1:1,
      if isempty(find(fis.rule(i).antecedent~=0))
         fis.defrule.consequent=fis.rule(i).consequent;
         fis.rule(i)=[];
      end
   end
   in_n = in_n-1;
end
   
for in=1:in_n,
   input=fis.input(in);
   fis.input(in).mf_names=strvcat({input.mf.name}');		% MF names
   if all(strcmp({input.mf(2:end-1).type},'trimf')),
      fis.input(in).mf_type='trimf';							% MF type is triangular
      														% MF parameters
      % Compute triangles and trapezoids for interpretable variables
      % Inicial trapezoid                                          
      if strcmp({input.mf(1).type},'trapmf'),
         fis_params=[0 input.mf(1).params(3:4)];
      else
         pars=mf2mf(input.mf(1).params,input.mf(1).type,'trapmf');
         fis_params=[0 pars(3:4)];
      end
      % Inner triangles
      fis_params=[fis_params; cell2mat({input.mf(2:end-1).params}')];
      % Final trapezoid
      if strcmp({input.mf(end).type},'trapmf'),
         fis_params=[fis_params;[input.mf(end).params(1:2) 0]];
      else
         pars=mf2mf(input.mf(end).params,input.mf(end).type,'trapmf');
         fis_params=[fis_params; [pars(1:2) 0]];
      end
      % Parameter conversion to interpretable-variable format
      fis_params(:,1)=[fis_params(2:end,1);fis_params(end-1,3)];
      fis_params(:,4)=[fis_params(1,1);fis_params(1:end-1,3)];
      fis_params(:,3)=fis_params(:,2);
      fis.input(in).mf_params=mean(fis_params');
   else
      fis.input(in).mf_type='trapmf';							% MF type is trapezoidal
      % 													  MF parameters
      nmf=length(input.mf);
      fis_par=zeros(2,2*nmf+2);
      for im=2:2:2*nmf,
         mf=input.mf(im/2);
         if strcmp({mf.type},'trapmf'),
            pars=mf.params;
         else
            pars=mf2mf(mf.params,mf.type,'trapmf');
         end
         fis_par(1,im-1:im)=pars(1:2);
         fis_par(2,im+1:im+2)=pars(3:4);
      end
      fis.input(in).mf_params=sum(fis_par(:,3:end-2))/2;
   end
end
fis.input=rmfield(fis.input,'mf');


for out=1:out_n,
   output=fis.output(out);
   fis.output.mf_names=strvcat({output.mf.name}');		% MF names
   fis.output.mf_type='singleton';							% MF type
   % It will change when ifseval supports mamdani- and sugeno-type systems
   fis_params=cell2mat({output.mf.params}');
   fis.output.mf_params=fis_params(:,end)';				% MF parameters
end
fis.output=rmfield(fis.output,'mf');
