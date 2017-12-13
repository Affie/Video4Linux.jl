/*
 * v3lcapture.c
 *
 *  Created on: 29 Nov 2017
 *      Author: Johannes Terblanche
 *      Created from v4lcapture example
 * 	https://linuxtv.org/docs.php for more information
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <getopt.h>             /* getopt_long() */

#include <fcntl.h>              /* low-level i/o */
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include <linux/videodev2.h>

#include "v4lcapture.h"


#define CLEAR(x) memset(&(x), 0, sizeof(x))

enum io_method {
        IO_METHOD_READ,
        IO_METHOD_MMAP,
        IO_METHOD_USERPTR,
};

struct buffer {
        void   *start;
        size_t  length;
        unsigned int width;
        unsigned int height;
        unsigned int pixelformat;
};


static enum io_method   io = IO_METHOD_MMAP;
//static
struct buffer          *buffers;
static unsigned int     n_buffers;


static void errno_display(const char *s)
{
        fprintf(stderr, "%s error %d, %s\\n", s, errno, strerror(errno));

}

static int xioctl(int fh, int request, void *arg)
{
        int r;

        do {
                r = ioctl(fh, request, arg);
        } while (-1 == r && EINTR == errno);

        return r;
}


static int read_frame(int fd)
{
        struct v4l2_buffer buf;
        unsigned int i;

        switch (io) {
        case IO_METHOD_READ:
                if (-1 == read(fd, buffers[0].start, buffers[0].length)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_display("read");
                                return -1;
                                break;
                        }
                }
                // process_image(buffers[0].start, buffers[0].length);
                fprintf(stderr, "bytes: %lu\n",  buffers[0].length);
                break;

        case IO_METHOD_MMAP:
                CLEAR(buf);

                buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory = V4L2_MEMORY_MMAP;

                if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_display("VIDIOC_DQBUF");
                                return -1;
                                break;
                        }
                }

                assert(buf.index < n_buffers);

                // process_image(buffers[buf.index].start, buf.bytesused);
                fprintf(stderr, "bytes: %d\n",  buf.bytesused);

                if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)){
                        errno_display("VIDIOC_QBUF");
                        return -1;
                }
                break;

        case IO_METHOD_USERPTR:
                CLEAR(buf);

                buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory = V4L2_MEMORY_USERPTR;

                if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_display("VIDIOC_DQBUF");
                                return -1;
                                break;
                        }
                }

                for (i = 0; i < n_buffers; ++i)
                        if (buf.m.userptr == (unsigned long)buffers[i].start
                            && buf.length == buffers[i].length)
                                break;

                assert(i < n_buffers);

                // process_image((void *)buf.m.userptr, buf.bytesused);
                fprintf(stderr, "bytes: %d\n",  buf.bytesused);

                if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)){
                        errno_display("VIDIOC_QBUF");
                        return -1;
                }
                break;
        }

        return 1;
}

int mainloop(int fd, int frame_count)
{
        unsigned int count;
        int read_frame_status;

        count = frame_count;

        while (count-- > 0) {
                for (;;) {
                        fd_set fds;
                        struct timeval tv;
                        int r;

                        FD_ZERO(&fds);
                        FD_SET(fd, &fds);

                        /* Timeout. */
                        tv.tv_sec = 2;
                        tv.tv_usec = 0;

                        r = select(fd + 1, &fds, NULL, NULL, &tv);

                        if (-1 == r) {
                                if (EINTR == errno)
                                        continue;
                                errno_display("select");
                                return EXIT_FAILURE;
                        }

                        if (0 == r) {
                                fprintf(stderr, "select timeout\\n");
                                return EXIT_FAILURE;
                        }

                        read_frame_status = read_frame(fd);
                        //read was sucsessfull, break from for
                        if (read_frame_status == 1)
                                break;
                        //something went wrong, return
                        else if (read_frame_status == -1)
                                return EXIT_FAILURE;

                        /* EAGAIN - continue select loop. */
                }
        }
        return EXIT_SUCCESS;
}

int stop_capturing(int fd)
{
        enum v4l2_buf_type type;

        switch (io) {
        case IO_METHOD_READ:
                /* Nothing to do. */
                break;

        case IO_METHOD_MMAP:
        case IO_METHOD_USERPTR:
                type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                if (-1 == xioctl(fd, VIDIOC_STREAMOFF, &type)){
                        errno_display("VIDIOC_STREAMOFF");
                        return EXIT_FAILURE;
                }
                break;
        }

        return EXIT_SUCCESS;
}

