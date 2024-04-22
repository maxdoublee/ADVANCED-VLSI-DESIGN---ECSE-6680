# Final Project
Advanced VLSI Design - Course Project | ECSE 6680 

## Overview

This project centers on designing and implementing a low-pass Infinite Impulse Response (IIR) filter, utilizing MATLAB to match the frequency response characteristics of a previously designed Finite Impulse Response (FIR) filter. The target specifications include a transition region from 0.2π to 0.23π rad/sample and a stopband attenuation of at least 80dB. In comparison to the FIR filter project, which involved constructing a 100-tap low-pass filter meeting similar specifications, the IIR filter design introduces unique challenges and efficiencies. 

For instance, while the FIR project required an iterative approach to meet the desired stopband attenuation, the IIR design leverages a direct calculation method for determining the necessary filter order. This highlights a fundamental difference in handling design complexity between FIR and IIR filters. Moreover, the recursive nature of IIR filters necessitates careful consideration of stability and quantization effects, aspects that are managed differently than in FIR filters. Documentation in this README will cover the entire design process, from MATLAB modeling to Verilog implementation, including detailed analyses of the filter's frequency response, architecture, and hardware performance results. 

This documentation will serve as a resource for understanding the intricacies of IIR filter implementation, providing insights into the comparative advantages and challenges faced when designing IIR filters as opposed to FIR filters. Through this project, I aim to advance the practical application of digital signal processing techniques in real-world scenarios, demonstrating the adaptability and robustness of IIR filters in high-performance computing environments. 

## Design Process

### MATLAB IIR Filter Design

The design of the Infinite Impulse Response (IIR) filter was undertaken with MATLAB, a platform chosen for its advanced signal processing tools and capabilities. The first step in the design process was defining the filter specifications. These included the passband edge (0.2π rad/sample), stopband edge (0.23π rad/sample), passband ripple (1 dB), and stopband attenuation (80 dB). The `ellipord` function was instrumental in determining the optimal filter order and natural frequency. This function calculates the minimal filter order required to achieve the desired attenuation and ripple, balancing performance with computational efficiency, a critical aspect in filter design where lower order generally means less complexity and faster computation.

Following the calculation of the filter order, the `ellip` function was utilized to design the filter. This function is specifically chosen for elliptic filters due to their steep rolloff capabilities, which are essential for achieving sharp transition between passband and stopband with minimal order. The elliptic filter is ideal for applications requiring stringent stopband attenuation without excessive ripple in the passband.

#### Comparison with FIR Filter Design

In contrast to the FIR filter design, which necessitated an iterative approach to incrementally meet the stopband attenuation by adjusting the number of taps (`N`), the IIR design process leveraged a more direct method. The IIR's design was accomplished in a single step through the `ellipord` function, which directly calculates the minimal order needed for the specified attenuation and ripple requirements.

The FIR filter required manual adjustments and repeated calculations to ensure the desired stopband attenuation was met, iterating through increasing the number of filter taps until the attenuation criteria were satisfied. This often led to a larger filter order and, consequently, greater resource consumption when implemented in hardware.

### Verilog Implementation

The Verilog implementation of this low-pass Infinite Impulse Response (IIR) filter showcases advanced digital design techniques by adhering to best practices for recursive filter computations, the implementation ensures efficient signal processing with minimal latency.

#### Design Structure and Patterns

The IIR filter module is designed to efficiently process incoming data through a sophisticated pipeline, ensuring high fidelity in the filter's response. Key elements of the module include:
- **Parameters**: `ORDER` and `COEFFICIENT_WIDTH` dictate the recursion stages and the precision of filter coefficients, respectively.
- **Dynamic Coefficient Loading**: Coefficients for feedforward (`b`) and feedback (`a`) paths are loaded dynamically from memory at initialization, allowing for flexible, real-time adjustments to the filter's behavior.

#### Advanced Pipelining

To optimize the performance of the IIR filter, the implementation integrates advanced pipelining strategies that cater specifically to the recursive nature of IIR calculations. This pipelining not only orchestrates the timing of operations to ensure seamless data flow but also manages dependencies between consecutive stages effectively. Each stage of the pipeline processes part of the computation, and then swiftly passes the intermediate results to the next stage without idle cycles. For instance, the multiplication results from both feedforward `mult_results_b` and feedback `mult_results_a` paths are computed concurrently and then immediately directed to summation stages. This method substantially reduces the waiting time that typically occurs when stages are processed sequentially, thereby boosting the overall throughput and reducing the latency of the filter's response.

