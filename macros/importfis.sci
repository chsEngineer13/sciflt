function fls=importfis(fis_filename)
//Import Matlab fis structure
//Calling Sequence
//fls=importfis(fis_filename)
//Parameters
//fls:fls structure.
//fis_filename:string, the fis file name
//Description
// 
//          <literal>importfis </literal> try to import a fis structure generated by
//     Matlab from file <literal>fis_filename</literal>.The extension
//     <literal>'.fis'</literal> is assumed for <literal>fis_filename</literal> if it is not
//     already present.
// 
//     
//          <emphasis role="bold">REMARKS</emphasis>: This utility take the default values if it isn't
//     present in the file. Some member functions have different parameters in
//     Matlab, but are converted to be compatible.
//
// Authors
// Jaime Urzua Grez
// Holger Nahrstaedt


// ----------------------------------------------------------------------
// Try to import matlab fis file
// ----------------------------------------------------------------------
// This file is part of sciFLT ( Scilab Fuzzy Logic Toolbox )
// Copyright (C) @YEARS@ Jaime Urzua Grez
// mailto:jaime_urzua@yahoo.com
// 
// 2011 Holger Nahrstaedt
// ----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ----------------------------------------------------------------------
// CHANGES:
// 2004-10-28 Fix defuzz method.
// 2005-03-24 Fix minor bug
// ----------------------------------------------------------------------

// SOME REMARKS:
// -------------
// (1) The routine don not make a exaustive revision of the file, it's expect that is correct writed


// CHECK ARGUMENT
if (type(fis_filename)~=10) then
	erro("The argument must be a string.");
end
if (convstr(fileparts(fis_filename,"extension"),"l")~=".fis") then
	fisname=fis_filename+".fis";
else
	fisname=fis_filename;
end

// OPEN THE FILE
[fd,ierr]=mopen(fisname,"r");
if (ierr~=0) then
	error("Unable to open the file!");
end
tofind1=["[System]" "[Input" "[Output" "[Rules]"];

// CREATE A DEFAULT STRUCTURE
mfname="";
mftype="";
mfpar=[];
varname="";
varrange=[];

