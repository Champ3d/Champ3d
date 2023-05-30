function c3dobj = f_add_tconductor(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_thdesign3d','id_tconductor','id_mesh3d','id_dom3d','id_elem',...
           'flambda','frho','fcp','frhocp',...
           'lambda','rho','cp','rhocp'};

% --- default input value
id_thdesign3d = [];
id_mesh3d     = [];
id_dom3d = [];
flambda  = [];
frho     = [];
fcp      = [];
lambda   = [];
rho      = [];
cp       = [];
rhocp    = [];
id_tconductor = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No tconductor to add!']);
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
if isempty(id_thdesign3d)
    id_thdesign3d = fieldnames(c3dobj.thdesign3d);
    id_thdesign3d = id_thdesign3d{1};
end

if isempty(id_mesh3d)
    id_mesh3d = c3dobj.thdesign3d.(id_thdesign3d).id_mesh3d;
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_tconductor)
    error([mfilename ': id_tconductor must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
% --- Output
c3dobj.thdesign3d.(id_thdesign3d).tconductor.(id_tconductor).id_mesh3d = id_mesh3d;
c3dobj.thdesign3d.(id_thdesign3d).tconductor.(id_tconductor).id_dom3d = id_dom3d;
c3dobj.thdesign3d.(id_thdesign3d).tconductor.(id_tconductor).flambda = flambda;
c3dobj.thdesign3d.(id_thdesign3d).tconductor.(id_tconductor).lambda = lambda;
% --- info message
fprintf(['Add tcon #' id_tconductor ' to thdesign3d #' id_thdesign3d ' in mesh3d #' id_mesh3d '\n']);