#### Parallel Processing

Parallel processing in the IIR filter design is implemented to decompose the filter's operations into smaller, simultaneous tasks, enhancing the efficiency of the computational process. In the Verilog implementation, the computational tasks are divided such that multiple data samples are processed in parallel through different pipeline stages. The core of this approach lies in the simultaneous calculation of multiple output values, where pairs of results from the `mult_results_b` and `mult_results_a` arrays are summed in parallel across the `sum_stage1` and `sum_stage2` arrays. This parallel processing is crucial in environments requiring real-time processing, as it maximizes data throughput and minimizes the response time, making my IIR filter suitable for high-frequency signal applications where delays must be kept to an absolute minimum.

#### Stability and Performance Optimization

Stability in the IIR filter is of paramount importance due to the inherent feedback mechanism that can potentially lead to unstable system responses. To ensure robust performance and maintain stability, my design incorporates controlled feedback mechanisms where the feedback coefficients (`a`) are carefully calibrated to prevent runaway conditions. Saturation arithmetic is used extensively within the feedback loops to prevent numerical overflow—a common issue in fixed-point arithmetic operations. The coefficients and state variables are stored in registers with a precision defined by `COEFFICIENT_WIDTH`, ensuring that the calculations maintain high accuracy without the risk of overflow. Additionally, initial conditions are set to zero in the always block triggered by a reset signal, ensuring a clean and stable startup each time the system is initialized. These measures significantly enhance the reliability and performance of the IIR filter under various operating conditions, preserving the integrity and accuracy of its output.

#### Comparison of IIR and FIR Filter Designs

The IIR filter design incorporates advanced techniques enhancing its functionality and efficiency. **Advanced Pipelining**, tailored to the recursive nature of IIR filters, ensures efficient data flow and minimizes latency. This facilitates the concurrent processing of feedforward (`mult_results_b`) and feedback (`mult_results_a`) paths, significantly enhancing throughput and responsiveness. **Parallel Processing** breaks down computational tasks into smaller, concurrent blocks, maximizing data throughput and minimizing processing time, vital for real-time operation in complex environments. **Stability and Performance Optimization** focuses on maintaining stability through controlled feedback mechanisms and saturation arithmetic, essential for preventing numerical overflow and ensuring reliable filter performance under various conditions.

In comparison, the FIR filter design requires iterative adjustments to achieve desired stopband attenuation, making the IIR filter's approach of using the `ellipord` tool to directly determine the optimal filter order more streamlined and efficient. This results in better resource management, as the recursive nature of the IIR filter, combined with advanced pipelining and parallel processing, allows for more efficient use of hardware resources. This is particularly advantageous in applications where hardware efficiency and processing speed are critical.

The IIR filter features efficient recursive data flow management using arrays `x_reg` and `y_reg`, with a two-stage parallel summation process (`sum_stage1` and `sum_stage2`) that optimizes feedback and feedforward calculations. In contrast, the FIR filter employs shift registers (`shift_reg`) for sequential data processing and multiplications with stored coefficients, using a dual-path accumulation system (`accum_reg_half1` and `accum_reg_half2`). While effective, this approach demands more extensive hardware resources compared to the more compact and efficient IIR design.

## Results

### MATLAB Analysis

This section presents the results of the MATLAB analysis performed on the low-pass Infinite Impulse Response (IIR) filter designed for this project. The analysis focuses on quantization effects, frequency response, phase response, and overall filter performance, providing a comprehensive overview of how the IIR filter behaves under various conditions. Additionally, I compare these results to those obtained from the FIR filter to illustrate differences in performance and computational efficiency.

#### Frequency Response

The frequency response of the IIR filter, both unquantized and quantized, is illustrated below. These graphs show how the transition from the passband to the stopband is managed by the filter, highlighting the effects of quantization on the filter's ability to maintain sharp roll-off characteristics.

**Frequency Response (Unquantized)**
  
  ![Frequency Response Unquantized](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/unquantized%20magnitude%20iir%20filter%20response.png)

**Frequency Response (Quantized)**
  
  ![Frequency Response Quantized](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/quantized%20magnitude%20iir%20filter%20response.png)

#### Phase Response

Phase response analysis is crucial for understanding the temporal behavior of the filter. The following figures depict the phase response for both the unquantized and quantized versions of the IIR filter:

**Phase Response (Unquantized)**
  
  ![Phase Response Unquantized](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/unquantized%20phase%20response%20.png)

**Phase Response (Quantized)**
  
  ![Phase Response Quantized](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/quantized%20phase%20response%20.png)

