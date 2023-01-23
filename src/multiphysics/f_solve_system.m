function dom3d = f_solve_system(dom3d,varargin)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

datin = [];
for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

if ~isfield(datin,'formulation')
    error([mfilename ' : chose a formulation : #APhi, #TOmega, #Thermic']);
end


%--------------------------------------------------------------------------

switch lower(datin.formulation)
    case 'aphi'
        dom3d = f_solveaphi(dom3d,datin);
    case 'aphijw'
        dom3d = f_solveaphijw(dom3d,datin);
    case 'tomega'
        dom3d = f_solvetomega(dom3d,datin);
    case 'thermic'
        dom3d = f_solvethermic(dom3d,datin);
    otherwise
        error([mfilename ' : ' datin.formulation ' is not supported !']);
end
%--------------------------------------------------------------------------


