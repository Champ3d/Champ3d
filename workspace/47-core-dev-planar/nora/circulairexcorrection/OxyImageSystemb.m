classdef OxyImageSystemb < Xhandle

properties
        imageregion1 = {}
        imageregion2 = {}
        imageregion3 = {}
        imageregion4 = {}
        imageregion5 = {}
        kmax = 2
        z1primaire=0
        z1secondaire=0
        alpha=0
        beta=0
 end

    % --- Constructors
    methods
        function obj = OxyImageSystemb(args)
            arguments
                args.imageregion1  = {}
                args.imageregion2 = {}
                args.imageregion3 = {}
                args.imageregion4 = {}
                args.imageregion5 = {}
                args.kmax {mustBeNumeric} = 2
                args.z1primaire {mustBeNumeric}= 0
                args.z1secondaire {mustBeNumeric}= 0
                args.alpha {mustBeNumeric}    = 1e-4
                args.beta {mustBeNumeric} = 1
               
            end
            % ---
            obj@Xhandle;
            % ---
           
            % ---
            obj.imageregion1 = args.imageregion1;
            obj.imageregion2 = args.imageregion2;
            obj.imageregion3 = args.imageregion3;
            obj.imageregion4 = args.imageregion4;
            obj.imageregion5 = args.imageregion5;
            obj.kmax = args.kmax;
            obj.z1primaire  = args.z1primaire ;
            obj.z1secondaire  = args.z1secondaire;
           
            
            obj.alpha = args.alpha;
            obj.beta = args.beta;
            % ---
        end

    end

%---setup
methods
 
     function setup(obj)
            obj.imageregion1 = {};
            obj.imageregion2 = {};
            obj.imageregion3 = {};
            obj.imageregion4 = {};
            obj.imageregion5 = {};
        end


end







    methods
       function addregion1(obj, coil_obj, region, next_interface)
                arguments
                    obj
                    coil_obj  OxyCoil6
                    region
                    next_interface
                end
            
                newElem = struct( "coil", coil_obj, "region", region, "next_interface", next_interface, "deja_traite", false);
            
                obj.imageregion1{end+1} = newElem;
        end

        function addregion2(obj, coil_obj, region, next_interface)
                arguments
                    obj
                    coil_obj  OxyCoil6
                    region
                    next_interface
                end
            
                 newElem = struct( "coil", coil_obj, "region", region, "next_interface", next_interface, "deja_traite", false);
            
                obj.imageregion2{end+1} = newElem;
        end

        function addregion3(obj, coil_obj, region, next_interface)
                arguments
                    obj
                    coil_obj  OxyCoil6
                    region
                    next_interface
                end
            
                newElem = struct( "coil", coil_obj, "region", region, "next_interface", next_interface, "deja_traite", false);
            
                obj.imageregion3{end+1} = newElem;
        end

        function addregion4(obj, coil_obj, region, next_interface)
                arguments
                    obj
                    coil_obj  OxyCoil6
                    region
                    next_interface
                end
            
                newElem = struct( "coil", coil_obj, "region", region, "next_interface", next_interface, "deja_traite", false);
            
                obj.imageregion4{end+1} = newElem;
        end
        
        function addregion5(obj, coil_obj, region, next_interface)
                arguments
                    obj
                    coil_obj  OxyCoil6
                    region
                    next_interface
                end
            
                newElem = struct( "coil", coil_obj, "region", region, "next_interface", next_interface, "deja_traite", false);
            
                obj.imageregion5{end+1} = newElem;
        end
        
    end
%%
methods


    function clearregion1(obj)
        obj.imageregion1 = {};
    end

    function clearregion2(obj)
        obj.imageregion2 = {};
    end

    function clearregion3(obj)
        obj.imageregion3 = {};
    end

    function clearregion4(obj)
        obj.imageregion4 = {};
    end

    function clearregion5(obj)
        obj.imageregion5 = {};
    end

end


methods

   function obj3 = fusionner(obj1, obj2)

    obj3 = OxyImageSystemb( ...
        "kmax", max(obj1.kmax, obj2.kmax), ...
        "z1primaire", obj1.z1primaire, ...
        "z1secondaire", obj1.z1secondaire, ...
        "epaisseur", obj1.epaisseur, ...
        "alpha", obj1.alpha, ...
        "beta", obj1.beta);

    obj3.imageregion1 = [obj1.imageregion1, obj2.imageregion1];
    obj3.imageregion2 = [obj1.imageregion2, obj2.imageregion2];
    obj3.imageregion3 = [obj1.imageregion3, obj2.imageregion3];
    obj3.imageregion4 = [obj1.imageregion4, obj2.imageregion4];
    obj3.imageregion5 = [obj1.imageregion5, obj2.imageregion5];
end



end
end