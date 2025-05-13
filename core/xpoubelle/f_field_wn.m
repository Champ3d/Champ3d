function field_wn = f_field_wn(val_on_n,mesh,varargin)
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
arglist = {'id_elem','coefficient','options'};

% --- default input value
id_elem = [];
coefficient = [];
options = 'on_center'; % 'on_center', 'on_gauss_points'

% --- default output value
field_wn = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
nb_elem = size(mesh.elem,2);
if isempty(id_elem)
    id_elem = 1:nb_elem;
end
%--------------------------------------------------------------------------
if isempty(coefficient)
    coef_array = 1;
    coef_array_type = 'iso_array';
else
    [coef_array, coef_array_type] = f_tensor_array(coefficient);
end
%--------------------------------------------------------------------------
if ~any(strcmpi(coef_array_type,{'iso_array'}))
    error([mfilename ': #coefficient ' coefficient ' must be scalar !']);
end
%--------------------------------------------------------------------------
if isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
else
    elem_type = f_elemtype(mesh.elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbG = con.nbG;
nbNo_inEl = con.nbNo_inEl;
%--------------------------------------------------------------------------
if any(strcmpi(options,{'on_center'}))
    Wn = mesh.intkit.cWn{1}(id_elem,:);
    fi = zeros(length(id_elem),1);
    for i = 1:nbNo_inEl
        wni = Wn(:,i);
        fi = fi + coef_array .* wni .* val_on_n(id_elem);
    end
    % ---
    field_wn = sparse(id_elem,1,fi,nb_elem,1);
    % ---
elseif any(strcmpi(options,{'on_gauss_points'}))
    Wn = cell(1,8);
    for iG = 1:nbG
        Wn{iG} = mesh.intkit.Wn{iG}(id_elem,:);
    end
    fi = zeros(length(id_elem),nbG);
    for iG = 1:nbG
        for i = 1:nbNo_inEl
            wni = Wn{iG}(:,i);
            fi(:,iG) = fi(:,iG) + coef_array .* wni .* val_on_n(id_elem);
        end
    end
    % ---
    field_wn = sparse(id_elem,1:nbG,fi,nb_elem,nbG);
end
%--------------------------------------------------------------------------

