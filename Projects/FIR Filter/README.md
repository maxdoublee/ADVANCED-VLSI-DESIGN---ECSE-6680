# FIR Filter Design and Implementation
Advanced VLSI Design - Course Project | ECSE 6680 
 
## Overview

This repository hosts the low-pass FIR filter project. Central to the project is the construction of a 100-tap filter using Matlab, meticulously tuned to operate within a narrow transition region from 0.2π to 0.23π rad/sample and achieve a stopband attenuation of at least 80dB. The project not only calls for a theoretical design approach, referencing MathWorks’ extensive [documentation](https://www.mathworks.com/help/signal/ug/firfilter-design.html) for guidance, but also a hands-on hardware application using Verilog for the filter implementation. Verilog, employed alongside FPGA design tools Quartus Prime and ModelSim, translate the Matlab-designed filter into a high-performance digital circuit. 

In navigating the architectural landscape of digital filters, the project delves into advanced concepts such as pipelining to bolster data processing rates and the incorporation of reduced-complexity parallel processing for configurations L=2, balancing the trade-offs between speed and hardware resource utilization. This comprehensive documentation captures the essence of the project, detailing the rationale behind architectural choices and the intricacies of implementing an efficient FIR filter that adheres to precise performance criteria.

## Design Process

### MATLAB FIR Filter Design

My design process commenced with the specification of a 100-tap filter aimed to achieve optimal transition between passband edge of 0.2π rad/sample and stopband edge of 0.23π rad/sample, maintaining a stopband attenuation of at least 80dB. The design objective was iteratively approached by incrementally enhancing the filter's tap count, monitoring the stopband attenuation through Matlab's Frequency Response Function to ensure it met or exceeded our stringent requirement.

Utilizing Matlab's `firpm` function, which implements the Parks-McClellan algorithm, the filter coefficients were calculated and then meticulously examined for the desired frequency characteristics. A key aspect of the design process was the consideration of quantization effects on filter coefficients. To address this, I integrated a fixed-point math configuration to simulate the real-world digital signal processing environment. The coefficients were quantized to 16 bits precision, ensuring the system's practical viability when later implemented in hardware. The process also involved the use of a `fimath` object to configure properties like overflow actions and rounding methods, thereby maintaining system integrity during operations exceeding dynamic range.

As part of the verification process, I visualized the filter's frequency response with `fvtool`, providing an interactive display to analyze the filter's performance, both in its unquantized and quantized states. The analysis included observing the effects of coefficient quantization and making the necessary adjustments to tap count and weight vectors, ensuring that the filter's frequency response remained within the acceptable range of the design specifications. This iterative design process was vital for fine-tuning the filter's response to achieve the desired attenuation levels and transition bandwidth.

To facilitate a seamless transition from Matlab design to hardware implementation, the quantized filter coefficients were exported to a text file in hexadecimal format (see, [quantized_coefficients.txt](./Projects/FIR%20Filter/MATLAB/hardware_inputs/quantized_coefficients.txt)), which could then be directly utilized in Verilog code for FPGA programming. This crucial step bridges the gap between theoretical design and practical deployment, ensuring that the FIR filter design realized in Matlab could be reproduced in a hardware environment, with careful consideration given to the inherent challenges posed by quantization and fixed-point arithmetic.

Links to the mentioned MATLAB scripts, including the unquantized and quantized versions of this low-pass FIR filter:
Unquantized: [Filter_unquantized.m](./Projects/FIR%20Filter/MATLAB/design/Filter_unquantized.m)
Quantized: [Filter_quantized.m](./Projects/FIR%20Filter/MATLAB/design/Filter_quantized.m)

### Verilog Implementation

The hardware aspect of this course project was tackled through a Verilog implementation strategy, materializing the theoretical FIR filter design into a functional digital model. The `fir_filter` module encapsulates a comprehensive design that incorporates L=2 parallel processing to enhance the filter's computational efficiency, aligning with the low-pass filter specifications derived from the Matlab model. The Verilog code begins with the declaration of the module, input-output ports, and parameters like the number of taps (`N`) and coefficient bit width, reflecting the precision set in Matlab's quantization process.

During initialization, the `fir_filter` reads the quantized coefficients from a text file using `$readmemh`, which provides a seamless transition from the Matlab-generated coefficients to the Verilog simulation environment. The design employs a shift register array to hold input samples, multiplying each by its corresponding coefficient in a parallelized fashion to achieve real-time data processing. Pipeline registers (`mult_reg`) are strategically placed after multiplication stages to reduce timing delays and facilitate higher clock frequencies, adhering to the pipelined architectural approach discussed in the course.

A modular incrementation of a counter within the clock-driven processes ensures that each filter tap is appropriately addressed, while the accumulation of the products occurs in two halves (`accum_reg_half1` and `accum_reg_half2`). This division is a testament to the parallel processing architecture, allowing the filter to operate at double the speed for a given clock rate. The final output (`data_out`) is obtained by summing these two accumulative registers, effectively combining the results from parallel computations to produce the final filtered output. The entire Verilog implementation is a representation of a practical, hardware-friendly approach to digital filter design, reflecting the considerations of both performance optimization and resource management discussed in the course.

### Architecture

The architecture of the FIR filter in this project is designed to balance performance and hardware efficiency. I adopted a parallelized approach that splits the computation into two streams (L=2 parallel processing), enabling the filter to process two data points concurrently and effectively doubling the throughput compared to a non-parallelized implementation. This strategy, combined with pipelining, allows the system to maintain high data rates by staggering computations across multiple clock cycles, which is essential for meeting the real-time processing requirements of complex digital signal processing tasks.

The core architectural elements of the FIR filter include:

- **Shift Registers**: A series of registers that sequentially pass the incoming samples, ensuring that each tap can access the appropriate data point for its respective computation.

- **Coefficient Multipliers**: Parallelized multipliers that concurrently compute the product of the current data sample and the corresponding filter coefficient.

- **Accumulators**: Two sets of accumulators (one for each half of the filter in the parallelized design) that sum the products from the multipliers. The final output is obtained by combining the results from both accumulators.

- **Pipeline Registers**: Introduced post-multiplication, these registers mitigate propagation delays by breaking down the filter's operations into smaller, manageable stages, thereby allowing higher clock frequencies.

Below are the conceptual diagrams representing the architecture of our FIR filter:

- **Pipelined FIR Filter Structure**:
  
[![Pipelined FIR Filter Structure](https://www.mathworks.com/help/dsphdl/ug/fir_arch_systolic_sym.png)]

- **Parallel Processing in FIR Filter (L=2)**:
  
[![Parallel Processing in FIR Filter](https://i.stack.imgur.com/O4xUz.png)]

These diagrams offer a visual understanding of the filter's internal structure and operation flow, showcasing the data movement through the filter stages and the parallel processing of input samples.

Both pipelining and parallel processing are pivotal in the pursuit of a filter design that not only meets the desired frequency response criteria but also aligns with the pragmatic constraints of digital hardware design. The use of FPGA design tools has enabled me to efficiently translate this architecture into a synthesizable hardware model, ready for implementation and testing on actual FPGA hardware.

## Results

### MATLAB Analysis

Present the filter frequency response of the original and quantized filter. Discuss the quantization effect and overflow management strategies.

### Hardware Analysis

Summarize the hardware implementation results, including area, clock frequency, and power estimation.

## Conclusion

Provide additional analysis and draw conclusions about your project's success and potential areas for improvement.
