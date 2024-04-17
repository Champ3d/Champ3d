function face = f_face(elem,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','defined_on'};

% --- default input value
elem_type = [];
defined_on = 'elem';
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(elem,'defined_on',defined_on);
end
%--------------------------------------------------------------------------
refelem = f_refelem(elem_type);
nbNo_inFa = refelem.nbNo_inFa;
nbFa_inEl = refelem.nbFa_inEl;
FaNo_inEl = refelem.FaNo_inEl;
%--------------------------------------------------------------------------
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
end