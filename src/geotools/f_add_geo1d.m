function geo = f_add_geo1d(geo,varargin)
% F_ADD_GEO1D ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'geo1d_axis','id_x','id_y','id_layer','d','dtype','dnum'};

% --- default input value
geo1d_axis = 'x'; % or 'y', 'layer'
d = 0;
dtype = 'lin';
dnum = '1';
id_x = [];
id_y = [];
id_layer = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_x) && isempty(id_y) && isempty(id_layer)
    error([mfilename ' : #id must be given !']);
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
geo.geo1d.(geo1d_axis).(id).d = d;
geo.geo1d.(geo1d_axis).(id).dtype = dtype;
geo.geo1d.(geo1d_axis).(id).dnum = dnum;
% --- Log message
fprintf(['Add ' geo1d_axis '-1d : #' id ' - done \n']);





