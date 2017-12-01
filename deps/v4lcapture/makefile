
RM := rm -rf


C_SRCS := \
/src/v4lcapture.c

OBJS := \
build/v4lcapture.o

C_DEPS := \
build/v4lcapture.d

#

build/%.o: src/%.c
	mkdir -p build
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O3 -Wall -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


# All Target
all: libv4lcapture.so

# Tool invocations
libv4lcapture.so: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	gcc -shared -o "libv4lcapture.so" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(LIBRARIES)$(OBJS)$(C_DEPS) libv4lcapture.so
	-@echo ' '

.PHONY: all clean dependents