int start_capturing(int fd)
{
        unsigned int i;
        enum v4l2_buf_type type;

        switch (io) {
        case IO_METHOD_READ:
                /* Nothing to do. */
                break;

        case IO_METHOD_MMAP:
                for (i = 0; i < n_buffers; ++i) {
                        struct v4l2_buffer buf;

                        CLEAR(buf);
                        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                        buf.memory = V4L2_MEMORY_MMAP;
                        buf.index = i;

                        if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)){
                                errno_display("VIDIOC_QBUF");
                                return EXIT_FAILURE;
                        }
                }
                type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                if (-1 == xioctl(fd, VIDIOC_STREAMON, &type)){
                        errno_display("VIDIOC_STREAMON");
                        return EXIT_FAILURE;
                }
                break;

        case IO_METHOD_USERPTR:
                for (i = 0; i < n_buffers; ++i) {
                        struct v4l2_buffer buf;

                        CLEAR(buf);
                        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                        buf.memory = V4L2_MEMORY_USERPTR;
                        buf.index = i;
                        buf.m.userptr = (unsigned long)buffers[i].start;
                        buf.length = buffers[i].length;

                        if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)){
                                errno_display("VIDIOC_QBUF");
                                return EXIT_FAILURE;
                        }
                }
                type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                if (-1 == xioctl(fd, VIDIOC_STREAMON, &type)){
                        errno_display("VIDIOC_STREAMON");
                        return EXIT_FAILURE;
                }
                break;
        }
        return EXIT_SUCCESS;
}


int uninit_device(void)
{
        unsigned int i;

        switch (io) {
        case IO_METHOD_READ:
                free(buffers[0].start);
                break;

        case IO_METHOD_MMAP:
                for (i = 0; i < n_buffers; ++i)
                        if (-1 == munmap(buffers[i].start, buffers[i].length)){
                                errno_display("munmap");
                                return EXIT_FAILURE;
                        }
                break;

        case IO_METHOD_USERPTR:
                for (i = 0; i < n_buffers; ++i)
                        free(buffers[i].start);
                break;
        }

        free(buffers);

        return EXIT_SUCCESS;
}

static int init_read(unsigned int buffer_size)
{
        buffers = calloc(1, sizeof(*buffers));

        if (!buffers) {
                fprintf(stderr, "Out of memory\\n");
                return EXIT_FAILURE;
        }

        buffers[0].length = buffer_size;
        buffers[0].start = malloc(buffer_size);

        if (!buffers[0].start) {
                fprintf(stderr, "Out of memory\\n");
                return EXIT_FAILURE;
        }

        return EXIT_SUCCESS;
}

static int init_mmap(int fd)
{
        struct v4l2_requestbuffers req;

        CLEAR(req);

        req.count = 4;
        req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        req.memory = V4L2_MEMORY_MMAP;

        if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
                if (EINVAL == errno) {
                        fprintf(stderr, "Dev does not support "
                                 "memory mappingn");
                        return EXIT_FAILURE;
                } else {
                        errno_display("VIDIOC_REQBUFS");
                        return EXIT_FAILURE;
                }
        }

        if (req.count < 2) {
                fprintf(stderr, "Insufficient buffer memory on dev\n");
                return EXIT_FAILURE;
        }

        buffers = calloc(req.count, sizeof(*buffers));

        if (!buffers) {
                fprintf(stderr, "Out of memory\n");
                return EXIT_FAILURE;
        }

        for (n_buffers = 0; n_buffers < req.count; ++n_buffers) {
                struct v4l2_buffer buf;

                CLEAR(buf);

                buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory      = V4L2_MEMORY_MMAP;
                buf.index       = n_buffers;

                if (-1 == xioctl(fd, VIDIOC_QUERYBUF, &buf))
                {
                        errno_display("VIDIOC_QUERYBUF");
                        return EXIT_FAILURE;
                }
                buffers[n_buffers].length = buf.length;
                buffers[n_buffers].start =
                        mmap(NULL /* start anywhere */,
                              buf.length,
                              PROT_READ | PROT_WRITE /* required */,
                              MAP_SHARED /* recommended */,
                              fd, buf.m.offset);

                if (MAP_FAILED == buffers[n_buffers].start)
                {
                        errno_display("mmap");
                        return EXIT_FAILURE;
                }
        }
        return EXIT_SUCCESS;
}

static int init_userp(unsigned int buffer_size, int fd)
{
        struct v4l2_requestbuffers req;

        CLEAR(req);

        req.count  = 4;
        req.type   = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        req.memory = V4L2_MEMORY_USERPTR;

        if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
                if (EINVAL == errno) {
                        fprintf(stderr, "Device does not support "
                                 "user pointer i/on");
                        return EXIT_FAILURE;
                } else {
                        errno_display("VIDIOC_REQBUFS");
                        return EXIT_FAILURE;
                }
        }

        buffers = calloc(4, sizeof(*buffers));

        if (!buffers) {
                fprintf(stderr, "Out of memory\n");
                return EXIT_FAILURE;
        }

        for (n_buffers = 0; n_buffers < 4; ++n_buffers) {
                buffers[n_buffers].length = buffer_size;
                buffers[n_buffers].start = malloc(buffer_size);

                if (!buffers[n_buffers].start) {
                        fprintf(stderr, "Out of memory\n");
                        return EXIT_FAILURE;
                }
        }

        return EXIT_SUCCESS;
}

