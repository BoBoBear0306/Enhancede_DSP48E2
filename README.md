
<div align="center">
  <a href="https://BoBoBear0306/Enhanced_DSP48E2.com/">
    <img src="https://github.com/user-attachments/assets/ad0a32a4-edc9-42f0-8c2a-c3053d2cc235" width="1000" height="500" />
  </a>

  <h1>Enhanced_DSP48E2</h1>

  <p>
 The enhanced_DSP48E2 is modified based on the standard DSP48E2, which can implement normal 27×18 complement multiplication, conversion from the small floating-point format to the fixed-point format and calculate MAC based on INT8 format.
  </p>

  </samp>
  </strong>
  </div>
</div>

## Table of Contents

<details>
  <summary>Click me to Open/Close the directory listing</summary>
  
- [Table of Contents](#table-of-contents)
- [Enhanced_DSP48E2_Verilog_Model](#Enhanced_DSP48E2_Verilog_Model)
- [PIR_DSP_D0_Verilog_Model](#PIR_DSP_D0_Verilog_Model)
- [Convolution_Core_tb](#Convolution_Core_tb)

</details>

## Enhanced_DSP48E2_Verilog_Model

The two's inputs of the complement multiplier are 27-bit from A and 27-bit from {D[8:0],B}. 
The complement multiplier is controlled by MULMODE(a new DSP attribute setting).

Our DSP can implement: 

①Normal complement multiplication 27*18, this time the result is A×B.

②Small floating-point numbers (ExMy,x≤4&y≤4) convert to the fixed-point numbers，this time the result is {sfp_to_int0+sfp_to_int1,sfp_to_int2+sfp_to_int3} . 

③MAC based on INT8 format, this time the result is {w0a0+w1a1,w0a3+w1a2}. 

## PIR_DSP_D0_Verilog_Model

 - **The PIR_DSP_D0_Verilog_Model** includes all the verilog modules of the PIR-DSP-D0. 

 - ⭐Refercnce paperlink of the PIR-DSP: https://ieeexplore.ieee.org/document/8735533

 - ⭐Reference open-source code and data of the PIR-DSP: https://www.github.com/raminrasoulinezhad/PIR-DSP

## Convolution_Core_tb

- **The Convolution_Core_tb** includes a 3×3 convolution core by cascading 5× ours enhanced_DSP48E2 or 3× the PIR-DSP-D0.

- The cascaded architecture of our DSP:

![image](https://github.com/user-attachments/assets/00b7f417-f4ec-4f6b-b7e9-df81154b58bd)





