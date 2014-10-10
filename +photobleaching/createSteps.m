function [ out_vec ] = createSteps()
%CREATESTEPS Summary of this function goes here
%   Detailed explanation goes here

out_vec = zeros([1,100]);

for i=1:100
   if i<40
      out_vec(i) = 0.9; 
   else
      out_vec(i) = 0.1;
   end
end

% Create 100-elt vector to represent signal.
% for i=1:100
%     if i<20
%         out_vec(i) = 1;
%     elseif i<22
%         out_vec(i) = 0.95;
%     elseif i<24
%         out_vec(i) = 0.9;
%     elseif i<26
%         out_vec(i) = 0.85;
%     elseif i<28
%         out_vec(i) = 0.8;
%     elseif i<50
%         out_vec(i) = 0.75;
%     elseif i<60
%         out_vec(i) = 0.65;
%     elseif i<70
%         out_vec(i) = 0.55;
%     elseif i<90
%         out_vec(i) = 0.5;
%     else
%         out_vec(i) = 0.25;
%     end
% end

out_vec = awgn(out_vec,45);

end

