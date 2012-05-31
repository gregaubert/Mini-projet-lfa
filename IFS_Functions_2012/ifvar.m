function [y, nmf] = ifvar(x, type, params)
%IFVAR Modified trapezoidal membership function.
%
%   Y = IFVAR(X, TYPE, PARAMS) returns the degree of membership of X to the set
%   of membership functions defined by PARAMS.
%
%   TYPE = 'trimf' or 'trapmf'
%
%   PARAMS = [P1 P2 ... Pm] is a m-element vector that defines a set
%   of n orthogonal membership functions 
%   (m=n for trimf-type, and m=2*(n-1) for trapmf-type)
%
%
%   It is required that P1 <= P2 <= .... <= Pn' <= Pm.
%
%   Y is a n-element vector containing the membership values of X to the 
%   n membership functions.
%
%   Note: a non-numeric value (NaN) of X returns a non-numeric value of Y.
%   This is intended to deal with incomplete input sets
%
%   For example:
%
%       x = [(0:0.1:10)'; NaN];
%       y = ifvar(x, 'trimf' [2 3 7 9]);
%

%   Carlos-Andres Pena-Reyes, 2-3-99
%   Logic System Laboratory
%   Swiss Federal Institute of Technology at Lausanne
%   E-mail: carlos.pena@epfl.ch



if nargin ~= 3
    error('Three arguments are required by the fuzzifier function');
elseif length(params) < 2
    error('The fuzzyfier function needs at least two parameters.');
end

%if any(params(1:end-1)-params(2:end)>0),
%   error('Parameters must be in ascending order');
%end

npar=length(params);
   
x = x(:);

% Initialize membership values matrix
%y = zeros(length(x),nmf);

% First membership function
y(x <= params(1),1) = 1;

% Trapezoidal orthogonal membership functions
if strcmp(type,'trapmf'),
   nmf = (npar+2)/2;
   for imf = 2:nmf-1,
      ixinf=2*imf-3;ixsup=ixinf+1;
      index = find(params(ixinf) < x & x <= params(ixsup));
      if ~isempty(index),
         % right side of the (imf-1)-th membership function...
         y(index, imf-1) =  (params(ixsup) - x(index))/(params(ixsup)-params(ixinf));
         % left slope of the i-th membership function (orthogonality)
         y(index, imf) = 1 - y(index, imf-1);
      end
      % flat unitary section of the i-th membership function
      y((params(ixsup) < x & x <= params(ixsup+1)),imf)=1;
   end
else	% Triangular orthogonal membership functions
   nmf=npar;
   for imf = 2:nmf-1,
      index = find(params(imf-1) < x & x <= params(imf));
      if ~isempty(index),
         % right side of the (imf-1)-th membership function...
         y(index, imf-1) =  (params(imf) - x(index))/(params(imf)-params(imf-1));
         % left slope of the i-th membership function (orthogonality)
         y(index, imf) = 1 - y(index, imf-1);
      end
   end
end


% Last (trapezoidal) membership function
index = find(params(npar-1) < x & x <= params(npar));
if ~isempty(index),
   % right side of the (imf-1)-th membership function...
   y(index, nmf-1) =  (params(npar) - x(index))/(params(npar)-params(npar-1));
   % left slope of the i-th membership function (orthogonality)
   y(index, nmf) = 1 - y(index, nmf-1);
end
y(params(npar)<x, nmf) = 1;

% Compute non-numeric memberships
y(isnan(x),:)=0;
