function [output, rulactiv] = ifseval(invalue, ifs)
%IFSEVAL   Perform fuzzy inferences using an interpretability-constrained system (IFS)
%
%   [output, rulactiv] = ifseval(invalue, ifs)
%
%   INVALUE = vector of input values (or matrix of input vectors).
%   IFS   = Interpretable Fuzzy System (IFS) structure which has the following fields:
%   	ifs.name
%   	ifs.type
%   	ifs.andMethod
%   	ifs.orMethod
%   	ifs.defuzzMethod
%   	ifs.impMethod
%   	ifs.aggMethod
%   	ifs.input
%   	ifs.output
%   	ifs.rule
%		ifs.defrule
%
%   - ifs.input and ifs.output have 5 subfields: 
%         name, range, mf_names, mf_type, and mf_params
%   - ifs.rule has 4 subfields:
%         antecedent, consequent, weight, and connection
%
%	 OUTVALUE = vector of output values (or matrix of input vectors).
%	 RULACTIV = vector of rule activations (or matrix of rule-activation vectors)
%
%   See also:
%       ifvar

%   Carlos-Andres Pena-Reyes, 10-11-2000
%   Logic System Laboratory
%   Swiss Federal Institute of Technology at Lausanne
%   E-mail: carlos.pena@epfl.ch


if (nargin ~= 2)
    error('Bad numer of arguments, see >>help fuzzycap');
end

nx = size(invalue,1);			% number of input cases
nv = size(ifs.input,2);		% number of input variables
nr = size(ifs.rule,2);			% number of rules
no = size(ifs.output,2);		% number of output variables

antactiv=ones(nx,nr,nv);		% Antecedent activations
rulactiv = ones(nx, nr);		% Rule activations
rules_antec=zeros(nv,nr); 		% Rule base antecedents
rules_antec(:)=[ifs.rule.antecedent];
rules_consec=zeros(no,nr); 		% Rule base consequents
rules_consec(:)=[ifs.rule.consequent];

for iv = 1:nv,
   % Compute the memberships of the variable (Fuzzification)
   [pert, nmf] = ifvar( invalue(:,iv), ifs.input(iv).mf_type, ifs.input(iv).mf_params );
   
   % Compute the rule activation (inference)
   rulinvar = rules_antec(iv,:);
   
   % Normal antecedents
   index = find( 1 <= rulinvar & rulinvar <= nmf );
   if ~isempty(index),
		antactiv(:,index, iv) = pert(:,rulinvar(index));
	end
 
   % Antecedents with a NOT condition
   index = find( -1 >= rulinvar & rulinvar >= -nmf );
   if ~isempty(index),
		antactiv(:,index, iv) = 1 - pert(:,-rulinvar(index));
	end
   
end

% Compute the activation of the rules
% By default, all rules are and-connected
rulactiv=min(antactiv,[],3);
% Compute activation of or-connected rules
index = find([ifs.rule.connection]==2);
rulactiv(:,index)=max(antactiv(:,index,:),[],3);

% Add the default rule to the rule base
if isfield(ifs, 'defrule')
   if not(isempty(ifs.defrule)),
      rulactiv(:,end+1) = zeros(size(rulactiv,1),1);
      rulactiv(:,end) = 1 - max(rulactiv')';
      rules_consec(:,end+1) = ifs.defrule.consequent';
   end
end
   
% Output defuzzification (singleton-type mfs)
output = zeros(nx, no);
for ov = 1:no,
   ruloutvar = rules_consec(ov,:);
   
   % Only assigned consequents
   index = find( 1 <= ruloutvar & ruloutvar <= length(ifs.output(ov).mf_params) );
   if sum(rulactiv(:,index))==0,
       rulactiv(end,index)=1;
   end
   % Weighted sum defuzzification
   output(:,ov) = (rulactiv(:,index) * ifs.output(ov).mf_params(ruloutvar(index))'	 ) ...
       ./ sum(rulactiv(:,index)')';
end

