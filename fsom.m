function [output] = fsom(dataset)

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