fls=newfls("ts");
fls.comment="Imported from Matlab fis - check it please!";
curpart=0;
while (meof(fd)==0),
	txt=mgetl(fd,1);
	if txt~=[] then
		// TRY TO FIND PART IDENTIFIER
		[a,b]=grep(txt,tofind1);
		if a~=[] then
			curpart=b;
		end
		// TRY TO IMPORT DESCRIPTION <-> SYSTEM
		if (curpart==1) then
			// THE NAME
			if matchid(txt,"Name") then
				t_name=retrievepar(txt,1);
				if t_name~="" then
					fls.name=t_name;
				end
			end

			// THE TYPE
			if matchid(txt,"Type") then
				t_type=retrievepar(txt,1);
				if t_type~="" then
					if (t_type=="mamdani") then
						fls.type="m";
					elseif (t_type=="sugeno") then
						fls.type="ts";
					else
						warning("Unknow type in fis -> take the default value");
					end
				end
			end

			// THE T-NORM
			if matchid(txt,"AndMethod") then
				t_tnorm=retrievepar(txt,1);
				if t_tnorm~="" then
					if (t_tnorm=="min") then
						fls.TNorm="min";
					elseif (t_tnorm=="prod") then
						fls.TNorm="aprod";
					elseif (t_tnorm=="einstein_product") then
						fls.TNorm="eprod";
					else
						warning("Unknow T-Norm in fis -> take the default value.");
					end
				end
			end

			// THE S-NORM
			if matchid(txt,"OrMethod") then
				t_snorm=retrievepar(txt,1);
				if t_snorm~="" then
					if (t_snorm=="max") then
						fls.SNorm="max";
					elseif (t_snorm=="probor") then
						fls.SNorm="asum";
					elseif (t_snorm=="einstein_sum") then
						fls.SNorm="esum";
					else
						warning("Unknow S-Norm in fis -> take the default value.");
					end
				end
			end

			// THE IMPLICATION METHOD
			if matchid(txt,"ImpMethod") then
				t_imp=retrievepar(txt,1);
				if t_imp~="" then
					if (t_imp=="min") then
						fls.ImpMethod="min";
					elseif (t_imp=="prod") then
						fls.ImpMethod="prod";
					elseif (t_imp=="einstein_product") then
						fls.ImpMethod="eprod";
					else
						warning("Unknow Implication Method in fis -> take the default value.");
						fls.ImpMethod="min";
					end
				end
			end

			// THE AGGREGATION METHOD
			if matchid(txt,"AggMethod") then
				t_agg=retrievepar(txt,1);
				if t_agg~="" then
					if (t_agg=="max") then
						fls.AggMethod="max";
					elseif (t_agg=="sum") then
						fls.AggMethod="sum";
					elseif (t_agg=="probor") then
						fls.AggMethod="asum";
					elseif (t_agg=="einstein_sum") then
						fls.AggMethod="esum";
					else
						warning("Unknow Aggregation Method in fis -> take the default value.");
						fls.AggMethod="max";
					end
				end
			end

			// THE DEFUZIFICATION METHOD
			if matchid(txt,"DefuzzMethod") then
				t_def=retrievepar(txt,1);
				if t_def~="" then
					if (t_def=="centroid") then
						fls.defuzzMethod="centroide";
					elseif (t_def=="bisector") then
						fls.defuzzMethod="bisector";
					elseif (t_def=="mom") then
						fls.defuzzMethod="mom";
					elseif (t_def=="lom") then
						fls.defuzzMethod="lom";
					elseif (t_def=="som") then
						fls.defuzzMethod="som";
					elseif (t_def=="wtaver") then
						fls.defuzzMethod="wtaver";
					elseif (t_def=="wtsum") then
						fls.defuzzMethod="wtsum";						
					else
						warning("Unknow Defuzzification Method in fis -> take the default value.");
					end
				end
			end
		end

		// TRY TO IMPORT INPUT | OUTPUT <-> INPUT* | OUTPUT*
		if (curpart==2)|(curpart==3) then
			// THE NAME
			if matchid(txt,"Name") then
				v_name=retrievepar(txt,1);
				if v_name~="" then
					varname=v_name;
				end
			end

			// THE RANGE
			if matchid(txt,"Range") then
				v_range=retrievepar(txt,2);
				if v_range~=[] then
					varrange=v_range;
				end
			end

			// CREATE A NEW VARIABLE
			if (varname~="")&(varrange~=[]) then
				if (curpart==2) then
					fls=addvar(fls,"input",varname,varrange);
				else
					fls=addvar(fls,"output",varname,varrange);
				end
				varname="";
				varrange=[];
			end

			// DETECT MEMBER FUNCTION
			if matchid(txt,"MF")&(~matchid(txt,"NumMF")) then
				[t_mfname,t_mftype,t_mfpar]=retrievepar(txt,3);
				if (t_mfname~="")&(t_mftype~="")&(t_mfpar~=[]) then
					[newpar,bok]=converparam(t_mftype,t_mfpar)
					if bok then
						flsmf=tlist(['flsmf','name','type','par'],t_mfname,t_mftype,newpar);
						if (curpart==2) then
							ci=length(fls.input);
							if ci>0 then
								fls.input(ci).mf($+1)=flsmf;
							end
						else
							co=length(fls.output);
							if co>0 then
								fls.output(co).mf($+1)=flsmf;
							end
						end
					end
				end
			end			
		end

		// TRY TO IMPORT RULE <-> RULES
		if (curpart==4) then
			// SKIP THE FIRST
			if (txt~="[RULES]") then
				t1=strsubst(txt,",","");
				t1=strsubst(t1,"(","");
				t1=strsubst(t1,")","");
				t1=strsubst(t1,":","");				
				[t1,ierr]=evstr(t1);
				if (ierr==0 & ~isempty(t1)) then
					// IN MATLAB 1 means AND and 2 OR
					// BUT IN SCIFLT 0 MEANS OR and 1 AND
                                        weights=t1(:,$-1);
					t1(:,$-1)=2-t1(:,$);		
                                        t1(:,$)=	weights;		
					s1=size(fls.rule,2);
					if (s1==0)|(s1==size(t1,2)) then
						fls.rule=[fls.rule; (t1)];
					end
				end
			end
		end
	end
end
mclose(fd);

// NOW CHECK THE FLS -- DISPLAY INFORMATION ABOUT THE CONVERSION
//checkfls(fls);

