using Images, ImageView
using Video4Linux


#create a display function that consumes the video on channel vidchan
function displayliveYonly!(im1, vidchan)

    im1[:] = reinterpret(Gray{N0f8},take!(vidchan))
    imshow(canvas["gui"]["canvas"], im1)

end


##
#Creaete Y component only 4:2:2 decoder type
yonly = Video4Linux.UYVYonlyY(640,480)
#yonly = Video4Linux.YUYVonlyY(640,480)
# create a videoproducer type channel (will only run 100 frames)
vidchan = Channel((c::Channel) -> videoproducer(c, yonly, devicename = "/dev/video0", iomethod = Video4Linux.IO_METHOD_READ))

##
#capture one frame to create im1 and canvas needed to diplay
im1 = reinterpret(Gray{N0f8},take!(vidchan))
canvas = imshow(im1)

##

# run untul channel is closed (100 frames of vidchan)
while isopen(vidchan)
    @time displayliveYonly!(im1, vidchan)
end


################################################################################
#full color 4:2:2

function displaylive!(im1, vidchan)

    A =  take!(vidchan)
    im1 = RGB.(YCbCr.(A[:,:,1], A[:,:,2], A[:,:,3]))
    imshow(canvas["gui"]["canvas"], im1)

end

ycrcb = Video4Linux.UYVY(640,480)
# ycrcb = Video4Linux.YUYV(640,480)

vidchan = Channel((c::Channel) -> videoproducer(c, ycrcb, devicename = "/dev/video0", iomethod = Video4Linux.IO_METHOD_READ))

##
#capture one frame to create im1 and canvas needed to diplay
A =  take!(vidchan)
im1 = RGB.(YCbCr.(A[:,:,1], A[:,:,2], A[:,:,3]))
canvas = imshow(im1)

##

# run untul channel is closed (100 frames of vidchan)
while isopen(vidchan)
    @time displaylive!(im1, vidchan)
end


################################################################################
#10bit packed


function displaylive10bit!(im1, vidchan)
    im1 = take!(vidchan)
    imshow(canvas["gui"]["canvas"], im1)

end

y10b = Video4Linux.Y10B(640,480)
vidchan = Channel((c::Channel) -> videoproducer(c, y10b), devicename = "/dev/video0")

##
#capture one frame to create im1 and canvas needed to diplay
im1 = take!(vidchan)
canvas = imshow(im1)

##

# run untul channel is closed (100 frames of vidchan)
while isopen(vidchan)
    @time displaylive10bit!(im1, vidchan)
end
