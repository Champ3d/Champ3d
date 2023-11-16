function geo = f_cutdom(node,elem,varargin)
% F_CUTDOM computes the minimum set of elements that makes a domain cut
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% elem : nb_nodes_per_element x nb_elem
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'elem_type' : element type ('prism', 'hex', ...)
% 'cut_equation' : cutting surface equation
%--------------------------------------------------------------------------
% OUTPUT
% geo : geometry definition of cut domain
%   geo.id_elem        : element indices
%   geo.node_positive  : nodes (indices) on one side
%   geo.node_negative  : nodes on another side
%--------------------------------------------------------------------------
% EXAMPLE
% geo = F_CUTDOM(node,elem,'elem_type','prism',...
%                'cut_equation','y > 0 & y == -x & z <= 0.12');
%   --> geo.id_elem
%       geo.node_positive
%       geo.node_negative
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
arglist = {'node','elem','cut_equation','elem_type'};

% --- default input value
cut_equation = '';
elem_type = 'prism';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
cut_equation(isspace(cut_equation)) = [];
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbElem = size(elem,2);
%--------------------------------------------------------------------------

iCond  = strfind(cut_equation,'&');
nbCond = length(iCond) + 1;

j = 0; k = 0; neqcond = '1';
for i = 1:nbCond
    if i == 1
        cond = cut_equation(1:iCond(i)-1);
    elseif i == nbCond
        cond = cut_equation(iCond(i-1)+1:end);
    else
        cond = cut_equation(iCond(i-1)+1:iCond(i)-1);
    end
    if ~isempty(strfind(cond,'>')) || ~isempty(strfind(cond,'<'))
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

if length(neqcond) > 1
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

if isempty(iElem)
    %----------------------------------------------------------------------
    geo.node_positive = [];
    geo.node_negative = [];
    %----------------------------------------------------------------------
else

    elem(nbNo_inEl+1,:) = 1;
    elem(nbNo_inEl+1,iElem) = 2;
    mesh = f_make_mds(node,elem,elem_type);

    etrodeNode = [];
    for i = 1:max(con.nbNo_inFa)
        etrodeNode = [etrodeNode mesh.interface(i,:)];
    end

    etrodeNode(etrodeNode == 0) = [];
    x = node(1,etrodeNode);
    y = node(2,etrodeNode);
    z = node(3,etrodeNode);

    for i = 1:nbEqcond
        eqcond_L = strrep(eqcond{i},'==','<');
        eqcond_R = strrep(eqcond{i},'==','>');
        eval(['checksum_L = (' eqcond_L ');']);
        eval(['checksum_R = (' eqcond_R ');']);
        Node_pos{i} = etrodeNode(checksum_L~=0);
        Node_neg{i} = etrodeNode(checksum_R~=0);
    end

    eNodePos = [];
    eNodeNeg = [];
    for i = 1:nbEqcond
        eNodePos = [eNodePos Node_pos{i}];
        eNodeNeg = [eNodeNeg Node_neg{i}];
    end

    %--------------------------------------------------------------------------
    geo.node_positive = eNodePos;
    geo.node_negative = eNodeNeg;
    %--------------------------------------------------------------------------
end


