function face = f_get_face(mesh3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type'};

% --- default input value
elem_type = [];

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
if isempty(elem_type) && isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    nbnoinel = size(mesh3d.elem, 1);
    switch nbnoinel
        case 4
            elem_type = 'tet';
        case 6
            elem_type = 'prism';
        case 8
            elem_type = 'hex';
    end
    fprintf(['Build meshds for ' elem_type ' \n']);
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inFa = con.nbNo_inFa;
nbFa_inEl = con.nbFa_inEl;
FaNo_inEl = con.FaNo_inEl;

%--------------------------------------------------------------------------
elem = mesh3d.elem;
nbElem = size(elem,2);
%--------------------------------------------------------------------------
maxnbNo_inFa = max(nbNo_inFa);
f = zeros(nbFa_inEl,maxnbNo_inFa,nbElem);
%--------------------------------------------------------------------------
for i = 1:nbFa_inEl
    ft = elem(FaNo_inEl(i,1:nbNo_inFa(i)),:);
    % ---
    [ft,~] = f_sortori(ft);
    ft = [ft; zeros(maxnbNo_inFa-nbNo_inFa(i),nbElem)];
    f(i,:,:) = ft;
end
%--------------------------------------------------------------------------
face = reshape(permute(f,[2 3 1]), maxnbNo_inFa, []);
face = f_unique(face);
%--------------------------------------------------------------------------
% --- Outputs
% mesh3d.face = face;

end