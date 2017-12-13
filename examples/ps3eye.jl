using Images, ImageView
using Video4Linux



function displaylive!(im1, vidchan)

    A =  take!(vidchan)
    im1 = RGB.(YCbCr.(A[:,:,1], A[:,:,2], A[:,:,3]))
    imshow(canvas["gui"]["canvas"], im1)

end

# This colour mapping may be wrong for the PS3eye.
ycrcb = Video4Linux.YUYV(640,480)
vidchan = Channel((c::Channel) -> videoproducer(c, ycrcb, devicename = "/dev/video0", iomethod = Video4Linux.IO_METHOD_MMAP ))

##
#capture one frame to create im1 and canvas needed to diplay
A =  take!(vidchan)
im1 = RGB.(YCbCr.(view(A,:,:,1), view(A,:,:,2), view(A,:,:,3)))
canvas = imshow(im1)

while isopen(vidchan)
    displaylive!(im1, vidchan)
end
