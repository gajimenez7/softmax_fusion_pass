include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if(MSVC)
	add_compile_options(/GR-)
else()
	add_compile_options(-fno-rtti)
endif()

add_library(SoftmaxFusionPass STATIC
  SoftmaxFusion.cpp
)

target_link_libraries(SoftmaxFusionPass PUBLIC
  MLIRAffineUtils
  MLIRAffineDialect
  MLIRFuncDialect
  MLIRIR
  MLIRPass
)

add_executable(softmax-opt
  driver/SoftmaxOptTool.cpp
)

target_link_libraries(softmax-opt PRIVATE
	SoftmaxFusionPass
  MLIRMlirOptMain
	MLIRAffineDialect
	MLIRAffineAnalysis
	MLIRAffineTransforms
	MLIRFuncDialect
	MLIRMemRefDialect
	MLIRSCFDialect
	MLIRArithDialect
	MLIRMathDialect
	MLIRTransforms
	MLIRDLTIDialect
	MLIRLLVMDialect
)
