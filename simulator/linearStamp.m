function [Y,J,num,Voltages,location] = linearStamp(LIN,NLN,NODES,INFO,Y,J,num)
parser_init;
location = zeros(size(LIN(:,1),1),1);
k = 1; %counter for voltage sources
Voltages=zeros(1,size(0:INFO(TSTEP_):INFO(TSTOP_),2));
    for i=1:size(LIN(:,1))
        %stamping the resistor component into Y matrix
       if(LIN(i,TYPE_) == R_)
          N1=LIN(i,R_N1_);
          N2=LIN(i,R_N2_);
          [N1,N2]= checkNode(NODES,N1,N2);
          
          if(N1>0)
              Y(N1,N1) = Y(N1,N2) + 1/LIN(i,R_VALUE_);
          end
          if(N2>0)
              Y(N2,N2) = Y(N1,N2) + 1/LIN(i,R_VALUE_);
          end
          if(N1>0 && N2>0)
              Y(N1,N2) = Y(N1,N2) - 1/LIN(i,R_VALUE_);
              Y(N2,N1) = Y(N2,N1) - 1/LIN(i,R_VALUE_);
          end
       
       %stamping independent current source into J vector
       elseif(LIN(i,TYPE_) == I_)
          N1=LIN(i,I_N1_);
          N2=LIN(i,I_N2_);
          [N1,N2]= checkNode(NODES,N1,N2);
          
          if(N1>0)
              J(N1) = J(N1) - LIN(i,I_VALUE_);
          end
          if(N2>0)
              J(N2) = J(N2) + LIN(i,I_VALUE_);
          end
          
       %stamping independent voltage source into Y matrix and J vector   
       elseif(LIN(i,TYPE_) == V_)
          N1=LIN(i,V_N1_);
          N2=LIN(i,V_N2_);
          [N1,N2]= checkNode(NODES,N1,N2);
          
          num = num+1;
          J(num) = LIN(i,V_VALUE_);
          
          if(N1>0)
              Y(num,N1) = 1;
              Y(N1,num) = 1;
          end
          if(N2>0)
              Y(num,N2) = -1;
              Y(N2,num) = -1;
          end
          
          if(LIN(i,V_POINTS_)>0 && LIN(i,V_TYPE_)==PWL_)
             location(i)=num;
             xdata = zeros(LIN(i,V_POINTS_)+2,1);
             xdata(1) =  LIN(i,V_VALUE_);
             tdata = zeros(LIN(i,V_POINTS_)+2,1);
             tdata(size(tdata,1)) = INFO(TSTOP_);
             for j=1:LIN(i,V_POINTS_)
                xdata(j+1) = LIN(i,V_POINTS_+2*j);
                tdata(j+1) = LIN(i,V_POINTS_+2*j-1);
             end
             t= 0:INFO(TSTEP_):INFO(TSTOP_);
            
             [~,index] = unique(xdata);
             duplicates = setdiff(1:numel(xdata),index);
             for j=1:size(duplicates,2)
                xdata(duplicates(j))= xdata(duplicates(j))+1e-6*rand; 
             end
             Voltages(k,:) = interp1(tdata,xdata,t);
             k = k+1;
          end
          
       % stamping voltage controlled current source    
      elseif(LIN(i,TYPE_) == G_)
          N1=LIN(i,G_N1_);
          N2=LIN(i,G_N2_);
          CN1=LIN(i,G_CN1_);
          CN2=LIN(i,G_CN2_);
          [N1,N2]= checkNode(NODES,N1,N2);
          [CN1,CN2]= checkNode(NODES,CN1,CN2);
          
          if(N1>0 && CN1>0)
              Y(CN1,N1)=Y(CN1,N1)+LIN(i,G_VALUE_);
          end
          if(N2>0 && CN2>0)
              Y(CN1,N2)=Y(CN1,N2)-LIN(i,G_VALUE_);
          end
          if(CN1>0 && N2>0)
              Y(CN1,N2)=Y(CN1,N2)-LIN(i,G_VALUE_);
          end
          if(N1>0 && CN2>0)
              Y(CN2,N1)=Y(CN2,N1)-LIN(i,G_VALUE_);
          end
      
      %stamping current controlled current sources
      elseif(LIN(i,TYPE_) == F_)
          N1=LIN(i,F_N1_);
          N2=LIN(i,F_N2_);
          if(F_SOURCE_MAT_==1)
              CN1=LIN(F_SOURCE_IND_,3);
              CN2=LIN(F_SOURCE_IND_,4);
          elseif(F_SOURCE_MAT_==2)
              CN1=NLN(F_SOURCE_IND_,3);
              CN2=NLN(F_SOURCE_IND_,4);
          end
          [N1,N2]= checkNode(NODES,N1,N2);
          [CN1,CN2]= checkNode(NODES,CN1,CN2);
          
          num = num+1;
          %location(i)=num;
          J(num) = 0;
          
          if(N1>0)
              Y(N1,num) = LIN(i,F_VALUE_);
          end
          if(CN1>0)
              Y(CN1,num)=1;
              Y(num,CN1)=1;
          end
          if(N2>0)
              Y(N2,num) = -1*LIN(i,F_VALUE_);
          end
          if(CN2>0)
              Y(CN2,num)=-1;
              Y(num,CN2)=-1;
          end
       
      %stamping Voltage controlled voltage source    
      elseif(LIN(i,TYPE_) == E_)
          N1=LIN(i,E_N1_);
          N2=LIN(i,E_N2_);
          CN1=LIN(i,E_CN1_);
          CN2=LIN(i,E_CN2_);
          [N1,N2]= checkNode(NODES,N1,N2);
          [CN1,CN2]= checkNode(NODES,CN1,CN2);
          
          num=num+1;
          J(num)=0;
          
          if(CN1>0)
              Y(num,CN1)=-LIN(i,E_VALUE_);
              Y(CN1,num)=1;
          end
          if(N1>0)
              Y(num,N1)=1;
          end
          if(CN2>0)
              Y(num,CN2)=LIN(i,E_VALUE_);
              Y(CN2,num)=-1;
          end
          if(N2>0)
              Y(num,N2)=-1;
          end
       
      %stamping current controlled voltage source    
      elseif(LIN(i,TYPE_) == H_)
          N1=LIN(i,H_N1_);
          N2=LIN(i,H_N2_);
          if(H_SOURCE_MAT_==1)
              CN1=LIN(H_SOURCE_IND_,3);
              CN2=LIN(H_SOURCE_IND_,4);
          elseif(H_SOURCE_MAT_==2)
              CN1=NLN(H_SOURCE_IND_,3);
              CN2=LIN(H_SOURCE_IND_,4);
          end
          [N1,N2]= checkNode(NODES,N1,N2);
          [CN1,CN2]= checkNode(NODES,CN1,CN2);
          
          num = num+2;
          Y(num,num-1)=-LIN(i,H_VALUE_);
          J(num-1)=0;
          J(num)=0;
          
          if(N1>0)
              Y(num-1,N1)=1;
              Y(N1,num)=1;
          end
          if(CN1>0)
              Y(num-1,CN1)=1;
              Y(CN1,num-1)=1;
          end
          if(N2>0)
              Y(num-1,N2)=-1;
              Y(N2,num)=-1;
          end
          if(CN2>0)
              Y(num-1,CN2)=-1;
              Y(CN2,num-1)=-1;
          end
       end
    end
end

        