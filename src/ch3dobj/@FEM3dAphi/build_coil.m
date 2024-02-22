%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_coil(obj)

% ---
phydom_type = 'coil';
% ---
if isempty(obj.(phydom_type))
    return
else
    allphydom = fieldnames(obj.(phydom_type));
end
% ---
for i = 1:length(allphydom)
    % ---
    id_phydom = allphydom{i};
    % ---
    phydom = obj.(phydom_type).(id_phydom);
    dom = phydom.dom;
    % ---
    if ~phydom.to_be_rebuild
        break
    end
    % ---
    f_fprintf(0,['Build #' phydom_type],1,id_phydom,0,'\n');
    % ---
    parent_mesh = dom.parent_mesh;
    % --- current field
    current_field = sparse(3,parent_mesh.nb_elem);
    % ---
    if isa(phydom,'CloseCoil')
        % ---
        con = f_connexion(parent_mesh.elem_type);
        nbEd_inEl = con.nbEd_inEl;
        % ---
        nb_node = parent_mesh.nb_node;
        nb_edge = parent_mesh.nb_edge;
        id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
        % ---
        for ipart = 1:2
            if ipart == 1
                vdom = phydom.electrode_dom;
            else
                vdom = phydom.shape_dom;
            end
            % ---
            gid_elem = vdom.gid_elem;
            gid_node_vdom = f_uniquenode(parent_mesh.elem(:,vdom.gid_elem));
            lwewe = parent_mesh.cwewe('id_elem',gid_elem);
            % ---
            gwewe = sparse(nb_edge,nb_edge);
            for j = 1:nbEd_inEl
                for k = j+1 : nbEd_inEl
                    gwewe = gwewe + ...
                        sparse(id_edge_in_elem(j,gid_elem),id_edge_in_elem(j,gid_elem),...
                        lwewe(:,j,k),nb_edge,nb_edge);
                end
            end
            gwewe = gwewe + gwewe.';
            for j = 1:nbEd_inEl
                gwewe = gwewe + ...
                    sparse(id_edge_in_elem(j,gid_elem),id_edge_in_elem(j,gid_elem),...
                    lwewe(:,j,j),nb_edge,nb_edge);
            end
            % ---
            V = zeros(nb_node,1);
            V(vdom.gid_side_node_1) = 1;
            % ---
            id_node_v_unknown = setdiff(gid_node_vdom,...
                [vdom.gid_side_node_1 vdom.gid_side_node_2]);
            % ---
            if ~isempty(id_node_v_unknown)
                gradgrad = parent_mesh.discrete.grad.' * gwewe * parent_mesh.discrete.grad;
                RHS = - gradgrad * V;
                gradgrad = gradgrad(id_node_v_unknown,id_node_v_unknown);
                RHS = RHS(id_node_v_unknown,1);
                V(id_node_v_unknown) = gradgrad \ RHS;
            end
            % ---
            dofJs = parent_mesh.discrete.grad * V;
            vJs = parent_mesh.field_we('dof',dofJs,'id_elem',gid_elem);
            vJs = f_normalize(vJs);
            % ---
            current_field = current_field + vJs;
        end
        % ---
        % current turn density vector field
        % current_turn_density  = current_field .* nb_turn ./ cs_area;
        % ---
        obj.(phydom_type).(id_phydom).matrix.gid_elem = dom.gid_elem;
        obj.(phydom_type).(id_phydom).matrix.current_field = current_field;
        % ---
    end
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    if isa(phydom,'CloseJsCoil') || isa(phydom,'OpenJsCoil')
        % --- current turn density vector field
        current_turn_density  = current_field .* phydom.nb_turn ./ phydom.cs_area;
        % ---
        js_array = phydom.js.get_on(dom);
        js_array = js_array .* phydom.matrix.current_field;
        % ---
        gid_elem = dom.gid_elem;
        wfjs = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',js_array);
        % ---
        obj.(phydom_type).(id_phydom).matrix.current_turn_density = current_turn_density;
        obj.(phydom_type).(id_phydom).matrix.wfjs = wfjs;
    end
    % ---------------------------------------------------------------------
    phydom.to_be_rebuild = 0;
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
end

end