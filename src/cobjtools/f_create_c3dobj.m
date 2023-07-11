function c3dobj = f_create_c3dobj(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('create_c3dobj');

% --- default input value
project_path = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
c3dobj.config.project_path = project_path;
%--------------------------------------------------------------------------
c3dobj.mesh1d = [];
c3dobj.mesh2d = [];
c3dobj.mesh3d = [];
c3dobj.em_design3d = [];
c3dobj.th_design3d = [];


end