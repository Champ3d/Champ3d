classdef OxyImageSystem < Xhandle

properties
        imageregion1 = {}
        imageregion0 = {}
        imageregion2 = {}
        kmax = 2
        xmir = 0
        ymir = 0
        alpha=0
        beta=0
 end

    % --- Constructors
    methods
        function obj = OxyImageSystem(args)
            arguments
                args.imageregion1  = {}
                args.imageregion0 = {}
                args.imageregion2 = {}
                args.kmax {mustBeNumeric}      = 2
                args.xmir {mustBeNumeric}      = 0
                args.ymir {mustBeNumeric}      = 0
                args.alpha {mustBeNumeric}    = 1e-4
                args.beta {mustBeNumeric} = 1
               
            end
            % ---
            obj@Xhandle;
            % ---
           
            % ---
              obj.imageregion1 = args.imageregion1;
            obj.imageregion0 = args.imageregion0;
            obj.imageregion2 = args.imageregion2;
            obj.kmax = args.kmax;
            obj.xmir = args.xmir;
            obj.ymir = args.ymir;
            obj.alpha = args.alpha;
            obj.beta = args.beta;
            % ---
        end

    end

%---setup
methods
 
     function setup(obj)
            obj.imageregion1 = {};
            obj.imageregion0 = {};
            obj.imageregion2 = {};
        end


end







    methods
       function addregion1(obj, pos, I)
            arguments
                obj
                pos
                I
               
             end
        
             obj.imageregion1{end+1} = struct("pos", pos, "I", I);
        end

        function addregion0(obj, pos, I)
            arguments
                obj
                pos
                I
                
            end
        
            obj.imageregion0{end+1} = struct("pos", pos, "I", I);
        end

        function addregion2(obj, pos, I)
            arguments
                obj
                pos
                I
            end
        
            obj.imageregion2{end+1} = struct("pos", pos, "I", I);
        end
    end
%%
methods


    function clearregion1(obj)
        obj.imageregion1 = {};
    end

    function clearregion0(obj)
        obj.imageregion0 = {};
    end

    function clearregion2(obj)
        obj.imageregion2 = {};
    end

end
%%
methods
  function removeregion1(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        keep = true(1, numel(obj.imageregion1));
        for k = 1:numel(obj.imageregion1)
            samePos = norm(obj.imageregion1{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregion1{k}.I - I) < tol;
            if samePos && sameI
                keep(k) = false;
            end
        end
        obj.imageregion1 = obj.imageregion1(keep);
    end

    function removeregion0(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        keep = true(1, numel(obj.imageregion0));
        for k = 1:numel(obj.imageregion0)
            samePos = norm(obj.imageregion0{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregion0{k}.I - I) < tol;
            if samePos && sameI
                keep(k) = false;
            end
        end
        obj.imageregion0 = obj.imageregion0(keep);
    end

    function removeregion2(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        keep = true(1, numel(obj.imageregion2));
        for k = 1:numel(obj.imageregion2)
            samePos = norm(obj.imageregion2{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregion2{k}.I - I) < tol;
            if samePos && sameI
                keep(k) = false;
            end
        end
        obj.imageregion2 = obj.imageregion2(keep);
    end


end





end