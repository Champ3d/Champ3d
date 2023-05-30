function c3dobj = f_add_econductor(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_econductor','id_mesh3d','id_dom3d','sigma'};

% --- default input value
id_emdesign3d = [];
id_mesh3d     = [];
id_dom3d      = [];
sigma         = 0;
id_econductor = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No econductor to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if isempty(id_emdesign3d)
    id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    id_emdesign3d = id_emdesign3d{1};
end

if isempty(id_mesh3d)
    id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_econductor)
    error([mfilename ': id_econductor must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_econductor).id_mesh3d = id_mesh3d;
c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_econductor).id_dom3d = id_dom3d;
c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_econductor).sigma = sigma;
% --- info message
fprintf(['Add econ #' id_econductor ' to emdesign3d #' id_emdesign3d ' in mesh3d #' id_mesh3d '\n']);


