function ys = f_smoothing(y,varargin)
% F_SMOOTHING smooths y data by moving average of given order.
%--------------------------------------------------------------------------
% FIXED INPUT
% y : ordered array to be smoothed
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'order' : odd-value order of moving average
%   o by default : order = 7 or length of y
%--------------------------------------------------------------------------
% OUTPUT
% ys : smoothed y
%--------------------------------------------------------------------------
% EXAMPLE
% ys = f_smoothing(y,'order',5);
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
arglist = {'y','order'};

% --- default input value
order = 7;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

if mod(order,2) == 0, order = order + 1; end

%--------------------------------------------------------------------------
y    = f_torowv(y);
leny = length(y);
o    = min(order,leny);
if mod(o,2) == 0, o = o + 1; end
%--------------------------------------------------------------------------
yleft = zeros((o-1)/2,leny);
yrigh = zeros((o-1)/2,leny);

% --- version 1
for i = 1 : (o-1)/2
    yleft(i,:) = [y(i+1:leny) y(leny-i+1:leny)];
    yrigh(i,:) = [y(1:i) y(1:leny-i)];
end
% --- version 2
% for i = 1 : (o-1)/2
%     yleft(i,:) = [y(i+1:leny) y(leny:-1:leny-i+1)];
%     yrigh(i,:) = [y(i:-1:1) y(1:leny-i)];
% end
%--------------------------------------------------------------------------
ys = mean([yleft; y; yrigh]);








