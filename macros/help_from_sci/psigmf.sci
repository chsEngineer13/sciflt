function y=psigmf(x,par)
//Product of Two Sigmoidal member function
//Calling Sequence
//y=psigmf(x,par)
//Parameters
//x:matrix of real.
// par=[a,b,c,d]:4 element row vector of parameters.
//Description
//   <literal>psigmf </literal> compute the product of two sigmoidal member
//     function of <literal>x</literal> with parameters <literal>[a,b,c,d]</literal>.
//         
//       <inlinemediaobject> <imageobject> <imagedata fileref="psigmf.gif" />
//         </imageobject> </inlinemediaobject>
//     
// 
//Examples
//x=linspace(0,1,100)';
// y1=psigmf(x,[15 0.1 15 0.3]);
// y2=psigmf(x,[-15 0.5 -15 0.7]);
// y3=psigmf(x,[15 0.5 -15 0.7]);
// scf();clf();
// plot2d(x,[y1 y2 y3],leg="y1@y2@y3");
// xtitle("Trapezoidal Member Function Example","x","mu(x)");
//See also
//member_functions
//mfeval
// Authors
// Jaime Urzua Grez
// Holger Nahrstaedt

