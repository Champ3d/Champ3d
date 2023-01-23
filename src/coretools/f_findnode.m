function geo = f_findnode(node,elem,varargin)
% F_FINDNODE returns node IDs.
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% elem : nb_nodes_per_elem x nb_elem
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'elem_type' : element type ('prism', ...)
% 'cut_equation' : cut equation
%--------------------------------------------------------------------------
% OUTPUT
% geo : indices of found nodes and elements.
%--------------------------------------------------------------------------
% EXAMPLE
% geo = F_FINDNODE(node,elem,'elem_type','prism',...
%                  'cut_equation','y > 0 & y == -x & z <= 0.12');
%   --> geo.id_elem
%       geo.id_node
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','cut_equation','elem_type'};

% --- default input value
cut_equation = '';
elem_type = 'prism';

% --- check and update input
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
cut_equation(isspace(cut_equation)) = [];
cut_equation = strrep(cut_equation,'max(x)','max(max(x))');
cut_equation = strrep(cut_equation,'max(y)','max(max(y))');
cut_equation = strrep(cut_equation,'max(z)','max(max(z))');
cut_equation = strrep(cut_equation,'min(x)','min(min(x))');
cut_equation = strrep(cut_equation,'min(y)','min(min(y))');
cut_equation = strrep(cut_equation,'min(z)','min(min(z))');
%--------------------------------------------------------------------------
if isempty(strfind(cut_equation,'&'))
    cut_equation = [cut_equation '&1'];
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbElem = size(elem,2);
%--------------------------------------------------------------------------

iCond  = strfind(cut_equation,'&');
nbCond = length(iCond) + 1;

j = 0; k = 0; neqcond = '1'; eqcond = [];
for i = 1:nbCond
    if i == 1
        cond = cut_equation(1:iCond(i)-1);
    elseif i == nbCond
        cond = cut_equation(iCond(i-1)+1:end);
    else
        cond = cut_equation(iCond(i-1)+1:iCond(i)-1);
    end
    if ~isempty(strfind(cond,'>')) | ~isempty(strfind(cond,'<'))
        j = j + 1;
        neqcond = [neqcond ' & ' cond];
    elseif ~isempty(strfind(cond,'=='))
        k = k + 1;
        eqcond{k} = cond;
    end
end

%--------------------------------------------------------------------------
x = zeros(nbNo_inEl,nbElem);
y = zeros(nbNo_inEl,nbElem);
z = zeros(nbNo_inEl,nbElem);

for i = 1:nbNo_inEl
    x(i,:) = node(1,elem(i,:));
    y(i,:) = node(2,elem(i,:));
    z(i,:) = node(3,elem(i,:));
end

if length(neqcond) > 1                      % 1 & something else
    eval(['iNeqcond = (' neqcond ');']);
    eval('checksum = sum(iNeqcond);');
    iElem = find(checksum >= nbNo_inEl);
else
    iElem = 1:nbElem;
end
    
nbEqcond = length(eqcond);
for i = 1:nbEqcond
    eqcond_L = strrep(eqcond{i},'==','<');
    eqcond_R = strrep(eqcond{i},'==','>');
    eval(['iEqcond_L{i} = (' eqcond_L ');']);
    eval(['iEqcond_R{i} = (' eqcond_R ');']);
    checksum_L = sum(iEqcond_L{i});
    checksum_R = sum(iEqcond_R{i});
    checksum   = checksum_L + checksum_R;
    iElemEqcond{i} = find( (checksum_L < nbNo_inEl & checksum_L > 0 & ...
                            checksum_R < nbNo_inEl & checksum_R > 0)  ...
                          |(checksum   < nbNo_inEl));
end

for i = 1:nbEqcond
    iElem = intersect(iElem,iElemEqcond{i});
end

%--------------------------------------------------------------------------
geo.id_elem = iElem;
%--------------------------------------------------------------------------

con = f_connexion(elem_type);

IDNode = [];
for i = 1:con.nbNo_inEl
    IDNode = [IDNode elem(i,:)];
end

x = node(1,IDNode);
y = node(2,IDNode);
z = node(3,IDNode);

iNeqcond = [];
checksum = [];
neqNode  = [];
if length(neqcond) > 1                      % 1 & something else
    eval(['checksum = (' neqcond ');']);
    neqNode = find(checksum);
else
    neqNode = 1:length(IDNode);
end

for i = 1:nbEqcond
    eval(['checksum = (' eqcond{i} ');']);
    eqNode{i} = find(checksum);
end

eNode = neqNode;
for i = 1:nbEqcond
    eNode = intersect(eNode,eqNode{i});
end
eNode(eNode == 0) = [];
%--------------------------------------------------------------------------
geo.id_node = unique(IDNode(eNode));
%--------------------------------------------------------------------------





















