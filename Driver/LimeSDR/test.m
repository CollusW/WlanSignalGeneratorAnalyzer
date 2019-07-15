%   (1) Open a device handle:
 
    dev = limeSDR(); % Open device
 
%   (2) Setup device parameters. These may be changed while the device
%       is actively streaming.
 
    dev.rx0.frequency  = 1000e6;
    dev.rx0.samplerate = 5e6;
    dev.rx0.gain = 30;
    dev.rx0.antenna = 2;
 
%   (3) Enable stream parameters. These may NOT be changed while the device
%       is streaming.
 
    dev.rx0.enable;
 
%   (4) Start the module
 
    dev.start();
 
%   (5) Receive 5000 samples on RX0 channel
 
   samples = dev.receive(5000,0);
 
%   (6) Cleanup and shutdown by stopping the RX stream and having MATLAB
%       delete the handle object.
 
   dev.stop();
   clear dev;