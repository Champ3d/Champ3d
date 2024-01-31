function c3dobj = f_add_geo1d(c3dobj,varargin)
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
arglist = {'geo1d_axis','id_mesh1d','id_x','id_y','id_layer','d','dtype','dnum','flog'};

% --- default input value
id_mesh1d = [];
geo1d_axis = 'x'; % or 'y', 'layer'
d = 0;
dtype = 'lin';
dnum = '1';
id_x = [];
id_y = [];
id_layer = [];
flog = 1.05;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_x) && isempty(id_y) && isempty(id_layer)
    error([mfilename ' : #id must be given !']);
end
%--------------------------------------------------------------------------
if isempty(id_mesh1d)
    id_mesh1d = 'mesh1d_01';
end
%--------------------------------------------------------------------------
if ~isempty(id_x)
    id = id_x;
elseif ~isempty(id_y)
    id = id_y;
elseif ~isempty(id_layer)
    id = id_layer;
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.mesh1d.(id_mesh1d).(geo1d_axis).(id).d = d;
c3dobj.mesh1d.(id_mesh1d).(geo1d_axis).(id).dtype = dtype;
c3dobj.mesh1d.(id_mesh1d).(geo1d_axis).(id).dnum = dnum;
c3dobj.mesh1d.(id_mesh1d).(geo1d_axis).(id).flog = flog;
% --- Log message
% fprintf(['Add ' geo1d_axis '-1d : #' id '\n']);





