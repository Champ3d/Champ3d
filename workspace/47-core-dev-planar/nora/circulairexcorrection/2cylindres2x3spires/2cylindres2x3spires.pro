Include "cylindreSpire_data.pro";
Include "config_data.pro";
  
Group {
  
  OmegaMag = Region[1];
  OmegaAir = Region[2];
  Omega = Region[{1:2}];
  
  OmegaCoil = Region[1000:1005];
  For i In {1:6}
    iDom = 1000+i-1;
    OmegaCoil~{i} = Region[iDom];
  EndFor
  
  BdOmegaMag = Region[100];

  BdV0 = Region[2000];
}

Function {

  DefineConstant[sorties = "Sorties/"];
  
  mu0 = 4e-7*Pi;
  mu[OmegaMag] = mu_fer*mu0;
  mu[OmegaAir] = mu0;

  sigma[OmegaMag] = sigma_fer;

  w = 2*Pi*freq;

  If (flagConfig==0)
    Jsource[OmegaCoil_1] = Sin_wt_p[]{w,0}*Tangent[];
    Jsource[OmegaCoil_2] = Sin_wt_p[]{w,2*Pi/3}*Tangent[];
    Jsource[OmegaCoil_3] = Sin_wt_p[]{w,-2*Pi/3}*Tangent[];
    Jsource[OmegaCoil_4] = Sin_wt_p[]{w,0}*Tangent[];
    Jsource[OmegaCoil_5] = Sin_wt_p[]{w,2*Pi/3}*Tangent[];
    Jsource[OmegaCoil_6] = Sin_wt_p[]{w,-2*Pi/3}*Tangent[];
  Else
    For icoil In {1:6}
      If (flagConfig==icoil)
        Jsource[OmegaCoil~{icoil}] = Tangent[];
      Else
	Jsource[OmegaCoil~{icoil}] = 0*Tangent[];
      EndIf
    EndFor
  EndIf
    
  Tinit = 0;
  Tfinal = 1/freq;
  dt = Tfinal/100;
}

Jacobian {
  { Name Vol ; Case { { Region All ; Jacobian Vol ; } } }
  { Name Sur ; Case { { Region All ; Jacobian Sur ; } } }
  { Name Lin ; Case { { Region All ; Jacobian Lin ; } } }
}

Integration {
  { Name Int ; 
    Case { 
      { Type Gauss ;
	Case {
	  { GeoElement Point       ; NumberOfPoints  1 ; }
	  { GeoElement Line        ; NumberOfPoints  3 ; }
	  { GeoElement Triangle    ; NumberOfPoints  4 ; }
	  { GeoElement Quadrangle  ; NumberOfPoints  4 ; }
	  { GeoElement Tetrahedron ; NumberOfPoints  5 ; }
	  { GeoElement Hexahedron  ; NumberOfPoints  6 ; }
	  { GeoElement Prism       ; NumberOfPoints  6 ; }
	  { GeoElement Pyramid     ; NumberOfPoints  8 ; }
	}
      }
    }
  }
}

Constraint {

  // condition limite pour A
  { Name AGauge ; Case { { Region Omega; SubRegion BdOmegaMag; Type Assign; Value 0.0 ; } } }

}

FunctionSpace {
  // B = rot A
  { Name ASpace; Type Form1;
    BasisFunction { { Name se; NameOfCoef a; Function BF_Edge; Support Region[{Omega,OmegaCoil}]; Entity EdgesOf[All,Not BdOmegaMag]; } }
    Constraint { { NameOfCoef a ; EntityType EdgesOfTreeIn ; EntitySubType StartingOn ; NameOfConstraint AGauge ; } }
  }
  
  // E = -dA/dt-grad V
  { Name VSpace; Type Form0;
    BasisFunction { { Name sn; NameOfCoef v; Function BF_Node; Support OmegaMag; Entity NodesOf[All,Not BdV0]; } }
  }
  
}

Formulation {

  { Name MagStat; Type FemEquation;
    Quantity {
      { Name a; Type Local; NameOfSpace ASpace; }
    }
    Equation {
      // 1/mu rot A . rot A
      Galerkin { [ 1/mu[] * Dof{d a} , {d a} ]; In Omega; Integration Int; Jacobian Vol; }
      // -A.J
      Galerkin { [ - Jsource[] , {a} ]; In OmegaCoil; Integration Int; Jacobian Lin; }
    }
  }

  { Name MagDyn; Type FemEquation;
    Quantity {
      { Name v; Type Local; NameOfSpace VSpace; }
      { Name a; Type Local; NameOfSpace ASpace; }
    }
    Equation {
      // 1/mu rot A . rot A
      Galerkin { [ 1/mu[] * Dof{d a} , {d a} ]; In Omega; Integration Int; Jacobian Vol; }
      // sigma grad v . A
      Galerkin { [ sigma[] * Dof{d v} , {a} ]; In OmegaMag; Integration Int; Jacobian Vol;  }
      // sigma grad v . grad v
      Galerkin { [ sigma[] * Dof{d v} , {d v} ]; In OmegaMag; Integration Int; Jacobian Vol;  }
      // sigma dA/dt . A
      Galerkin { DtDof [ sigma[] * Dof{a} , {a} ]; In OmegaMag; Integration Int; Jacobian Vol;  }
      // sigma dA/dt . grad v
      Galerkin { DtDof [ sigma[] * Dof{a} , {d v} ]; In OmegaMag; Integration Int; Jacobian Vol;  }
      // -A.J
      Galerkin { [ - Jsource[] , {a} ]; In OmegaCoil; Integration Int; Jacobian Lin; }
    }
  }
  
}

