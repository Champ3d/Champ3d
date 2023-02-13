function iElem = f_findelem(mesh,varargin)
% F_FINDELEM returns the indices of elements in the mesh with a given ID description.
%--------------------------------------------------------------------------
% iElem = F_FINDELEM(mesh,'id_dom2d',[1 2],'id_layer','Coil');
% iElem = F_FINDELEM(mesh,'id_dom3d',[3 4]);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l?Universit?, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

% for i = 1:(nargin-1)/2
%         eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
% end

datin = [];
datin.defined_on = 'elem';
for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

mesher = mesh.mesher;
elem   = mesh.elem;
con = f_connexion(mesh.elem_type);

switch mesher
    case {'prism2dto3d','hexa2dto3d'}
        iElem = [];
        if strcmpi(datin.defined_on,'elem')
            %-----
            if iscell(datin.id_dom2d)
                lenId_dom2d = length(datin.id_dom2d);
                id_dom2d    = datin.id_dom2d;
            else
                id_dom2d{1} = datin.id_dom2d;
                lenId_dom2d = 1;
            end
            %-----
            if iscell(datin.id_layer)
                lenId_layer = length(datin.id_layer);
                id_layer    = datin.id_layer;
            else
                id_layer{1} = datin.id_layer;
                lenId_layer = 1;
            end
            %-----
            if lenId_dom2d == 1 & lenId_dom2d < lenId_layer
                for ifind = 1:lenId_layer
                    codeLayer = f_str2code(id_layer{ifind});
                    for i = 1:length(id_dom2d{1})
                        iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom2d{1}(i)+ codeLayer)];
                    end
                end
            elseif lenId_layer == 1 & lenId_layer < lenId_dom2d
                for ifind = 1:lenId_dom2d
                    codeLayer = f_str2code(id_layer{1});
                    for i = 1:length(id_dom2d{ifind})
                        iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom2d{ifind}(i)+ codeLayer)];
                    end
                end
            elseif lenId_layer == lenId_dom2d
                for ifind = 1:lenId_dom2d
                    temp = id_layer{ifind};
                    if iscell(temp)
                        for j = 1:length(temp)
                            codeLayer = f_str2code(temp{j});
                            for i = 1:length(id_dom2d{ifind})
                                temp2 = id_dom2d{ifind}(i);
                                if iscell(temp2)
                                    temp2 = cell2mat(temp2);
                                end
                                for k = 1:length(temp2)
                                    %fprintf('id2d = %d, idlay = %s', temp2(k), temp(j))
                                    iElem = [iElem find(elem(con.nbNo_inEl+1,:) == temp2(k)+ codeLayer)];
                                end
                            end
                        end
                    else
                        codeLayer = f_str2code(id_layer{ifind});
                        for i = 1:length(id_dom2d{ifind})
                            iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom2d{ifind}(i)+ codeLayer)];
                        end
                    end
                end
            end
        end
        

%         iElem = [];
%         for i = 1:length(id_dom2d)
%             if iscell(id_layer)
%                 for j = 1:length(id_layer)
%                     codeLayer = f_str2code(id_layer(j));
%                     iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom2d(i)+ codeLayer)];
%                 end
%             else
%                 codeLayer = f_str2code(id_layer);
%                 iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom2d(i)+ codeLayer)];
%             end
%         end
    case 'xxx'
        iElem = [];
        for i = 1:length(id_dom3d)
            iElem = [iElem find(elem(con.nbNo_inEl+1,:) == id_dom3d(i))];
        end
end

%--------------------------------------------------------------------------
iElem = unique(iElem);
end



