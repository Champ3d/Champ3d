function c3dobj = f_add_coil(c3dobj,varargin)
% F_ADD_COIL ...
%--------------------------------------------------------------------------
% FIXED INPUT
% emdesign3d : actual design
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
% emdesign3d with added coil
%--------------------------------------------------------------------------
% EXAMPLE
% emdesign3d = f_add_coil(emdesign3d,'id_dom3d','coil',...
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
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'emdesign3d','id_dom3d','id_elem','etrode_type',...
           'coil_mode','coil_type',...
           'cs_equation','petrode_equation','netrode_equation',...
           'field_vector_o','field_vector_v','nb_turn', ...
           'v_petrode','v_netrode','stype','cs_area','j_coil','i_coil','id_bcon'};
       

% --- default input value
c3dobj.coil(iec+1).id_dom3d = [];
c3dobj.coil(iec+1).id_elem  = [];
c3dobj.coil(iec+1).id_node  = [];
c3dobj.coil(iec+1).coil_mode = [];
c3dobj.coil(iec+1).coil_type = [];
c3dobj.coil(iec+1).etrode_type  = [];
c3dobj.coil(iec+1).cs_equation  = [];
c3dobj.coil(iec+1).petrode_equation = [];
c3dobj.coil(iec+1).netrode_equation = [];
c3dobj.coil(iec+1).v_petrode = 1;
c3dobj.coil(iec+1).v_netrode = 0;
c3dobj.coil(iec+1).stype = [];
c3dobj.coil(iec+1).cs_area = [];
c3dobj.coil(iec+1).j_coil = [];
c3dobj.coil(iec+1).i_coil = [];
c3dobj.coil(iec+1).nb_turn = [];
c3dobj.coil(iec+1).id_bcon = [];
c3dobj.coil(iec+1).field_vector_o = [];
c3dobj.coil(iec+1).field_vector_v = [];
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename 'No coil to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if strcmpi(varargin{2*i-1},'coil_option')
        coil_option = varargin{2*i};
        c3dobj.coil(iec+1) = f_addtostruct(coil_option,c3dobj.coil(iec+1));
    else
        if any(strcmpi(arglist,varargin{2*i-1}))
            c3dobj.coil(iec+1).(lower(varargin{2*i-1})) = varargin{2*i};
        else
            error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
        end
    end
end
%--------------------------------------------------------------------------

if ~isfield(c3dobj,'dom3d')
    error([mfilename ' : dom3d is not defined !']);
end

if isempty(c3dobj.coil(iec+1).id_dom3d)
    error([mfilename ' : id_dom3d must be defined !'])
end

if ~isfield(c3dobj.dom3d,c3dobj.coil(iec+1).id_dom3d)
    error([mfilename ' : ' id_dom3d ' is not defined !']);
end

%--------------------------------------------------------------------------
if isempty(c3dobj.coil(iec+1).coil_mode)
    c3dobj.coil(iec+1).coil_mode = 'transmitter';
end
if ~strcmpi(c3dobj.coil(iec+1).coil_mode,'transmitter') & ~strcmpi(c3dobj.coil(iec+1).coil_mode,'receiver')
    c3dobj.coil(iec+1).coil_mode = 'receiver';
end
%--------------------------------------------------------------------------
if isempty(c3dobj.coil(iec+1).i_coil)
    if isempty(c3dobj.coil(iec+1).cs_area) | isempty(c3dobj.coil(iec+1).j_coil)
        c3dobj.coil(iec+1).i_coil = 1;
    else
        c3dobj.coil(iec+1).i_coil = c3dobj.coil(iec+1).j_coil .* ...
                                      c3dobj.coil(iec+1).cs_area;
    end
end
%--------------------------------------------------------------------------
if isempty(c3dobj.coil(iec+1).nb_turn)
    c3dobj.coil(iec+1).nb_turn  = 1;
end
if isempty(c3dobj.coil(iec+1).cs_area)
    c3dobj.coil(iec+1).cs_area  = 1;
end
if isempty(c3dobj.coil(iec+1).j_coil)
    if ~isempty(c3dobj.coil(iec+1).i_coil) & ~isempty(c3dobj.coil(iec+1).nb_turn) & ~isempty(c3dobj.coil(iec+1).cs_area)
        c3dobj.coil(iec+1).j_coil = ...
            c3dobj.coil(iec+1).i_coil*c3dobj.coil(iec+1).nb_turn/c3dobj.coil(iec+1).cs_area;
    else
        c3dobj.coil(iec+1).j_coil = 0;
    end
end
%--------------------------------------------------------------------------

coilModel = [lower(c3dobj.coil(iec+1).coil_type), ...
             lower(c3dobj.coil(iec+1).stype)];

