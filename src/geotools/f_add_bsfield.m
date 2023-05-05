function c3dobj = f_add_bsfield(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_design3d','id_sfield','id_dom3d','Bs'};

% --- default input value
id_design3d = [];
id_dom3d    = [];
Bs          = 0;
id_bsfield  = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No bsfield to add!']);
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

if isempty(id_design3d)
    id_design3d = fieldnames(c3dobj.design3d);
    id_design3d = id_design3d{1};
end

if isempty(id_bsfield)
    error([mfilename ': id_bsfield must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
% --- Output
c3dobj.design3d.(id_design3d).bsfield.(id_bsfield).id_dom3d = id_dom3d;
c3dobj.design3d.(id_design3d).bsfield.(id_bsfield).Bs = Bs;
% --- info message
fprintf(['Add bsfield #' id_bsfield ' to design3d #' id_design3d '\n']);



