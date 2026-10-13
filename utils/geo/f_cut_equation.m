function cut_equation = f_cut_equation(cut_equation,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'tol'};

% --- default input value
tol = 1e-12; % tolerance

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if iscell(cut_equation)
    cut_equation = cut_equation{1};
end
%--------------------------------------------------------------------------
original = cut_equation;
%--------------------------------------------------------------------------
cut_equation(isspace(cut_equation)) = [];
cut_equation = strrep(cut_equation,'&&','&');
cut_equation = strrep(cut_equation,'||','|');
cut_equation = strrep(cut_equation,'==','=');
cut_equation = strrep(cut_equation,'=','==');
cut_equation = strrep(cut_equation,'>==','>=');
cut_equation = strrep(cut_equation,'<==','<=');
cut_equation = strrep(cut_equation,'max(x)','max(max(x))');
cut_equation = strrep(cut_equation,'max(y)','max(max(y))');
cut_equation = strrep(cut_equation,'max(z)','max(max(z))');
cut_equation = strrep(cut_equation,'min(x)','min(min(x))');
cut_equation = strrep(cut_equation,'min(y)','min(min(y))');
cut_equation = strrep(cut_equation,'min(z)','min(min(z))');
%--------------------------------------------------------------------------
if ~contains(cut_equation,'&')
    cut_equation = [cut_equation '&1'];
end
%--------------------------------------------------------------------------
iCond  = strfind(cut_equation,'&');
nbCond = length(iCond) + 1;
j = 0; k = 0; neqcond = '1'; eqcond = [];
for i = 1:nbCond
    %----------------------------------------------------------------------
    if i == 1
        cond = cut_equation(1:iCond(i)-1);
    elseif i == nbCond
        cond = cut_equation(iCond(i-1)+1:end);
    else
        cond = cut_equation(iCond(i-1)+1:iCond(i)-1);
    end
    %----------------------------------------------------------------------
    if contains(cond,'>') || contains(cond,'<')
        j = j + 1;
        neqcond = [neqcond ' & ' cond];
    elseif contains(cond,'==')
        k = k + 1;
        eqcond{k} = cond;
    end
end
%--------------------------------------------------------------------------
% output 2
cut_equation = [];
cut_equation.original = original;
cut_equation.tol = tol;
cut_equation.neqcond = neqcond;
cut_equation.eqcond  = eqcond;



