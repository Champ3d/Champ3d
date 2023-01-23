function design3d = f_add_mconductor(design3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_dom3d','id_elem','bhcurve','mur','id_mconductor'};
% --- default input value
if isempty(design3d)
    design3d.mconductor = [];
end
id_dom3d = [];
id_elem  = [];
mur     = 0;
bhcurve  = [];


%--------------------------------------------------------------------------
if ~isfield(design3d,'mconductor')
    iec = 0;
else
    iec = length(design3d.mconductor);
end

id_mconductor = ['mcon' num2str(iec+1)];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No magnetic material to add!']);
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

if ~isfield(design3d,'dom3d')
    error([mfilename ': dom3d is not defined !']);
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be defined !'])
end

if ~isfield(design3d.dom3d,id_dom3d)
    error([mfilename ': ' id_dom3d ' is not defined !']);
end

%--------------------------------------------------------------------------
design3d.mconductor(iec+1).id_mconductor  = id_mconductor;
design3d.mconductor(iec+1).id_dom3d = id_dom3d;
if isempty(id_elem)
    design3d.mconductor(iec+1).id_elem  = design3d.dom3d.(id_dom3d).id_elem;
else
    design3d.mconductor(iec+1).id_elem  = id_elem;
end
design3d.mconductor(iec+1).mur     = mur;
design3d.mconductor(iec+1).bhcurve = bhcurve;

end



