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

<img src="https://www.mathworks.com/help/dsphdl/ug/fir_arch_systolic_sym.png" width="1000">

- **Parallel Processing in FIR Filter (L=2)**:

<img src="https://i.stack.imgur.com/O4xUz.png" width="1000">

These diagrams offer a visual understanding of the filter's internal structure and operation flow, showcasing the data movement through the filter stages and the parallel processing of input samples.

Both pipelining and parallel processing are pivotal in the pursuit of a filter design that not only meets the desired frequency response criteria but also aligns with the pragmatic constraints of digital hardware design. The use of FPGA design tools has enabled me to efficiently translate this architecture into a synthesizable hardware model, ready for implementation and testing on actual FPGA hardware.

## Results

### MATLAB Analysis

The primary objective of this MATLAB analysis was to assess the impact of quantization on a 100-tap low-pass FIR filter. Figures 7 and 8 offer a deeper look into the frequency domain, contrasting the original and quantized filters. The transition band between the passband and stopband is of particular interest, showing the effect of quantization on the filter's sharpness and roll-off characteristics. A narrower transition band correlates with higher filter order and complexity, providing a critical comparison point for the two implementations.

![Magnitude Response (Unquantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/unquantized%20magnitude%20fir%20filter%20response.png)
*Magnitude Response (Unquantized)*

![Magnitude Response (Quantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/quantized%20magnitude%20fir%20filter%20response.png)
*Magnitude Response (Quantized)*

The phase response of a filter is another pivotal aspect that determines the filter's performance in time-sensitive applications. It provides information about the phase shift introduced by the filter at various frequencies. Figures depicting the phase response for both unquantized and quantized filters are essential for understanding how quantization affects the temporal characteristics of the filter's output. The aim is to have minimal phase distortion between the unquantized and quantized filters, preserving the waveform's original timing and structural integrity.

![Phase Response (Unquantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/unquantized%20phase%20response%20.png)
*Phase Response (Unquantized)*

![Phase Response (Quantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/quantized%20phase%20response%20.png)
*Phase Response (Quantized)*

To further prove the functionality, a testbench was designed to evaluate the performance of both unquantized and quantized FIR filters under various conditions. The sampling frequency (48000 Hz) is set well above the Nyquist rate to ensure accurate frequency representation.

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

#### Impulse response

The impulse responses for both the unquantized and quantized filters are presented in Figures 5. This figure visually represents the differences in the filter's reaction to a delta function input. The response's spread and magnitude clearly depict the smoothing effect that quantization imparts on the system.

![Impulse Response (Unquantized Vs. Quantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/impulse%20response.png)
*Impulse Response (Unquantized Vs. Quantized)*

#### Harmonic Distortion Analysis (THD)

Total Harmonic Distortion (THD) analysis is a critical metric for evaluating the linearity and accuracy of the filter. Lower THD values indicate a more accurate reproduction of the input signal without harmonic distortion, which is desired in high-fidelity systems.

| Filter Type    | THD (dB)      |
|----------------|---------------|
| Unquantized    | -297.13       |
| Quantized      | -297.11       |

#### Intermodulation distortion (IMD) 

Intermodulation distortion (IMD) is a critical metric used to evaluate the linearity of an audio system and its ability to reproduce multiple frequencies simultaneously without distortion. In the context of FIR filters, IMD can illustrate how the quantization process might introduce non-linearities into the system. The below figure contrasts the IMD performance of the unquantized and quantized filters. A closer IMD profile of the quantized to the unquantized filter indicates that the quantization process preserves the filter's linearity to a significant extent.

![Intermodulation Distortion (Unquantized Vs. Quantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/MATLAB/images/Intermodulation%20Distortion.png)
*Intermodulation Distortion (Unquantized Vs. Quantized)*

#### Overflow Testing

Overflow testing is indicative of how well the system handles the digital signal's amplitude without inducing clipping or saturation. Properly managing the dynamic range is essential to prevent overflow, ensuring the filter's output remains within the bounds of the system's representational limits.

| Parameter                        | Unquantized       | Quantized         |
|----------------------------------|-------------------|-------------------|
| Maximum Output Amplitude         | 37785.84          | 37779.91          |
| Minimum Output Amplitude         | -37785.84         | -37779.91         |
| Peak-to-Peak Amplitude           | 75559.815912      | 75559.815912      |

The detailed analysis conducted in MATLAB served as a decisive phase, critically informing the subsequent hardware implementation stages. The insight gained from quantization effects, observed as alterations in the impulse and frequency responses, underscores the importance of precision in digital filter design. Managing these effects through strategic choices in coefficient quantization and system architecture ensured that the filter maintained its performance criteria. 

The SNR and ENOB tests revealed the subtle influences of quantization on the filter's noise performance and resolution. These results are crucial for verifying the fidelity of the filter in a digital signal processing chain. The dynamic range and sweeping signal frequency tests further validated the robustness of the filter against varying signal conditions, which is vital for real-world applications where signal amplitude and frequency can be unpredictable.

Harmonic distortion analysis (THD) provided a stringent benchmark for the filter's linearity. The minimal difference in THD between the unquantized and quantized filters suggests that the quantization approach preserved the integrity of the signal despite the reduced bit depth.

Lastly, the overflow tests guaranteed that the designed filter could handle signal peaks without clipping, which is essential for maintaining signal quality in practice. The peak-to-peak amplitude consistency between the unquantized and quantized filters reflects the effectiveness of the overflow management strategy implemented.

### Hardware Analysis

The FPGA-based implementation of the low-pass FIR filter yielded comprehensive data encapsulating the design's performance, area, and power consumption. 

#### Clock Frequency Analysis

The clock signal used in the FIR filter hardware implementation labeled clk, operates with a high frequency of 1000.0 MHz and a period of 1 nanosecond, which is indicative of the system's capability to perform high-speed signal processing. The fall time of 0.500 ns suggests a fast transition from high to low state, crucial for maintaining signal integrity at such high operating frequencies. This precise clock management enables the filter to perform at optimal speeds while also potentially allowing for greater data throughput, an essential feature for any application requiring real-time signal processing. 

![Clock Frequency Analysis](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/Verilog/images/clock%20frequency.png)
*Clock Frequency Analysis*

#### Resource Utilization

A detailed report on resource utilization showed that the design of the FIR filter's implementation on a Cyclone V FPGA demonstrates minimal usage of logic elements and registers, with less than 1% of the available Adaptive Logic Modules (ALMs), with a modest count of 246 registers deployed. Memory consumption is also minimal, utilizing just a fraction of the available block memory bits, ensuring ample room for further expansion or concurrent processes. This efficient use of space is crucial for cost-effective scalability and for accommodating additional functionalities in the FPGA.

![Resource Utilization](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/Verilog/images/resource%20utilization%20.png)
*Resource Utilization*

#### Timing Closure

The Multi-Corner Summary reported a positive timing slack of 0.103 ns, even at the worst-case corner, which simulates the fastest operational scenario at 1100mV and typical operating conditions. A zero Total Negative Slack (TNS) further confirms that all timing constraints are met, ensuring the design's functionality is upheld even under the most demanding circumstances. This suggests a robust design, capable of stable performance without any timing violations, crucial for reliable real-time applications.

![Multi-Corner Summary](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/Verilog/images/critical%20path.png)
*Multi-Corner Summary*

#### DSP Block Utilization

The DSP Block Usage is minimal, with only two DSP blocks employed, specifically two independent 18x18 multipliers, one fixed-point signed multiplier, and one fixed-point mixed-sign multiplier. This use of DSP blocks aligns with the parallel processing strategy of the filter, allowing for efficient real-time computation while maintaining a conservative footprint on the FPGA’s DSP resources. This conservative use signifies the design's lower power consumption and leaves room for additional parallel operations if necessary. 

![DSP Block Usage Summary](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/Verilog/images/dsp%20usage.png)
*DSP Block Usage Summary*

#### Detailed Analysis of Logic Utilization

The Analysis & Synthesis Resource Utilization report provided a breakdown of how each entity within the design contributed to the overall logic utilization, painting a picture of internal computational efficiency. The filter's main module utilizes 171 ALUTs and 316 registers, central to its computational needs. Integral components for data handling within the filter taps, such as shift registers, are efficiently mapped out, revealing their individual contributions to the overall logic utilization. With only 1552 block memory bits and two DSP blocks utilized, the design minimizes DSP resource usage, suggesting potential for scalability. Additionally, the use of 50 pins for interfacing underscores the design's capability for seamless integration with external systems. This summary encapsulates a design that is judiciously optimized for FPGA resource economy while maintaining high functional performance. 

![Analysis & Synthesis Resource Utilization](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/FIR%20Filter/Verilog/images/resource%20utilization%20.png)
*Analysis & Synthesis Resource Utilization*

These findings, gathered from the synthesis and compilation reports, affirm the FIR filter's design efficacy, achieving a balance between high performance, minimal area, and efficient power consumption—prime for real-world applications ranging from embedded systems to complex signal processing tasks.

## Conclusion

The completion of this FIR filter design and implementation project marks a significant milestone in the application of theoretical concepts to practical, real-world digital signal processing challenges. The project's success is underscored by the meticulous MATLAB design process, which achieved the desired filter specifications, and the subsequent translation of that design into an FPGA-based implementation using Verilog.

One of the project's key successes is the seamless integration between MATLAB design and Verilog implementation, demonstrating a high level of precision in quantization and an adept handling of potential overflow issues. The use of pipelining and parallel processing strategies in the hardware design not only aligned with theoretical expectations but also showcased the practical viability of the design, with timing closure reports confirming the robustness of the design under stringent conditions.

However, like any complex engineering endeavor, there remain areas open for improvement. The potential to further optimize FPGA resource utilization exists, perhaps through more aggressive logic optimization techniques or exploration of alternative architectural designs. Additionally, while the filter's performance metrics, such as SNR and THD, are within expected ranges, continued refinement could push the boundaries of filter performance, particularly in noise reduction and signal fidelity.

The scalability of the design could be tested by integrating it into larger systems or by extending its capabilities to handle higher order filtering tasks. Power consumption, a critical aspect of any embedded system, would benefit from a more in-depth analysis, possibly leading to optimizations that could reduce the design's power footprint without sacrificing performance.

In conclusion, the project stands as a testament to the efficacy of integrating software-based design with hardware implementation. The lessons learned and methodologies refined through this process hold significant value for future projects, highlighting the importance of rigorous design, careful planning, and thorough testing in the field of advanced computer systems and VLSI design.

## Reference Links

https://www.mathworks.com/help/signal/ug/fir-filter-design.html

https://www.mathworks.com/help/signal/ref/lowpass.html

https://www.mathworks.com/help/fixedpoint/ref/embedded.fimath.html
