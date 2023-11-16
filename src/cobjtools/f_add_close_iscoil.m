function c3dobj = f_add_close_iscoil(c3dobj,varargin)
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
arglist = {'id_emdesign3d','id_coil','id_dom3d','id_elem','etrode_type',...
           'coil_mode','coil_type',...
           'cs_equation','petrode_equation','netrode_equation',...
           'field_vector_o','field_vector_v','nb_turn', ...
           'v_petrode','v_netrode','stype','cs_area','j_coil','i_coil','id_bcon'};
       

% --- default input value
id_emdesign3d = [];
id_coil       = [];
id_dom3d      = [];
coil_mode     = 'transmitter'; % or 'tx'; 'receiver' or 'rx'
cs_equation   = [];
v_petrode = 1;
v_netrode = 0;
stype     = [];
cs_area   = 1;
j_coil    = [];
i_coil    = [];
v_coil    = [];
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
if isempty(id_emdesign3d)
    id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
if isempty(id_dom3d)
    error([mfilename ' : #id_dom3d must be given !']);
end
%--------------------------------------------------------------------------
if isempty(id_coil)
    error([mfilename ' : #id_coil must be given !']);
end
%--------------------------------------------------------------------------
if isempty(cs_equation)
    if isempty(field_vector_o) || isempty(field_vector_v)
        error([mfilename ' : #cs_equation or #field_vector_o and #field_vector_v must be given !']);
    end
end
%--------------------------------------------------------------------------
id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
%--------------------------------------------------------------------------
id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
node = c3dobj.mesh3d.(id_mesh3d).node;
elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
elem_type = c3dobj.mesh3d.(id_mesh3d).elem_type;
con = f_connexion(elem_type);
id_node = f_uniquenode(elem,'nb_vertices',con.EdNo_inEl);
%--------------------------------------------------------------------------
if ~isempty(cs_equation)
    if ~iscell(cs_equation)
        cs_equation{1} = cs_equation;
    end
    geo = f_cutdom(node, elem, 'elem_type', elem_type,...
                   'cut_equation', cs_equation{1});
    geo.id_elem = id_elem(geo.id_elem); % !!!
    %------
    etrode = geo;
    petrode.id_elem = geo.id_elem;
    petrode.id_node = geo.node_positive;
    netrode.id_elem = geo.id_elem;
    netrode.id_node = geo.node_negative;
    id_elem = setdiff(id_elem,geo.id_elem);
    cutnode = f_uniquenode(c3dobj.mesh.elem(:,geo.id_elem),...
                           'nb_vertices',con.EdNo_inEl);
    id_node = setdiff(id_node,cutnode);
    %------
end
%--------------------------------------------------------------------------
% --- Output
% -
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).cs_equation = cs_equation;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).etrode  = etrode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).id_elem = id_elem;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).id_node = id_node;
% -
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).petrode = petrode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).netrode = netrode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).id_emdesign3d = id_emdesign3d;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).id_dom3d  = id_dom3d;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).coil_mode = coil_mode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).coil_type = 'close_iscoil';
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).v_petrode = v_petrode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).v_netrode = v_netrode;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).stype     = 'is';
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).cs_area   = cs_area;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).j_coil    = j_coil;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).i_coil    = i_coil;
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).v_coil    = v_coil;
% --- status
c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #close-iscoil',1,id_coil,0,'to #emdesign3d',1,id_emdesign3d,0,'\n');

