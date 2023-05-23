function c3dobj = f_getedge(c3dobj,varargin)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_dom3d'};
       

% --- default input value
id_mesh3d = [];
id_dom3d  = [];
id_dom3d      = [];
coil_mode     = 'transmitter'; % or 'tx'; 'receiver' or 'rx'
cs_equation   = [];
v_petrode = 1;
v_netrode = 0;
stype     = [];
cs_area   = 1;
j_coil    = [];
i_coil    = [];
v_coil    = [];
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
