load -mat rc_line.dat;

num = size(NODES,1);
Y=zeros(size(NODES,1));
J=zeros(size(NODES,1),1);
t=INFO(TSTEP_);
disp([INFO(FE_) INFO(BE_) INFO(TR_)]);
IL=0;
IC=0;

for i=1:size(LINELEM,1)
   if(LINELEM(i,TYPE_) == R_)
       N1=LINELEM(i,Y_N1_);
       N2=LINELEM(i,Y_N2_);
       if(N1>num)
           Y(N1,N1)=0;
       end
       if(N2>num)
           Y(N2,N2)=0;
       end
       if(N1>0) && (N2>0)
           Y(N1,N1)=Y(N1,N1)+LINELEM(i,Y_VALUE_);
           Y(N1,N2)=Y(N1,N2)-LINELEM(i,Y_VALUE_);
           Y(N2,N1)=Y(N2,N1)-LINELEM(i,Y_VALUE_);
           Y(N2,N2)=Y(N2,N2)+LINELEM(i,Y_VALUE_);
       elseif(N1<0)
           Y(N2,N2)=Y(N2,N2)+LINELEM(i,Y_VALUE_);
       elseif(N2<0)
           Y(N1,N1)=Y(N1,N1)+LINELEM(i,Y_VALUE_);
       end
       %display([i N1 N2 LINELEM(i,Y_VALUE_)]);
   elseif(LINELEM(i,TYPE_) == V_)
       N1=LINELEM(i,V_N1_);
       N2=LINELEM(i,V_N2_);
       if(N1>num)
           Y(N1,N1)=0;
       end
       if(N2>num)
           Y(N2,N2)=0;
       end
       if(N1>0)
           Y(num+1,N1)=1;
           Y(N1,num+1)=1;
       end
       if(N2>0)
           Y(num+1,N2)=-1;
           Y(N2,num+1)=-1;
       end
       J(num+1)=V_VALUE_;
       num=num+1;
   elseif(LINELEM(i,TYPE_) == I_)
       N1=LINELEM(i,I_N1_);
       N2=LINELEM(i,I_N2_);
       if(N1>num)
           J(I_N1_)=0;
       end
       if(N1>num)
           J(I_N2_)=0;
       end
       if(N1>0) && (N2>0)
           J(N1)=J(N1)-LINELEM(i,I_VALUE_);
           J(N2)=J(N2)+LINELEM(i,I_VALUE_);
       elseif(N1<0)
           J(N2)=J(N2)+LINELEM(i,I_VALUE_);
       elseif(N2<0)
           J(N1)=J(N1)-LINELEM(i,I_VALUE_);
       end
   elseif(LINELEM(i,TYPE_) == G_)
       N1=LINELEM(i,G_N1_);
       N2=LINELEM(i,G_N2_);
       CN1=LINELEM(i,G_CN1_);
       CN2=LINELEM(i,G_CN2_);
       if(N1>num)
           Y(N1,N1)=0;
       end
       if(N2>num)
           Y(N2,N2)=0;
       end
       if(N1>0) && (N2>0)
           Y(CN1,N1)=Y(CN1,N1)+LINELEM(i,G_VALUE_);
           Y(CN1,N2)=Y(CN1,N2)-LINELEM(i,G_VALUE_);
           Y(CN2,N1)=Y(CN2,N1)-LINELEM(i,G_VALUE_);
           Y(CN2,N2)=Y(CN2,N2)+LINELEM(i,G_VALUE_);
       elseif(N1<0)
           Y(CN2,N2)=Y(CN2,N2)+LINELEM(i,G_VALUE_);
       elseif(N2<0)
           Y(CN1,N1)=Y(CN1,N1)+LINELEM(i,G_VALUE_);
       end
   elseif(LINELEM(i,TYPE_) == C_)
       N1=LINELEM(i,C_N1_);
       N2=LINELEM(i,C_N2_);
       if(N1>num)
           Y(N1,N1)=0;
           J(N1)=0;
       end
       if(N2>num)
           Y(N2,N2)=0;
           J(N2)=0;
       end
       if(N1>0) && (N2>0) 
           Y(N1,N1)=Y(N1,N1)+(2*LINELEM(i,C_VALUE_)/t);
           Y(N1,N2)=Y(N1,N2)-(2*LINELEM(i,C_VALUE_)/t);
           Y(N2,N1)=Y(N2,N1)-(2*LINELEM(i,C_VALUE_)/t);
           Y(N2,N2)=Y(N2,N2)+(2*LINELEM(i,C_VALUE_)/t);
           if(~isnan(LINELEM(i,C_IC_)))
               IC = 2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t;
               J(N1)=J(N1)-(2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t);
               J(N2)=J(N2)+(2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t);
           end
       elseif(N1<0)
           Y(N2,N2)=Y(N2,N2)+(2*LINELEM(i,C_VALUE_)/t);
           if(~isnan(LINELEM(i,C_IC_)))
               IC = 2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t;
               J(N2)=J(N2)+(2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t);
           end
       elseif(N2<0)
           Y(N1,N1)=Y(N1,N1)+(2*LINELEM(i,C_VALUE_)/t);
           if(~isnan(LINELEM(i,C_IC_)))
               IC = 2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t;
               J(N1)=J(N1)-(2*LINELEM(i,C_IC_)*LINELEM(i,C_VALUE_)/t);
           end
       end
   elseif(LINELEM(i,TYPE_) == L_)
       N1=LINELEM(i,L_N1_);
       N2=LINELEM(i,L_N2_);
       if(N1>num)
           Y(N1,N1)=0;
           J(N1)=0;
       end
       if(N2>num)
           Y(N2,N2)=0;
           J(N2)=0;
       end
       if(N1>0) && (N2>0) 
           Y(N1,N1)=Y(N1,N1)+(0.5*t/LINELEM(i,L_VALUE_));
           Y(N1,N2)=Y(N1,N2)-(0.5*t/LINELEM(i,L_VALUE_));
           Y(N2,N1)=Y(N2,N1)-(0.5*t/LINELEM(i,L_VALUE_));
           Y(N2,N2)=Y(N2,N2)+(0.5*t/LINELEM(i,L_VALUE_));
           if(~isnan(LINELEM(i,L_IC_)))
               IL = LINELEM(i,L_IC_);
               J(N1)=J(N1)-LINELEM(i,L_IC_);
               J(N2)=J(N2)+LINELEM(i,l_IC_);
           end
       elseif(N1<0)
           Y(N2,N2)=Y(N2,N2)+(t/LINELEM(i,L_VALUE_));
           if(~isnan(LINELEM(i,L_IC_)))
               IL = LINELEM(i,L_IC_);
               J(N2)=J(N2)+LINELEM(i,L_IC_);
           end
       elseif(N2<0)
           Y(N1,N1)=Y(N1,N1)+(t/LINELEM(i,L_VALUE_));
           if(~isnan(LINELEM(i,L_IC_)))
               IL = LINELEM(i,L_IC_);
               J(N1)=J(N1)-LINELEM(i,L_IC_);
           end
       end
   end    
   %elseif(LINELEM(i,TYPE_ == C_)
end
disp(Y);
[L, U, P] = lu(Y,'vector');
temp = L \ J(P);
X = U \ temp;

for j=1:t:INFO(TSTOP_)
    for i=1:size(LINELEM,1)
        if(LINELEM(i,TYPE_) == C_)
            N1=LINELEM(i,C_N1_);
            N2=LINELEM(i,C_N2_);
            if(N1>num)
                J(N1)=0;
            end
            if(N2>num)
                J(N2)=0;
            end
            if(N1>0) && (N2>0)
                J(N1)=J(N1)-((2*X(N1)*LINELEM(i,C_VALUE_)/t)+IC);
                J(N2)=J(N2)+((2*X(N2)*LINELEM(i,C_VALUE_)/t)+IC);
            elseif(N1<0)
                J(N2)=J(N2)+((2*X(N2)*LINELEM(i,C_VALUE_)/t)+IC);
            elseif(N2<0)
                J(N1)=J(N1)-((2*X(N1)*LINELEM(i,C_VALUE_)/t)+IC);
            end
            IC = (2*X(N1)*LINELEM(i,C_VALUE_)/t)+IC;
        elseif(LINELEM(i,TYPE_) == L_)
            N1=LINELEM(i,L_N1_);
            N2=LINELEM(i,L_N2_);
            if(N1>num)
                J(N1)=0;
            end
            if(N2>num)
                J(N2)=0;
            end
            if(N1>0) && (N2>0)
                J(N1)=J(N1)-((0.5*X(N1)*t/LINELEM(i,L_VALUE_))+IL);
                J(N2)=J(N2)+((0.5*X(N1)*t/LINELEM(i,L_VALUE_))+IL);
            elseif(N1<0)
                J(N2)=J(N2)+((0.5*X(N1)*t/LINELEM(i,L_VALUE_))+IL);
            elseif(N2<0)
                J(N1)=J(N1)-((0.5*X(N1)*t/LINELEM(i,L_VALUE_))+IL);
            end
            IL = (0.5*X(N1)*t/LINELEM(i,L_VALUE_))+IL;
        end
     end
     [L, U, P] = lu(Y,'vector');
     temp = L \ J(P);
     X = U \ temp;
end
display(X);