switch coilModel
    case {['stranded','j'],['massive','j']}
        %--------------------------
        if ~isempty(c3dobj.coil(iec+1).field_vector_v) & ~isempty(c3dobj.coil(iec+1).field_vector_o)
            c3dobj.coil(iec+1).coil_model = 't1';
        end
        %--------------------------
        if ~isempty(c3dobj.coil(iec+1).cs_equation)
            c3dobj.coil(iec+1).coil_model = 't2';
        end
        %--------------------------
        if ~isempty(c3dobj.coil(iec+1).petrode_equation) & ~isempty(c3dobj.coil(iec+1).netrode_equation)
            c3dobj.coil(iec+1).coil_model = 't2';
        end
    case ['massive','i']
        %--------------------------
%         if ~isempty(emdesign3d.coil(iec+1).cs_equation)
%             emdesign3d.coil(iec+1).coil_model = 't3';
%         end
        c3dobj.coil(iec+1).coil_model = 't3';
    case ['massive','v']
        %--------------------------
%         if ~isempty(emdesign3d.coil(iec+1).cs_equation)
%             emdesign3d.coil(iec+1).coil_model = 't4';
%         end
        c3dobj.coil(iec+1).coil_model = 't4';
end
%--------------------------------------------------------------------------
if isempty(c3dobj.coil(iec+1).id_elem)
    c3dobj.coil(iec+1).id_elem  = c3dobj.dom3d.(c3dobj.coil(iec+1).id_dom3d).id_elem;
else
    c3dobj.coil(iec+1).id_elem  = id_elem;
end
% ---
con = f_connexion(c3dobj.mesh.elem_type);
c3dobj.coil(iec+1).id_node = unique(c3dobj.mesh.elem(1:con.nbNo_inEl,c3dobj.coil(iec+1).id_elem));

%--------------------------------------------------------------------------
% coil_type = dom3d.coil(iec+1).coil_type;
etrode_type = c3dobj.coil(iec+1).etrode_type;
switch etrode_type
    case 'close'
        if ~isempty(c3dobj.coil(iec+1).cs_equation)
            if ~iscell(c3dobj.coil(iec+1).cs_equation)
                cs_equation{1} = c3dobj.coil(iec+1).cs_equation;
            else
                cs_equation = c3dobj.coil(iec+1).cs_equation;
            end
            geo = f_cutdom(c3dobj.mesh.node,c3dobj.mesh.elem(:,c3dobj.coil(iec+1).id_elem),...
                    'elem_type',c3dobj.mesh.elem_type,...
                    'cut_equation',cs_equation{1});
            geo.id_elem = c3dobj.coil(iec+1).id_elem(geo.id_elem); % !!!
            %------
            c3dobj.coil(iec+1).etrode = geo;
            c3dobj.coil(iec+1).petrode.id_elem = geo.id_elem;
            c3dobj.coil(iec+1).petrode.id_node = geo.node_positive;
            c3dobj.coil(iec+1).netrode.id_elem = geo.id_elem;
            c3dobj.coil(iec+1).netrode.id_node = geo.node_negative;
            c3dobj.coil(iec+1).id_elem = ...
                setdiff(c3dobj.coil(iec+1).id_elem,geo.id_elem);
            cutnode = f_uniquenode(c3dobj.mesh.elem(:,geo.id_elem),...
                          'nb_vertices',6);
            c3dobj.coil(iec+1).id_node = ...
                setdiff(c3dobj.coil(iec+1).id_node,cutnode);
            %------
        end
    case 'open'
        if ~isempty(c3dobj.coil(iec+1).petrode_equation)
            if ~iscell(c3dobj.coil(iec+1).petrode_equation)
                petrode_equation{1} = c3dobj.coil(iec+1).petrode_equation;
            else
                petrode_equation = c3dobj.coil(iec+1).petrode_equation;
            end
            for itrod = 1:length(c3dobj.coil(iec+1).petrode_equation)
                geo = f_findnode(c3dobj.mesh.node,c3dobj.mesh.elem(:,c3dobj.coil(iec+1).id_elem),...
                        'elem_type',c3dobj.mesh.elem_type,...
                        'cut_equation',petrode_equation{itrod});
                geo.id_elem = c3dobj.coil(iec+1).id_elem(geo.id_elem); % !!!
                %------
                c3dobj.coil(iec+1).petrode(itrod) = geo;
                %------
            end
        end
        if ~isempty(c3dobj.coil(iec+1).netrode_equation)
            if ~iscell(c3dobj.coil(iec+1).netrode_equation)
                netrode_equation{1} = c3dobj.coil(iec+1).netrode_equation;
            else
                netrode_equation = c3dobj.coil(iec+1).netrode_equation;
            end
            for itrod = 1:length(c3dobj.coil(iec+1).netrode_equation)
                geo = f_findnode(c3dobj.mesh.node,c3dobj.mesh.elem(:,c3dobj.coil(iec+1).id_elem),...
                        'elem_type',c3dobj.mesh.elem_type,...
                        'cut_equation',netrode_equation{itrod});
                geo.id_elem = c3dobj.coil(iec+1).id_elem(geo.id_elem); % !!!
                %------
                c3dobj.coil(iec+1).netrode(itrod) = geo;
                %------
            end
        end
end

