function f_femm_set_block(draw2d,varargin)

%--------------------------------------------------------------------------
% 'draw2d' : draw2d data structure
% 'id_draw2d' : id of the draw to be put into the block
% 'method' : method to define the block
%     + 'center', 'c'
%     + 'bottomleft', 'bl'
%     + 'bottomright', 'br'
%     + 'upperleft', 'ul'
%     + 'upperright', 'ur'
% 'block_name' : name of the block
% 'in_circuit' : name of the circuit to put it in
% 'nb_turns'  : number of turns (for incircuit block)
% 'set_pm_direction' : set permanent magnet direction
%     + +1 --> same as draw2d.c_angle
%     + -1 --> opposite to draw2d.c_angle
%     +  0 --> no set
% 'meshsize'  : meshsize (see FEMM)
%--------------------------------------------------------------------------
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
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
arglist = {'draw2d','id_draw2d','method','block_name','in_circuit',...
           'nb_turns','set_pm_direction','pm_direction','meshsize'};

% --- default input value
method     = 'center';
block_name  = [];
in_circuit = 0;
nb_turns   = 0;
set_pm_direction = 0;
group = 0;
meshsize = 0;
pm_direction = 0; % degree
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};'])
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
for i2d = 1:length(draw2d)
    if strcmpi(draw2d(i2d).id_draw2d,id_draw2d)
        id = i2d;
    end
end
% -------------------------------------------------------------------------
if isempty(block_name) || strcmpi(block_name,'nomesh') || strcmpi(block_name,'no mesh')
    block_name = '<No Mesh>';
end
% -------------------------------------------------------------------------

switch lower(method)
    case {'center','c'}
        %------------------------------------------------------------------
        px = draw2d(id).center(1);
        py = draw2d(id).center(2);
        %------------------------------------------------------------------
    case {'bottomleft','bl'}
        %------------------------------------------------------------------
        px = draw2d(id).bottomleft(1);
        py = draw2d(id).bottomleft(2);
        %------------------------------------------------------------------
    case {'bottomright','br'}
        %------------------------------------------------------------------
        px = draw2d(id).bottomright(1);
        py = draw2d(id).bottomright(2);
        %------------------------------------------------------------------
    case {'upperleft','ul'}
        %------------------------------------------------------------------
        px = draw2d(id).upperleft(1);
        py = draw2d(id).upperleft(2);
        %------------------------------------------------------------------
    case {'upperright','ur'}
        %------------------------------------------------------------------
        px = draw2d(id).upperright(1);
        py = draw2d(id).upperright(2);
        %------------------------------------------------------------------
    case {'bottom','b'}
        %------------------------------------------------------------------
        px = draw2d(id).bottom(1);
        py = draw2d(id).bottom(2);
        %------------------------------------------------------------------
    case {'upper','u'}
        %------------------------------------------------------------------
        px = draw2d(id).upper(1);
        py = draw2d(id).upper(2);
        %------------------------------------------------------------------
    case {'right','r'}
        %------------------------------------------------------------------
        px = draw2d(id).right(1);
        py = draw2d(id).right(2);
        %------------------------------------------------------------------
    case {'left','l'}
        %------------------------------------------------------------------
        px = draw2d(id).left(1);
        py = draw2d(id).left(2);
        %------------------------------------------------------------------
end
%--------------------------------------------------------------------------
if set_pm_direction == +1
    pm_direction = draw2d(id).c_angle;
elseif set_pm_direction == +1/2
    pm_direction = draw2d(id).c_angle + 90;
elseif set_pm_direction == -1/2
    pm_direction = draw2d(id).c_angle - 90;
elseif set_pm_direction == -1
    pm_direction = draw2d(id).c_angle + 180;
end
%--------------------------------------------------------------------------
mi_addblocklabel(px,py);
mi_selectlabel(px,py);
%--------------------------------------------------------------------------
mi_setblockprop(block_name,0,meshsize,in_circuit,pm_direction,group,nb_turns);
%--------------------------------------------------------------------------
mi_clearselected;








