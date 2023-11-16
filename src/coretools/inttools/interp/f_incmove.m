function [fieldOut, node, id_node] = f_incmove(fieldIn,node,varargin)
% F_INCREMENTALMOVE returns ... related to an incremental move in x, y or z
% direction.
% field : [1 x nbElem]
% node  : [3 x nbElem]
% 'direction' : 'x', 'y' or 'z'
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
arglist = {'id_node','direction','nb_step','cyclic_move'};

% --- default input value
id_node = [];
direction = [];
nb_step = 1;
cyclic_move = 0;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_node)
    id_node = 1:length(fieldIn);
end
%--------------------------------------------------------------------------
if strcmpi(direction,'x')
    [node, id] = f_multisort(node,'sort_order',[1 2 3]);
    cmov       = node(1,:);
    id_node    = id_node(id);
    fieldOut   = fieldIn(id);
elseif strcmpi(direction,'y')
    [node, id] = f_multisort(node,'sort_order',[2 1 3]);
    cmov       = node(2,:);
    id_node    = id_node(id);
    fieldOut   = fieldIn(id);
elseif strcmpi(direction,'z')
    [node, id] = f_multisort(node,'sort_order',[3 1 2]);
    cmov       = node(3,:);
    id_node    = id_node(id);
    fieldOut   = fieldIn(id);
end
%--------------------------------------------------------------------------
dcz = [1  find(diff(cmov))+1];
%--------------------------------------------------------------------------
nb_cmov = length(dcz);
for i = 1 : nb_cmov
    if i <= nb_cmov - 1
        iP{i} = dcz(i) : dcz(i+1)-1; % all have same cmov
        f{i}  = fieldOut(iP{i});
    else
        iP{i} = dcz(i) : length(cmov); % all have same cmov
        f{i}  = fieldOut(iP{i});
    end
end
%--------------------------------------------------------------------------
if ~cyclic_move
    i0 = (1:nb_cmov).';
    imov = circshift(i0,nb_step);
    if abs(nb_step) >= nb_cmov
        for i = 1 : nb_cmov
                fieldOut(iP{i}) = 0;
        end
    else
        for i = 1 : nb_cmov
            if nb_step > 0
                if i >= nb_step + 1
                    fieldOut(iP{i}) = f{imov(i)};
                else
                    fieldOut(iP{i}) = 0;
                end
            elseif nb_step < 0
                if i <= nb_cmov - abs(nb_step)
                    fieldOut(iP{i}) = f{imov(i)};
                else
                    fieldOut(iP{i}) = 0;
                end
            end
        end
    end
else
    i0 = (1:nb_cmov).';
    imov = circshift(i0,nb_step);
    for i = 1 : nb_cmov
        fieldOut(iP{i}) = f{imov(i)};
    end
end
