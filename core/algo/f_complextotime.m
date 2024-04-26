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
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'cvalue','fr','form','time','a'};

% --- default input value
form  = 'cos';
fr    = 0;
time  = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(time) & fr == 0
    error([mfilename ' : frequency, time (or phase angle) must be given !']);
end

if isempty(time)
    time = 0;
end
%--------------------------------------------------------------------------
dim = min(size(cvalue,1),size(cvalue,2));
len = max(size(cvalue,1),size(cvalue,2));
rvalue = zeros(dim,len);
switch form
    case 'sin'
        for i = 1:dim
            rvalue(i,:) = abs(cvalue(i,:)) .* sin(2*pi*fr*time + angle(cvalue(i,:)));
        end
    case 'cos'
        for i = 1:dim
            rvalue(i,:) = abs(cvalue(i,:)) .* cos(2*pi*fr*time + angle(cvalue(i,:)));
        end
end
