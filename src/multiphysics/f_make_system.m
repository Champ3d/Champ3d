function dom3d = f_make_system(dom3d,varargin)
% F_MAKE_SYSTEM ...
%--------------------------------------------------------------------------
% SElectromag = F_MAKE_SYSTEM(dom3d,'formulation','APhi','fr',1e3,'id_bcon_A',[id_bcon1 id_bcon2],'id_bcon_Phi',id_bcon);
% SElectromag = F_MAKE_SYSTEM(dom3d,'formulation','TOmega','fr',1e3,'id_bcon_T',id_bcon,'id_bcon_Omega',id_bcon);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

fprintf('Making system ... \n');

tic

datin = [];
datin.sflux_onbof  = [];
datin.sflux_onface = [];
datin.svolumic_in  = [];

for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

if ~isfield(datin,'formulation')
    error([mfilename ' : chose a formulation : #APhi, #TOmega, #Thermic']);
end

if ~isfield(datin,'fr')
    datin.fr = 0;
end

%--------------------------------------------------------------------------

switch lower(datin.formulation)
    case 'aphi'
        dom3d = f_makeaphi(dom3d,datin);
    case 'aphijw'
        dom3d = f_makeaphijw(dom3d,datin);
    case 'tomega'
        dom3d = f_maketomega(dom3d,datin);
    case 'thermic'
        dom3d = f_makethermic(dom3d,datin);
    otherwise
        error([mfilename ' : ' datin.formulation ' is not supported !']);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
fprintf('Time making system : %.4f s \n',toc);
end