#### Comparative Analysis of IIR versus FIR Filter

Comparing the IIR filter with the previously designed FIR filter provides valuable insights into the efficiency and performance of both filter types. Here I look at various metrics such as SNR, ENOB, and dynamic range to assess each filter's capabilities.

**Signal-to-Noise Ratio (SNR) and Effective Number of Bits (ENOB)**
  
  | Metric        | IIR Unquantized Filter  | IIR Quantized  Filter | FIR Unquantized Filter | FIR Quantized Filter |
  |---------------|-------------------------|-----------------------|------------------------|----------------------|
  | SNR (dB)      | 80.29                   | 75.14                 | 5.13                   | 5.26                 |
  | ENOB (bits)   | 13.33                   | 13.35                 | 0.56                   | 0.58                 |

- **Dynamic Range Test**
  
  | Amplitude | IIR Unquantized SNR (dB) | IIR Quantized SNR (dB) | FIR Unquantized SNR (dB) | FIR Quantized SNR (dB) | 
  |-----------|--------------------------|------------------------|--------------------------|------------------------|
  | 0.01      | 0.40                     | 0.39                   | 0.31                     | 0.29                   |
  | ...       | ...                      | ...                    | ...                      | ...                    |
  | 1.00      | 2.12                     | 2.25                   | 0.95                     | 0.97                   |

- **Sweeping Signal Frequency Test**

  | Frequency (Hz) | IIR Unquantized SNR (dB) | IIR Quantized SNR (dB) | FIR Unquantized SNR (dB) | FIR Quantized SNR (dB) | 
  |----------------|--------------------------|------------------------|--------------------------|------------------------|
  | 4800.00        | 70.73                    | 68.56                  | 1.29                     | 1.30                   |
  | ...            | ...                      | ...                    | ...                      | ...                    |
  | 5520.00        | 72.97                    | 68.68                  | 5.42                     | 5.46                   |

- **Impulse Response Comparison**
  
  ![Impulse Response (Unquantized Vs. Quantized)](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/impulse%20response.png)

- **Total Harmonic Distortion (THD)**
  
  | Filter Type     | THD (dB) |
  |-----------------|----------|
  | IIR Unquantized | -290.00  |
  | IIR Quantized   | -289.50  |
  | FIR Unquantized | -297.13  |
  | FIR Quantized   | -297.11  |

- **Intermodulation Distortion (IMD)**
  
  ![IMD Comparison](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/MATLAB/images/Intermodulation%20Distortion.png)

- **Overflow Test Results**
  
  | Parameter                        | IIR Unquantized | IIR Quantized | FIR Unquantized | FIR Quantized |
  |----------------------------------|-----------------|---------------|-----------------|---------------| 
  | Maximum Output Amplitude         | 37750.09        | 37745.88      | 37785.84        | 37779.91      |
  | Minimum Output Amplitude         | -37750.09       | -37745.88     | -37785.84       | -37779.91     |
  | Peak-to-Peak Amplitude           | 75500.180000    | 75491.76      | 75559.815912    | 75559.815912  |

These results highlight the distinct advantages of the IIR filter, particularly in terms of computational efficiency and resource management, while also detailing areas where the FIR filter may offer benefits, such as stability and simplicity.

### Hardware Analysis

#### Clock Frequency Analysis

The clock signal used in the IIR filter hardware implementation labeled clk, operates with a high frequency of 1000.0 MHz and a period of 1 nanosecond, which is indicative of the system's capability to perform high-speed signal processing. The fall time of 0.500 ns suggests a fast transition from high to low state, crucial for maintaining signal integrity at such high operating frequencies. This precise clock management enables the filter to perform at optimal speeds while also potentially allowing for greater data throughput, an essential feature for any application requiring real-time signal processing. 

![Clock Frequency Analysis](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/images/clock%20frequency.png)

#### Resource Utilization

A comprehensive resource utilization report for the IIR filter implemented on a Cyclone V FPGA indicates efficient employment of hardware resources. The design utilizes a modest 2% of the available Adaptive Logic Modules (ALMs), accounting for 345 logic elements out of 18,480. With 322 registers used, the register count remains well within limits, occupying a minimal percentage of the FPGA's capacity. Notably, the design requires no virtual pins and does not tap into the block memory bits, leaving the full memory capacity available for additional processes or future enhancements. The digital signal processing (DSP) block usage stands at 17 out of 66, which is 26%, a moderate amount that allows for further complex operations if needed. This level of efficiency in resource management highlights the design's potential for cost-effective scalability and the possibility to integrate more functionality within the FPGA fabric.

