function rvalue = f_complextotime(cvalue,varargin)
% F_COMPLEXTOTIME compute from complex value the real value at given time.
%--------------------------------------------------------------------------
% FIXED INPUT
% cvalue : complex value array
%   o [1 x nb_values]  -> ex : x-component of B-field
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'fr' : frequency
% 'form' :
%   o 'sin'  
%   o 'cos'  -> by default
% 'time' : time instant to compute real value
% 'a' : phase angle, ie. angle = 90 <-> t = T/2
%--------------------------------------------------------------------------
% OUTPUT
% rvalue : real value array at the given time
%   o [1 x nb_values]
%--------------------------------------------------------------------------
% EXAMPLE
% rvalue = f_complextotime(cvalue,'fr',50,'time',0);
% rvalue = f_complextotime(cvalue,'fr',50,'angle',90);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'cvalue','fr','form','time','a'};

% --- default input value
form  = 'cos';
fr    = 0;
time  = [];
a     = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(time) & isempty(a) & fr == 0
    error([mfilename ' : frequency, time (or phase angle) must be given !']);
end

if isempty(time)
    time = a/360*1/fr;
end
%--------------------------------------------------------------------------
switch form
    case 'sin'
        rvalue = abs(cvalue) .* sin(2*pi*fr*time + angle(cvalue));
    case 'cos'
        rvalue = abs(cvalue) .* cos(2*pi*fr*time + angle(cvalue));
end