ffLinux : FishVideoLinux.o  FishEyeCorrect.o
	g++ -o FishVideoLinux.o  FishEyeCorrect.o -L/home/xarkit/x86ff -lopencv_core -lopencv_highgui -lopencv_imgproc
FishVideoLinux.o:FishVideoLinux.cpp
	g++ -c FishVideoLinux.cpp -lopencv_core -L/home/xarkit/x86ff -lopencv_core -lopencv_highgui -lopencv_imgproc
FishEyeCorrect.o:FishEyeCorrect.cpp FishEyeCorrect.h
	g++ -c FishEyeCorrect.cpp -lopencv_core -L/home/xarkit/x86ff -lopencv_core -lopencv_highgui -lopencv_imgproc


