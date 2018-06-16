% 保护算法

% 故障时间
fault_t = 400000;

%构造时间窗
t_begin = fault_t - 2000;
t_end = fault_t + 5999;

% 选取三相行波信号
signals = load('abc.out');
fault_Ia = signals(t_begin:t_end,2);
fault_Ib = signals(t_begin:t_end,3);
fault_Ic = signals(t_begin:t_end,4);  
% 模量变换
I_alpha = (fault_Ia - fault_Ib)/3;
I_beta = (fault_Ia + fault_Ic)/3;
I_gamma = (fault_Ib - fault_Ic)/3;
I_0 = (fault_Ia + fault_Ib + fault_Ic)/3;


% 小波变换
scale = 4;
[SWD_0, ~] = wvt(I_0, scale);
[SWD_alpga, ~] = wvt(I_alpha, scale);
[SWD_beta, ~] = wvt(I_beta, scale);
[SWD_gamma, ~] = wvt(I_gamma, scale);


figure(1)
level = scale + 1;
for i = 1:level
    subplot(level,1,i);
    plot(SWD_0(i,:))
end

 for i=2:level
subplot(level,1,i)
title(['第',num2str(i-1),'尺度下小波变换'])
 end

subplot(level,1,1)
title('原信号: 0模')

figure(2)
level = scale + 1;
for i = 1:level
    subplot(level,1,i);
    plot(SWD_alpga(i,:))
end

 for i=2:level
subplot(level,1,i)
title(['第',num2str(i-1),'尺度下小波变换'])
 end

subplot(level,1,1)
title('原信号: alpha模')

figure(3)
level = scale + 1;
for i = 1:level
    subplot(level,1,i);
    plot(SWD_beta(i,:))
end

 for i=2:level
subplot(level,1,i)
title(['第',num2str(i-1),'尺度下小波变换'])
 end

subplot(level,1,1)
title('原信号: beta模')

figure(4)
level = scale + 1;
for i = 1:level
    subplot(level,1,i);
    plot(SWD_gamma(i,:))
end

 for i=2:level
subplot(level,1,i)
title(['第',num2str(i-1),'尺度下小波变换'])
 end

subplot(level,1,1)
title('原信号: gamma模')