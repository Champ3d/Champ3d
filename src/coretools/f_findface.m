function foundface = f_findface(varargin)

% 'findby' = 'isboundof','isinterfaceof', 'ID', 'boundedby'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

datin = [];
for i = 1:nargin/2
    eval(['datin.' varargin{2*i-1} '= varargin{2*i};']);
end

if isfield(datin,'isboundof')
    elem = datin.elem;
    node = datin.node;
    iDom = unique(elem(nbNo_inEl+1,:));
    nb2D = length(iDom);
    ibO = []; ibI = [];
    for i = 1:nb2D
        ibO = [ibO find(face_domO == iDom(i) & face_domI == 0)];
        ibI = [ibI find(face_domI == iDom(i) & face_domO == 0)];
    end
    nbBou = length([ibO ibI]);
    bound = zeros(maxnbNo_inFa+1,nbBou);
    bound(1:maxnbNo_inFa,:) = [face(:,ibO) f_invori(face(:,ibI))];
    bound(end,:) = [ibO ibI];
    %----- out
    foundface = bound;
end

%----- interface
if nargin == 1 | isfield(datin,'full') | isfield(datin,'interedge') 
    iDom = unique(elem(nbNo_inEl+1,:));
    iDom = combnk(iDom,2);
    nb2D = size(iDom,1);
    iinf = [];
    for i = 1:nb2D
        iinf = [iinf find((face_domO == iDom(i,1) & face_domI == iDom(i,2)) | ...
                          (face_domI == iDom(i,1) & face_domO == iDom(i,2)))];
    end
    nbInt = length(iinf);
    interface = zeros(maxnbNo_inFa+3,nbInt);
    interface(1:maxnbNo_inFa,:) = face(1:maxnbNo_inFa,iinf);
    interface(maxnbNo_inFa+1,:) = face_domO(iinf);
    interface(maxnbNo_inFa+2,:) = face_domI(iinf);
    interface(maxnbNo_inFa+3,:) = iinf;
    %----- out
    foundface = interface;
end

end