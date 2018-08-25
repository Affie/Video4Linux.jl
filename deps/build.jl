

# Make c library
run(`make -C v4lcapture/`)

# set linker path to library
libv4lpath = joinpath(dirname(@__FILE__),"v4lcapture")


#create a file to push to the DL_LOAD_PATH when module loads,
f = open("loadpath.jl", "w")

write(f,"# This is an automatically generated file, do not edit.\n")
write(f,"using Libdl\n")
write(f,"push!(Libdl.DL_LOAD_PATH, \"$(libv4lpath)\")")

close(f)