![Resource Utilization](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/images/compilation%20report.png)

#### DSP Block Utilization

The Analysis & Synthesis DSP Block Usage Summary reveals a judicious allocation of DSP blocks within the FPGA for the current filter design. Specifically, the design utilizes 20 independent 18x18 multipliers, complemented by an additional sum of five 18x18 multipliers, bringing the total number of DSP blocks in use to 25. Out of these, 10 are fixed-point signed multipliers, 5 are fixed-point unsigned multipliers, and a significant number, 15, are fixed-point mixed-sign multipliers. This allocation underscores the filter's ability to handle a variety of computational tasks, adhering to a design that favors mixed-sign operations. The effective distribution of these multipliers supports the parallel processing needs of the filter, ensuring efficient and swift computation suitable for real-time applications. Furthermore, this approach indicates a balanced use of the FPGA’s DSP resources, optimizing power consumption while still offering the capability to extend functionality for additional parallel processing requirements.

![DSP Block Usage Summary](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/images/dsp%20usage.png)

#### Detailed Analysis of Logic Utilization

The Analysis & Synthesis Resource Utilization by Entity report outlines the specific resource usage for the iir_filter design implemented on an FPGA. The report shows that the filter utilizes a total of 608 combinational Adaptive Look-Up Tables (ALUTs), demonstrating its logic complexity and computational requirements. A total of 1420 dedicated logic registers are employed within the design, facilitating state retention and sequential logic functions critical for filter operations. Notably, the design does not utilize any block memory bits, indicating that the filter architecture relies solely on registers for data storage. The DSP blocks used amount to 25, indicating the implementation of complex multiplication operations, likely related to the filter coefficients and signal processing algorithms. The use of 50 pins for I/O operations confirms the design's capacity for interfacing with external devices and data streams, which is essential for real-world signal processing applications. The absence of virtual pins suggests a direct mapping of physical pins, further pointing to a design tailored for practical deployment.

![Analysis & Synthesis Resource Utilization](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/images/resource%20utilization.png)

The FPGA resource usage for the iir_filter is summarized, demonstrating the allocation of hardware resources to support the filter's operations. A total of 764 Adaptive Logic Modules (ALMs) have been estimated for the logic utilization of the filter. This is indicative of the overall logic complexity and the computational depth within the filter design.

The maximum fan-out observed is from the clk-input node, with a fan-out of 1420, reflecting the wide distribution of the clock signal across the design and its importance in synchronizing the filter's operations. The total fan-out of 6607 provides insight into the extensive internal connectivity and the interdependence of logic elements within the filter.

This focused summary of resource usage characterizes a design that is both economical and efficient. The filter's architecture has been optimized to provide a balance between computational power and prudent use of FPGA resources, allowing for scalability and potential integration of additional modules without compromising on performance.

![Analysis & Synthesis Resource Usage](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/images/resource%20usage.png)

## Final Thoughts

Looking back, taking on the challenge to create this low-pass Infinite Impulse Response (IIR) filter has taught me a lot. It was about bringing complex ideas from theory into real-world practice with MATLAB, then carefully turning those into a working design in Verilog, striking a balance between precision and efficiency that is key in advanced electronic design.

Combining MATLAB's analytical power with Verilog's ability to implement those designs has shown how important it is to move smoothly from concept to reality. This project allowed me to really dig into the differences between IIR and FIR filters, seeing up close how each has its own advantages and challenges. The IIR filter stands out for its computational efficiency, crafted with a keen understanding of how quantization and stability can shape a design meant for powerful computing tasks.

The hardware side of things, including analyzing clock frequencies, managing resources, and using DSP blocks, shows a setup that's optimized for top performance while still being smart about using FPGA resources. The GitHub repository is proof of this, documenting the RTL synthesized output which shows a filter design that's both flexible and ready to be part of larger systems, focusing on adaptability and careful resource use.

I invite you to check out the RTL synthesized outputs on GitHub for a closer look at the project details. The repository is full of comprehensive outputs that give insight into the practical side of this academic work:

[Explore the RTL Synthesized Output on GitHub](https://github.com/maxdoublee/ADVANCED-VLSI-DESIGN---ECSE-6680/blob/main/Projects/Final%20Project-%20IIR%20Filter/Verilog/hardware_synthesis/RTL_viewer.pdf)

This project is not just an endpoint but the start of ongoing exploration into the world of digital signal processing and VLSI design. The knowledge and experience I've gained here will be the base for future projects in this ever-changing field. 
