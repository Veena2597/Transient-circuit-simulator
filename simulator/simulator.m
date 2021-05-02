function [] = simulator(argc)
parser_init;
[LINELEM,NLNELEM,INFO,NODES,LINNAME,NLNNAME,PRINTNV,PRINTBV,PRINTBI,PLOTNV,PLOTBV,PLOTBI] = parser(argc);

%parameter intialization
num = size(NODES,1); %number of nodes
Y = zeros(num); %Y-matrix
Yn = zeros(num);
J = zeros(num,1); %J-vector
J = zeros(num,1); 

[Y,J,num,Voltages,location] = linearStamp(LINELEM,NLNELEM,NODES,INFO,Y,J,num);

Jc = zeros(num,1); %J-vector for capactiors and inductors
[Y,Jc,LC,location] = lcStamp(LINELEM,NODES,INFO,Y,Jc,location);

%[Yn,Jn] = nonlinearStamp(NLNELEM,Yn,Jn);

Jnew = J+Jc;
[L,U,P]= lu(Y,'vector');
temp= L\Jnew(P);
X= U\temp;
%disp(Y*X-Jnew);
[vplot] = linearTransient(LINELEM,NODES,INFO,PLOTNV,Y,J,X,LC,Voltages,location); 

t=INFO(TSTEP_):INFO(TSTEP_):INFO(TSTOP_);

for i=1:size(vplot,1)
    figure(i);
    xlabel('Time');
    ylabel('Voltage');
    plot(t,vplot(i,:));
end
%disp(X);

end