endfunction


function [newpar,bok]=converparam(mftype,param)
// UTIL FUNCTION
// CONVERT SOME PARAMETERS FROM MATLAB -> SCILAB
// IT'S ALL OK ??
newpar=[];
bok=%f;

if (mftype=="trimf") then
	if (length(param)>=3) then
		newpar=param(1:3);
		bok=%t;
	end

elseif (mftype=="trapmf") then
	if (length(param)>=4) then
		newpar=param(1:4);
		bok=%t;
	end

elseif (mftype=="gaussmf") then
	if (length(param)>=2) then
		newpar=[param(1) param(2)];
		bok=%t;
	end

elseif (mftype=="gauss2mf") then
	if (length(param)>=4) then
		newpar=[param(1) param(2) param(3) param(4)];
		bok=%t;
	end

elseif (mftype=="gbellmf") then
	if (length(param)>=3) then
		newpar=[param(1) param(2) param(3)];
		bok=%t;
	end

elseif (mftype=="sigmf") then
	if (length(param)>=2) then
		newpar=param(1:2);
		bok=%t;
	end

elseif (mftype=="dsigmf") then
	if (length(param)>=4) then
		newpar=param(1:4);
		bok=%t;
	end

elseif (mftype=="psigmf") then
	if (length(param)>=4) then
		newpar=param(1:4);
		bok=%t;
	end

elseif (mftype=="smf") then
	if (length(param)>=2) then
		newpar=[param(1) param(2)];
		bok=%t;
	end

elseif (mftype=="zmf") then
	if (length(param)>=2) then
		newpar=[param(1) param(2)];
		bok=%t;
	end

elseif (mftype=="pimf") then
	if (length(param)>=4) then
		newpar=[param(1) param(2) param(3) param(4)];
		bok=%t;
	end

elseif (mftype=="constant") then
	if (length(param)>=1) then
		newpar=param(1);
		bok=%t;
	end

elseif (mftype=="linear") then
	newpar=param;
	bok=%t;
end

endfunction


function out=matchid(tx1,tx2)
// UTIL FUNCTION
out=%f;
v1=grep(tx1,tx2);
if v1~=[] then
	out=%t;
end
endfunction



function [out1,out2,out3]=retrievepar(txt,mo)
// UTIL FUNCTION
// RETURN THE PARAMETERS 
// mo = 1  --> find the ???? in * = '????' (the first)
// mo = 2  --> find the ???? in * = [????]
// mo = 3  --> find the ???? in * = '????':'????',[?? ?? ??]
// the [????] are returned as numbers

// FIND THE "="
a=strindex(txt,"=");
if (a~=[]) then
	// GET THE REST - ALSO DELETE THE INITIAL SPACES
	tx1=stripblanks(part(txt,(a(1)+1):length(txt)));
	if (mo==1) then
		out1=""
		out2="";
		out3=[];
		idx=strindex(tx1,"''");
		if (length(idx)>1) then
			out1=part(tx1,(idx(1)+1):(idx(2)-1));
		end

	elseif (mo==2) then
		out1=[];
		out2="";
		out3=[];
		idx1=strindex(tx1,"[");
		idx2=strindex(tx1,"]");
		if ((length(idx1)*length(idx2))>0) then
			tx1=part(tx1,idx1(1):idx2(1));
			[out1,ierr]=evstr(tx1)
			if (ierr~=0) then
				out1=[];
			end			
		end

	elseif (mo==3) then
		out1="";
		out2="";
		idx=strindex(tx1,"''");
		if length(idx)>3 then
			out1=part(tx1,(idx(1)+1):(idx(2)-1));
			out2=part(tx1,(idx(3)+1):(idx(4)-1));
		end
		idx1=strindex(tx1,"[");
		idx2=strindex(tx1,"]");
		if ((length(idx1)*length(idx2))>0) then
			tx1=part(tx1,idx1(1):idx2(1));
			[out3,ierr]=evstr(tx1)
			if (ierr~=0) then
				out3=[];
			end			
		end
		
	else
		error("Incorrect calling sequence");
	end

else
	// RETURN THE DEFAULT VALUES
	if mo==2 then
		out1=[];
	else
		out1="";
	end
	out2="";
	out3=[];
end
endfunction

