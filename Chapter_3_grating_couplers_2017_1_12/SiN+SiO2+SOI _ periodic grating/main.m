clear 
clc
%% 
%% �оٳ����������У�

parameters = [];

    for Period = 1.25:0.05:1.5
        for h_sio = 1.2:0.05:2.0
            parameters = [parameters; Period h_sio];
        end
    end 

%% ��һ���������ʼ�Ļ���Ч�ʡ�
efficiency = [] ;
for  num = 1:size(parameters,1)
     
     model = mphopen('erwei_grating_coupler_2017��1��12�� ������+��������+SOI - ����.mph');
     model.param.set('Period', [num2str(parameters(num,1)) '[um]']);   %��������
     model.param.set('h_sio', [num2str(parameters(num,2)) '[um]']);   %����ݸ߶�
     model.study('std1').run;    
     
% ����Ĺ⹦�ʣ����ں�����Ч�ʼ��㣩
     in = mphglobal(model,'Powerin'); 
% �������� S11 ������ͨ������S31������ʾ��
%      R = mphglobal(model,'abs(ewfd.S11)^2'); %���ŷ�������S11������׼ȷ����������Ĺ���
%      T = mphglobal(model,'abs(ewfd.S31)^2'); %ͬ������S31���������������ڲ����й�Ĺ���
% ���Ϸ���Ĺ���
     up = mphglobal(model,'Powerup');
% ���     
     Efield = mphinterp(model,'ewfd.Ez','dataset','cln1');      
     
     angle = 8;
     overlapp = [];
     period = parameters(num,1);
     for ang = 1:size(angle,2)
      align = - period *((1:100)/5);    
      %align = align(Position);
     for i = 1: size(align,2)
         z = linspace(-10,30,size(Efield,2));
         for j = 1: size(z,2);
             Efib(j) = exp(-(((align(i)+z(j))/5.2).^2))*exp(1i*1.46*2*pi/1.55*sind(angle(ang))*z(j));  % ���
         end 
        overlap(i) =   (abs(sum (conj(Efield).*Efib)))^2 ./ (sum(abs(Efield).^2)) / sum(abs(Efib).^2) ;        
     end
       overlapp = [overlapp ; overlap];
end   
     
     
      efficiency = [efficiency; max(overlap)*up];   
      fprintf('��ʼЧ�� %d\n',max(overlap)*up)
     
 
     
end