int init_device(int fd, int force_format)
{
        struct v4l2_capability cap;
        struct v4l2_cropcap cropcap;
        struct v4l2_crop crop;
        struct v4l2_format fmt;
        unsigned int min;

        if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
                if (EINVAL == errno) {
                        fprintf(stderr, "Device is no V4L2 device\n");
                        return EXIT_FAILURE;
                } else {
                        errno_display("VIDIOC_QUERYCAP");
                        return EXIT_FAILURE;
                }
        }

        if (!(cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)) {
                fprintf(stderr, "Device is no video capture device\n");
                return EXIT_FAILURE;
        }

        switch (io) {
        case IO_METHOD_READ:
                if (!(cap.capabilities & V4L2_CAP_READWRITE)) {
                        fprintf(stderr, "Device does not support read i/o\n");
                        return EXIT_FAILURE;
                }
                break;

        case IO_METHOD_MMAP:
        case IO_METHOD_USERPTR:
                if (!(cap.capabilities & V4L2_CAP_STREAMING)) {
                        fprintf(stderr, "Device does not support streaming i/o\n");
                        return EXIT_FAILURE;
                }
                break;
        }


        /* Select video input, video standard and tune here. */


        CLEAR(cropcap);

        cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

        if (0 == xioctl(fd, VIDIOC_CROPCAP, &cropcap)) {
                crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                crop.c = cropcap.defrect; /* reset to default */

                if (-1 == xioctl(fd, VIDIOC_S_CROP, &crop)) {
                        switch (errno) {
                        case EINVAL:
                                /* Cropping not supported. */
                                break;
                        default:
                                /* Errors ignored. */
                                break;
                        }
                }
        } else {
                /* Errors ignored. */
        }


        CLEAR(fmt);

        fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (force_format) {
                fmt.fmt.pix.width       = 640;
                fmt.fmt.pix.height      = 480;
                fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
                fmt.fmt.pix.field       = V4L2_FIELD_INTERLACED;

                if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmt)){
                        errno_display("VIDIOC_S_FMT");
                        return EXIT_FAILURE;
                }

                /* Note VIDIOC_S_FMT may change width and height. */
        } else {
                /* Preserve original settings as set by v4l2-ctl for example */
                if (-1 == xioctl(fd, VIDIOC_G_FMT, &fmt)){
                        errno_display("VIDIOC_G_FMT");
                        return EXIT_FAILURE;
                }
        }


        /* Buggy driver paranoia. */
        min = fmt.fmt.pix.width * 2;
        if (fmt.fmt.pix.bytesperline < min)
                fmt.fmt.pix.bytesperline = min;
        min = fmt.fmt.pix.bytesperline * fmt.fmt.pix.height;
        if (fmt.fmt.pix.sizeimage < min)
                fmt.fmt.pix.sizeimage = min;

        switch (io) {
        case IO_METHOD_READ:
                if (EXIT_SUCCESS == init_read(fmt.fmt.pix.sizeimage)){
                        // set pixel information on buffer[0]
                        buffers[0].width = fmt.fmt.pix.width;
                        buffers[0].height = fmt.fmt.pix.height;
                        buffers[0].pixelformat = fmt.fmt.pix.pixelformat;
                        return EXIT_SUCCESS;
                }
                else
                        return EXIT_FAILURE;
                break;

        case IO_METHOD_MMAP:
                if (EXIT_SUCCESS == init_mmap(fd)){
                        // set pixel information on buffer[0]
                        buffers[0].width = fmt.fmt.pix.width;
                        buffers[0].height = fmt.fmt.pix.height;
                        buffers[0].pixelformat = fmt.fmt.pix.pixelformat;
                        return EXIT_SUCCESS;
                }
                else
                        return EXIT_FAILURE;
                break;

        case IO_METHOD_USERPTR:
                return init_userp(fmt.fmt.pix.sizeimage, fd);
                break;
        default:
                return EXIT_FAILURE;
                break;
        }


}

int close_device(int fd)
{
        if (-1 == close(fd)){
                errno_display("close");
                return -1;
        }
        else
                return 0;


}

int open_device(char *dev_name)
{
        struct stat st;
        int fd;

        if (-1 == stat(dev_name, &st)) {
                fprintf(stderr, "Cannot identify '%s': %d, %s\\n",
                         dev_name, errno, strerror(errno));
                return -1;
        }

        if (!S_ISCHR(st.st_mode)) {
                fprintf(stderr, "%s is no devicen", dev_name);
                return -1;
        }

        fd = open(dev_name, O_RDWR /* required */ | O_NONBLOCK, 0);

        if (-1 == fd) {
                fprintf(stderr, "Cannot open '%s': %d, %s\\n",
                         dev_name, errno, strerror(errno));
                return -1;
        }
        return fd;
}


void set_io_method(int io_method_int){
	switch (io_method_int) {
		case 0:
			io = IO_METHOD_READ;
			break;
		case 1:
			io = IO_METHOD_MMAP;
			break;
		case 2:
			io = IO_METHOD_USERPTR;
			break;
		default:
			io = IO_METHOD_READ;
			break;
	}
}

void test_stringin(char * stringin)
{
	fprintf(stderr, "String %s", stringin);
}
