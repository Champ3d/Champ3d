function field_we = f_field_we(val_on_e,mesh,varargin)
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
arglist = {'id_elem','coefficient','options'};

% --- default input value
id_elem = [];
coefficient = [];
options = 'on_center'; % 'on_center', 'on_gauss_points'

% --- default output value
field_we = [];

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
if isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
else
    elem_type = f_elemtype(mesh.elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbG = con.nbG;
nbEd_inEl = con.nbEd_inEl;
%--------------------------------------------------------------------------
if ~isfield(mesh,'id_edge_in_elem')
    mesh = f_meshds(mesh,'get','id_edge_in_elem');
end
id_edge_in_elem = mesh.id_edge_in_elem;
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    if any(strcmpi(options,{'on_center'}))
        %------------------------------------------------------------------
        Wx = mesh.intkit.cWe{1}(id_elem,:,:);
        fi = zeros(length(id_elem),3);
        %------------------------------------------------------------------
        for i = 1:nbEd_inEl
            wix = Wx(:,1,i);
            wiy = Wx(:,2,i);
            wiz = Wx(:,3,i);
            id_edge = id_edge_in_elem(i,:);
            fi(:,1) = fi(:,1) + coef_array .* wix .* val_on_e(id_edge);
            fi(:,2) = fi(:,2) + coef_array .* wiy .* val_on_e(id_edge);
            fi(:,3) = fi(:,3) + coef_array .* wiz .* val_on_e(id_edge);
        end
        %------------------------------------------------------------------
        %field_wf = sparse(id_elem,1:3,fi,nb_elem,3);
        field_we = sparse(3,nb_elem);
        field_we(1:3,id_elem) = fi.';
    %----------------------------------------------------------------------
    elseif any(strcmpi(options,{'on_gauss_points'}))
        % --- TODO
    end
    %----------------------------------------------------------------------
elseif any(strcmpi(coef_array_type,{'tensor_array'}))
    %----------------------------------------------------------------------
    if any(strcmpi(options,{'on_center'}))
        %------------------------------------------------------------------
        id_edge_in_elem = mesh.id_edge_in_elem;
        Wx = mesh.intkit.cWe{1}(id_elem,:);
        fi = zeros(3,length(id_elem));
        %------------------------------------------------------------------
        for i = 1:nbEd_inEl
            wix = Wx(:,1,i);
            wiy = Wx(:,2,i);
            wiz = Wx(:,3,i);
            id_edge = id_edge_in_elem(i,:);
            fi(1,:) = fi(1,:) + (coef_array(:,1,1) .* wix + ...
                                 coef_array(:,1,2) .* wiy + ...
                                 coef_array(:,1,3) .* wiz) .* val_on_e(id_edge) ;
            fi(2,:) = fi(2,:) + (coef_array(:,2,1) .* wix + ...
                                 coef_array(:,2,2) .* wiy + ...
                                 coef_array(:,2,3) .* wiz) .* val_on_e(id_edge) ;
            fi(3,:) = fi(3,:) + (coef_array(:,3,1) .* wix + ...
                                 coef_array(:,3,2) .* wiy + ...
                                 coef_array(:,3,3) .* wiz) .* val_on_e(id_edge) ;
        end
        %------------------------------------------------------------------
        field_we = sparse(1:3,id_elem,fi,3,nb_elem);
    %----------------------------------------------------------------------
    elseif any(strcmpi(options,{'on_gauss_points'}))
        % --- TODO
    end
    %----------------------------------------------------------------------
end