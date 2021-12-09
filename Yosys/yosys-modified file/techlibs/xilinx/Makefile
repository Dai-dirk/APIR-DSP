CXXFLAGS=$(shell ../../yosys-config --cxxflags)
DATDIR=$(shell ../../yosys-config --datdir)

synth_pirdsp.so: synth_pirdsp.cc
	../../yosys-config --exec --cxx $(subst $(DATDIR),../../share,$(CXXFLAGS)) --ldflags -o synth_pirdsp.so -shared synth_pirdsp.cc --ldlibs


#all: test0.log
#test0.log: synth_pirdsp.so
#	../../yosys -Ql test0.log_new -m ./synth_pirdsp.so -p 'synth_pirdsp' absval_ref.v
#	mv test0.log_new test0.log



