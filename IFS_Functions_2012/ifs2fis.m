function fis = ifs2fis(fis,defrule_weight)
%IFS2FIS   Transform from interpretable fuzzy format to FIS Toolbox format
%
%   fis = ifs2fis(fis)
%
%   Input FIS = Interpretable fuzzy inference system IFS structure (as used by ifseval)
%   Output FIS = Fuzzy inference system in the Fuzzy Toolbox format (as used by evalfis)
%
%   See also:
%       fis2ifs, ifseval, fuzzy (toolbox)

%   Carlos-Andres Pena-Reyes, 10-11-2000
%   Logic Systems Laboratory
%   Swiss Federal Institute of Technology at Lausanne
%   E-mail: carlos.pena@epfl.ch


if (nargin < 1)
   error('Need at least one argument');
elseif (nargin~=2)
   defrule_weight=0.1;
end


fis.type='sugeno';	
% it will be extended when the IFS toolbox support mamdani- and sugeno-type systems

in_n = length(fis.input);
out_n = length(fis.output);

% Input membership functions
for in=1:in_n,
   input=fis.input(in);
   
   %Initial trapezoid membership function
   fis.input(in).mf(1).type='trapmf';
   fis.input(in).mf(1).params=[input.range(1) input.range(1) input.mf_params(1:2)];
   if isfield(input,'mf_names'),
      fis.input(in).mf(1).name=input.mf_names(1,:);
   else
      fis.input(in).mf(1).name=['in',num2str(in),'mf1'];
   end
   
   
   % Internal membership functions
   if strcmp(input.mf_type,'trimf'),
      nmf=length(input.mf_params);
      step=1;
   elseif strcmp(input.mf_type,'trapmf'),
      nmf=(length(input.mf_params)+2)/2;
      step=2;
   else
      error('Unsupported membership function type');
   end
   for im=1:nmf-2,
      fis.input(in).mf(im+1).type=input.mf_type;
      fis.input(in).mf(im+1).params=input.mf_params(1+step*(im-1):2+step*im);
      if isfield(input,'mf_names'),
         fis.input(in).mf(im+1).name=input.mf_names(im+1,:);
      else
         fis.input(in).mf(im+1).name=['in',num2str(in),'mf',num2str(im+1)];
      end
   end
   
   % Final trapezoid
   fis.input(in).mf(nmf).type='trapmf';
   fis.input(in).mf(nmf).params=[input.mf_params(end-1:end) input.range(2) input.range(2)];
   if isfield(input,'mf_names'),
      fis.input(in).mf(nmf).name=input.mf_names(nmf,:);
   else
      fis.input(in).mf(nmf).name=['in',num2str(in),'nmf'];
   end
   

end


% Output membership functions (Only singleton consequents are currently supported)
for out=1:out_n,
   output=fis.output(out);
   for im=1:length(output.mf_params),
      fis.output(out).mf(im).type='constant';
      
      fis.output(out).mf(im).params=output.mf_params(im);
      if isfield(input,'mf_names'),
         fis.output(out).mf(im).name=output.mf_names(im,:);
      else
         fis.output(out).mf(im).name=['out',num2str(out),'mf',num2str(im)];
      end
   end
end

if isfield(input,'mf_names'),
   fis.input=rmfield(fis.input,strvcat('mf_type','mf_names','mf_params'));
   fis.output=rmfield(fis.output,strvcat('mf_type','mf_names','mf_params'));
else
   fis.input=rmfield(fis.input,strvcat('mf_type','mf_params'));
   fis.output=rmfield(fis.output,strvcat('mf_type','mf_params'));
end


% Add the default rule to the rule base
% Given that Fuzzy Toolbox does not support default rule, it is approximated using a 
% variable called 'defrulevar' with an "alwaystrue' membership function. This variable
% is assigned a weight of 'defrule_weight' (whose default value is 0.1)
if isfield(fis, 'defrule')
   if not(isempty(fis.defrule)),
      fis=addinvar(fis,'defrulevar',[0 1]);
      fis=addmf(fis,'input',in_n+1,'alwaystrue','trapmf',[0 0 1 1]);
      rule=[zeros(1,in_n) 1]; 					% Default rule: antecedents
      rule=[rule fis.defrule.consequent;];	% Default rule: consequents
      rule=[rule defrule_weight 1];				% Default rule weight and AND connection
      fis=addrule(fis,rule);
   end
end

function out=addinvar(fis,varName,varRange)
%   Purpose
%   Add an input variable to an FIS. (Adapted from MathWorks' addvar)
out=fis;
    index=length(fis.input)+1;
    out.input(index).name=varName;
    out.input(index).range=varRange;
%    out.input(index).numMFs=0;
    out.input(index).mf=[];
    % Need to insert a new column into the current rule list
    numRules=length(fis.rule);
    if numRules,
        % Don't bother if there aren't any rules
      
        for i=1:numRules
         out.rule(i).antecedent(index)=0;
        end
    end

