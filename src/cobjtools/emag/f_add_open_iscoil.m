function c3dobj = f_add_open_iscoil(c3dobj,varargin)
% F_ADD_COIL ...
%--------------------------------------------------------------------------
% FIXED INPUT
% emdesign : actual design
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_dom3d' : ids of 3D domains
% 'id_bcon'  : ids of the applied boundary condition
% 'id_elem'  : elements' ids (used if id_dom3d is not available)
% 'coil_mode' = 'transmitter' or 'receiver'
%     + use 'transmitter' for source coil
% 'etrode_type' : electrode type : 'close' or 'open'
%     + for 'close'-type coil
%         o 'cs_equation' : cross section equation
%     + for 'open'-type coil
%         o 'petrode_equation' : equation to define positive electrode nodes
%         o 'netrode_equation' : equation to define negative electrode nodes
% 'v_petrode' : positive electrode potential
% 'v_netrode' : negative electrode potential
% 'stype' : source type
%     + 'j' : impressed j
%         o 'jcoil' : given j
%         o 'cs_area' : cross section area
%     + 'i' : impressed i
%     + 'v' : impressed v
% 'field_vector_o' : coordinates of the origine of the field vector
% 'field_vector_v' : the field vector that indicates approximatively
%                    the orientation of the source field
% 'field_vector_rounding' : rounding or not corner and straight edge
%--------------------------------------------------------------------------
% OUTPUT
% emdesign with added coil
%--------------------------------------------------------------------------
% EXAMPLE
% emdesign = f_add_coil(emdesign,'id_dom3d','coil',...
%                          'coil_type','stranded',...
%                          'coil_mode','transmitter',...
%                          'etrode_type','open',...
%                          'petrode_equation',{'z == max(z) & x < 0'},...
%                          'netrode_equation',{'z == max(z) & x > 0'},...
%                          'v_petrode',1,...
%                          'v_netrode',0,...
%                          'stype','j','j_coil',Icoil/coilSection,...
%                          'cs_area',coilSection,...
%                          'id_bcon',1);
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
arglist = {'id_emdesign','id_coil','id_dom3d','id_elem','etrode_type',...
           'coil_mode','coil_type',...
           'cs_equation','petrode_equation','netrode_equation',...
           'field_vector_o','field_vector_v','nb_turn', ...
           'v_petrode','v_netrode','stype','cs_area','j_coil','i_coil','id_bcon'};
       

% --- default input value
id_emdesign = [];
id_coil       = [];
id_dom3d      = [];
coil_mode     = 'tx'; % or 'tx'; 'receiver' or 'rx'
petrode_equation = [];
netrode_equation = [];
v_petrode = 1;
v_netrode = 0;
stype     = [];
i_coil    = 0;
j_coil    = [];
v_coil    = [];
nb_turn   = 1;
cs_area   = 1;
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
if isempty(id_emdesign)
    id_emdesign = fieldnames(c3dobj.emdesign);
    id_emdesign = id_emdesign{1};
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
if isempty(petrode_equation) || isempty(netrode_equation)
    error([mfilename ' : #petrode_equation and #netrode_equation must be given !']);
end
%--------------------------------------------------------------------------
id_mesh3d = c3dobj.emdesign.(id_emdesign).id_mesh3d;
%--------------------------------------------------------------------------
id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
node = c3dobj.mesh3d.(id_mesh3d).node;
elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
elem_type = c3dobj.mesh3d.(id_mesh3d).elem_type;
%--------------------------------------------------------------------------
if ~isempty(petrode_equation)
    %----------------------------------------------------------------------
    petrode = [];
    %----------------------------------------------------------------------
    petrode_equation = f_to_scellargin(petrode_equation);
    %----------------------------------------------------------------------
    for itrod = 1:length(petrode_equation)
        petrode(itrod).id_node = f_find_cutnode3d(node, elem, 'elem_type', elem_type,...
                                                'cut_equation', petrode_equation{itrod});
        idElem = f_find_cutelem3d(node, elem, 'elem_type', elem_type,...
                                'cut_equation', petrode_equation{itrod});
        idElem = id_elem(idElem);
        petrode(itrod).id_elem = idElem;
    end
end
%--------------------------------------------------------------------------
if ~isempty(netrode_equation)
    %----------------------------------------------------------------------
    netrode = [];
    %----------------------------------------------------------------------
    netrode_equation = f_to_scellargin(netrode_equation);
    %----------------------------------------------------------------------
    for itrod = 1:length(netrode_equation)
        netrode(itrod).id_node = f_find_cutnode3d(node, elem, 'elem_type', elem_type,...
                                                'cut_equation', netrode_equation{itrod});
        idElem = f_find_cutelem3d(node, elem, 'elem_type', elem_type,...
                                'cut_equation', netrode_equation{itrod});
        idElem = id_elem(idElem);
        netrode(itrod).id_elem = idElem;
    end
end
%--------------------------------------------------------------------------
% --- Output


c3dobj.emdesign.(id_emdesign).coil.(id_coil).petrode_equation = petrode_equation;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).netrode_equation = netrode_equation;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).defined_with = 'etrode';
c3dobj.emdesign.(id_emdesign).coil.(id_coil).id_elem = id_elem;
% -
c3dobj.emdesign.(id_emdesign).coil.(id_coil).petrode = petrode;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).netrode = netrode;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).id_emdesign = id_emdesign;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).id_dom3d  = id_dom3d;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).coil_mode = coil_mode;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).coil_type = 'open_iscoil';
c3dobj.emdesign.(id_emdesign).coil.(id_coil).v_petrode = v_petrode;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).v_netrode = v_netrode;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).stype     = 'is';
c3dobj.emdesign.(id_emdesign).coil.(id_coil).cs_area   = cs_area;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).j_coil    = j_coil;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).i_coil    = i_coil;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).nb_turn   = nb_turn;
c3dobj.emdesign.(id_emdesign).coil.(id_coil).v_coil    = v_coil;
% --- status
c3dobj.emdesign.(id_emdesign).coil.(id_coil).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #open-iscoil',1,id_coil,0,'to #emdesign',1,id_emdesign,0,'\n');

