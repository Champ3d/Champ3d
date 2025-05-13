function ltensor_array = f_evalltensor(c3dobj,varargin)
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
arglist = {'phydomobj','ltensor'};

% --- default input value
phydomobj = [];
ltensor = [];

% --- default output value
ltensor_array = [];

% --- valid depend_on
valid_ltensor = {'main_value','ort1_value','ort2_value',...
                 'main_dir','ort1_dir','ort2_dir'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
phydomobj = f_get_id(c3dobj,phydomobj);
id_elem   = phydomobj.id_elem;
nb_elem   = length(id_elem);
%--------------------------------------------------------------------------
ltfield__ = fieldnames(ltensor);
%--------------------------------------------------------------------------
for iltf = 1:length(ltfield__)
    %----------------------------------------------------------------------
    ltfield = ltensor.(ltfield__{iltf});
    paramtype = f_paramtype(ltfield);
    %----------------------------------------------------------------------
    if any(strcmpi(paramtype,{'c3d_parameter_function'}))
        param = f_evalisofun(c3dobj,'phydomobj',phydomobj,'iso_function',ltfield);
        %------------------------------------------------------------------
        % --- Output
        ltensor_array.(ltfield__{iltf}) = param;
        %------------------------------------------------------------------
    elseif any(strcmpi(paramtype,{'numeric'}))
        ltensor_array.(ltfield__{iltf}) = repmat(ltfield,nb_elem,1);
    else
        f_display(ltfield);
        error([mfilename ' : cannot evaluate ltensor field !']);
    end
end
%--------------------------------------------------------------------------
if isempty(ltensor_array)
    f_display(ltensor);
    error([mfilename ' : cannot evaluate ltensor !']);
end

