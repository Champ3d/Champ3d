function geo = f_add_mesh2d(geo,varargin)
% F_ADD_MESH2D ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'build_from','id','flog','id_x','id_y'};

% --- default input value
build_from = 'geo1d'; % 'geo1d', 'geoquad'
id = [];
flog = 1.05; % log factor when making log mesh
id_x = [];
id_y = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~strcmpi(build_from,'geo1d') && ~strcmpi(build_from,'geoquad')
    error([mfilename ' : #build_from should be #geo1d or #geoquad !']);
end
if isempty(id)
    error([mfilename ' : #id must be given !']);
end
%--------------------------------------------------------------------------
if strcmpi(build_from,'geo1d')
    %----------------------------------------------------------------------
    keeparg = {'flog','id_x','id_y'};
    argtopass = {};
    for i = 1:length(keeparg)
        argtopass{2*i-1} = keeparg{i};
        argtopass{2*i}   = eval(keeparg{i});
    end
end
    % --- Output
    geo.geo2d.mesh2d.(id) = f_mesh2dgeo1d(geo.geo1d,argtopass{:});
    % --- Log message
    fprintf(['Add mesh2d #' id ' - done \n']);
end







