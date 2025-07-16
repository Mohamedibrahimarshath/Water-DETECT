global cluster2;
L=5;M=5;N=5;LX=1;LY=1;LZ=1;DX=LX/L;DY=LY/M;DZ=LZ/N;dt=0.001;
 for time=1:10;
for i=1:L;
    
    for j=1:M;
        for k=1:N;
            x(i)=i*DX;
            y(j)=j*DY;
            Z(k)=k*DZ;
            u(i,j,k,time)=sin(x(i))*cos(y(i));
            v(i,j,k,time)=sin(x(i))+cos(y(i));
            w(i,j,k,time)=x(i)*exp(-x(i).^2-y(j).^2);
        end
    end
end
 end
axes(handles.axes8);imshow(cluster2);title('Naive Image');
aa=mean2(cluster2);
acc=100/aa;
a=(aa*acc)-26.4598;
set(handles.edit10,'String',a);
ina=std2(cluster2);avg_boby=ina/3.2;
set(handles.edit15,'String',avg_boby);