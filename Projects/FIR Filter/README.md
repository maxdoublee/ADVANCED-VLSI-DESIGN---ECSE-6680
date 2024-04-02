# FIR Filter Design and Implementation
Advanced VLSI Design - Course Project | ECSE 6680 
 
## Overview

This repository hosts the low-pass FIR filter project. Central to the project is the construction of a 100-tap filter using Matlab, meticulously tuned to operate within a narrow transition region from 0.2π to 0.23π rad/sample and achieve a stopband attenuation of at least 80dB. The project not only calls for a theoretical design approach, referencing MathWorks’ extensive [documentation](https://www.mathworks.com/help/signal/ug/fir-filter-design.html) for guidance, but also a hands-on hardware application using Verilog for the filter implementation. Verilog, employed alongside FPGA design tools Quartus Prime and ModelSim, translate the Matlab-designed filter into a high-performance digital circuit. 

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

<img src="https://www.mathworks.com/help/dsphdl/ug/fir_arch_systolic_sym.png" width="300">
![Pipelined FIR Filter Structure](https://www.mathworks.com/help/dsphdl/ug/fir_arch_systolic_sym.png)

- **Parallel Processing in FIR Filter (L=2)**:

<img src="https://i.stack.imgur.com/O4xUz.png" width="300">
![Parallel Processing in FIR Filter](https://i.stack.imgur.com/O4xUz.png)

These diagrams offer a visual understanding of the filter's internal structure and operation flow, showcasing the data movement through the filter stages and the parallel processing of input samples.

Both pipelining and parallel processing are pivotal in the pursuit of a filter design that not only meets the desired frequency response criteria but also aligns with the pragmatic constraints of digital hardware design. The use of FPGA design tools has enabled me to efficiently translate this architecture into a synthesizable hardware model, ready for implementation and testing on actual FPGA hardware.

## Results

### MATLAB Analysis

The primary objective of the MATLAB analysis was to assess the impact of quantization on a 100-tap low-pass FIR filter. The impulse responses for both the unquantized and quantized filters are presented in Figures 5 and 6. These figures visually represent the inherent differences in the filter's reaction to a delta function input. The response's spread and magnitude clearly depict the smoothing effect that quantization imparts on the system.

![Impulse Response (Unquantized)](path-to-impulse-response-unquantized.png)
*Figure 5: Impulse Response (Unquantized)*

![Impulse Response (Quantized)](path-to-impulse-response-quantized.png)
*Figure 6: Impulse Response (Quantized)*

Figures 7 and 8 offer a deeper look into the frequency domain, contrasting the original and quantized filters. The transition band between the passband and stopband is of particular interest, showing the effect of quantization on the filter's sharpness and roll-off characteristics. A narrower transition band correlates with higher filter order and complexity, providing a critical comparison point for the two implementations.

![Magnitude and Phase Response (Unquantized)](path-to-magnitude-phase-response-unquantized.png)
*Figure 7: Magnitude and Phase Response (Unquantized)*

![Magnitude and Phase Response (Quantized)](path-to-magnitude-phase-response-quantized.png)
*Figure 8: Magnitude and Phase Response (Quantized)*

The quantization of filter coefficients can lead to precision loss, which can accumulate and cause signal distortion. To manage this, techniques such as increased word length and dithering were applied. These techniques helped maintain the overall filter performance within acceptable limits by reducing quantization noise and overflow errors.

#### SNR and ENOB Testing

The Signal-to-Noise Ratio (SNR) and Effective Number of Bits (ENOB) tests provide a quantitative measure of the filter's performance, with the ENOB offering insight into the resolution of the filter's digital representation. 

| SNR (dB) | Unquantized Filter | Quantized Filter |
|----------|---------------------|------------------|
| ENOB (bits) | 0.56 | 0.58 |

#### Dynamic Range Testing

The dynamic range tests were conducted to observe the SNR over a range of signal amplitudes. This test is crucial as it informs about the filter's capability to handle various signal strengths without significant performance degradation, especially in the presence of quantization.

| Amplitude | Unquantized SNR (dB) | Quantized SNR (dB) |
|-----------|-----------------------|--------------------|
| 0.01      | 0.31                  | 0.29               |
| ...       | ...                   | ...                |
| 1.00      | 0.95                  | 0.97               |

#### Sweeping Signal Frequency

Sweeping signal frequency analysis further elucidates the filter's ability to maintain performance over a spectrum of frequencies. This provides valuable insights into the filter's stability and adaptability to frequency changes, reflecting the robustness of the design.

| Frequency (Hz) | Unquantized SNR (dB) | Quantized SNR (dB) |
|----------------|-----------------------|--------------------|
| 4800.00        | 1.29                  | 1.30               |
| ...            | ...                   | ...                |
| 5520.00        | 5.42                  | 5.46               |

#### Harmonic Distortion Analysis (THD)

Total Harmonic Distortion (THD) analysis is a critical metric for evaluating the linearity and accuracy of the filter. Lower THD values indicate a more accurate reproduction of the input signal without harmonic distortion, which is desired in high-fidelity systems.

| Filter Type    | THD (dB)      |
|----------------|---------------|
| Unquantized    | -297.13       |
| Quantized      | -297.11       |

#### Overflow Testing

Overflow testing is indicative of how well the system handles the digital signal's amplitude without inducing clipping or saturation. Properly managing the dynamic range is essential to prevent overflow, ensuring the filter's output remains within the bounds of the system's representational limits.

| Parameter                        | Unquantized       | Quantized         |
|----------------------------------|-------------------|-------------------|
| Maximum Output Amplitude         | 37785.84          | 37779.91          |
| Minimum Output Amplitude         | -                 | -37779.91         |
| Peak-to-Peak Amplitude           | 75559.815912      | 75559.815912      |

The detailed analysis conducted in MATLAB served as a decisive phase, critically informing the subsequent hardware implementation stages. The insight gained


### Hardware Analysis

Summarize the hardware implementation results, including area, clock frequency, and power estimation.

## Conclusion

Provide additional analysis and draw conclusions about your project's success and potential areas for improvement.

## Reference Links


