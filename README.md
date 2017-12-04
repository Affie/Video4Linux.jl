# Video4Linux

The aim of this package is to provide lower level access to the v4l2 driver for raw data manipulation. As much as possible should be implemented in Julia.
This is work in progress and any suggestions and contributions are very welcome.  


[![Build Status](https://travis-ci.org/affie/Video4Linux.jl.svg?branch=master)](https://travis-ci.org/affie/Video4Linux.jl)

[![Coverage Status](https://coveralls.io/repos/affie/Video4Linux.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/affie/Video4Linux.jl?branch=master)

[![codecov.io](http://codecov.io/github/affie/Video4Linux.jl/coverage.svg?branch=master)](http://codecov.io/github/affie/Video4Linux.jl?branch=master)


## Kinect Example
Currently the only camera tested is the Kenect using the kernel driver.  
This example was run on an raspberry pi 3 with Rasbian and julia 0.6.   
The kenect driver can be set to depth mode with:
`sudo rmmod gspca_kinect`
`sudo modprobe gspca_kinect depth_mode = 1`
![kenect depth image](docs/depthonpi.png)
