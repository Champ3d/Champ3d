function design3d = f_add_mconductor(design3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_mconductor','id_dom3d','id_elem','mur'};

% --- default input value

id_dom3d = [];
id_elem  = [];
mur      = 1;
id_mconductor = [];

%--------------------------------------------------------------------------
if ~isfield(design3d,'mconductor')
    design3d.mconductor = [];
end
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No mconductor to add!']);
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

if isempty(id_mconductor)
    error([mfilename ': id_mconductor must be defined !'])
end

if ~isfield(design3d,'dom3d')
    error([mfilename ': dom3d is not defined !']);
end

if isempty(id_dom3d) && isempty(id_elem)
    error([mfilename ': id_dom3d or id_elem must be defined !'])
end

%--------------------------------------------------------------------------
if isempty(id_elem)
    design3d.mconductor.(id_mconductor).id_elem  = design3d.dom3d.(id_dom3d).id_elem;
else
    design3d.mconductor.(id_mconductor).id_elem  = id_elem;
end
% ---
design3d.mconductor.(id_mconductor).id_dom3d = id_dom3d;
design3d.mconductor.(id_mconductor).mur = mur;

% --- info message
fprintf(['Add mcon ' id_mconductor ' - done \n']);