Resolution {

  { Name MagStat;
    System { { Name A; NameOfFormulation MagStat; Type ComplexValue; Frequency freq;} }
    Operation { Generate[A]; Solve[A]; SaveSolution[A]; }
  }
  
  { Name MagDyn;
    System { { Name A; NameOfFormulation MagDyn; Type ComplexValue; Frequency freq;} }
    Operation { Generate[A]; Solve[A]; Print[A]; SaveSolution[A]; }
  }
      
  { Name MagDynT;
    System { { Name A; NameOfFormulation MagDyn;} }
    Operation {
      InitSolution[A];
      TimeLoopTheta[Tinit, Tfinal, dt, 1] { Generate[A]; Solve[A]; SaveSolution[A]; }
    }
  }
}

PostProcessing {

  { Name MagStat; NameOfFormulation MagStat; NameOfSystem A;
    Quantity {
      { Name js ; Value { Integral { [ Jsource[]/ElementVol[] ] ; In OmegaCoil ; Integration Int; Jacobian Lin ; } } }
      { Name b; Value{ Integral{ [ {d a}/ElementVol[] ] ; In Omega; Integration Int; Jacobian Vol; } } }
      { Name Flux ; Value { Integral { [ Tangent[]*{a} ] ; In OmegaCoil ; Integration Int; Jacobian Lin ; } } }
    }
  }

  { Name MagDyn; NameOfFormulation MagDyn; NameOfSystem A;
    Quantity {
      { Name js ; Value { Integral { [ Jsource[]/ElementVol[] ] ; In OmegaCoil ; Integration Int; Jacobian Lin ; } } }
      { Name b; Value{ Integral{ [ {d a}/ElementVol[] ] ; In Omega; Integration Int; Jacobian Vol; } } }
      { Name j; Value{ Integral{ [ -sigma[]*(Dt[{a}]+{d v})/ElementVol[] ] ; In OmegaMag; Integration Int; Jacobian Vol; } } }
      { Name p ; Value{ Integral{ [ Conj[(Dt[{a}]+{d v})]*(sigma[]*(Dt[{a}]+{d v}))/ElementVol[] ]; In OmegaMag; Integration Int; Jacobian Vol; } } }
      { Name p_tot ; Value{ Integral{ [ Conj[(Dt[{a}]+{d v})]*(sigma[]*(Dt[{a}]+{d v})) ]; In OmegaMag; Integration Int; Jacobian Vol; } } }
      { Name Flux ; Value { Integral { [ Tangent[]*{a} ] ; In OmegaCoil ; Integration Int; Jacobian Lin ; } } }
      { Name v; Value{ Local{ [ {v} ] ; In OmegaMag; Jacobian Vol; } } }
    }
  }
}

PostOperation {

  { Name MagStat; NameOfPostProcessing MagStat;
    Operation {
      Print[ js, OnElementsOf OmegaCoil , File "js.pos"] ;
      Print[ b, OnElementsOf Omega , File "b.pos"] ;
      For i In {1:6}
	Print[ Flux[OmegaCoil~{i}], OnGlobal, Format Table, File Sprintf["flux%g.csv",i] ];
      EndFor
    }
  }

  { Name MagDyn; NameOfPostProcessing MagDyn;
    Operation {
      Print[ js, OnElementsOf OmegaCoil , File "js.pos"] ;      
      Print[ b, OnElementsOf Omega , File "b.pos"] ;
      For i In {1:6}
	Print[ Flux[OmegaCoil~{i}], OnGlobal, Format Table, File Sprintf["flux%g.csv",i] ];
      EndFor
      Print[ j, OnElementsOf OmegaMag , File "j.pos"] ;
      Print[ p, OnElementsOf OmegaMag , File "p.pos"] ;
      Print[ p_tot[OmegaMag], OnGlobal, Format Table, File "pertes.csv", SendToServer StrCat[sorties,"1Pertes"],Units "W",Color "LightBlue"] ;
      Print[ v, OnElementsOf OmegaMag , File "v.pos"] ;
    }
  }
}
