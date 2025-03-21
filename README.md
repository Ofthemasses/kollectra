# The Kollectra Project

## Installation
### Dependencies
- python3
- pip
    - yq

As of now, the repository can only pull required dependencies. To do this, enter the following command:

```
make init
```

## Why Does this Project Exist?
The open-source community in FPGA design is small but beginning to flourish.
Since the creation of the RISC-V open standard, the opportunity to adopt
designs that are not dependent on patented and commercial designs is now
possible when designing on FPGAs. This project, as a part of my master's
thesis, aims to create an FPGA game console using purely open-source IP blocks
and HDL code. By doing this, we can explore open-source FPGA design and
complete a piece of work that can act as a meaningful contribution to the
open-source community.

The core goals of the project are:
- **To Create an FPGA Game Console**: The
realisation of an FPGA game console with display output, controller interfaces,
and an interface to load programs.
 
- **Make Use of Existing Open-Source IPs and Graphics APIs**: The aim of the
project is not to reinvent the wheel. By making use of existing open-source
RISC-V cores, interface blocks, and integration of open-standard graphic APIs,
we aim to enhance these projects that are auxiliary to ours and others.
 
- **Create a Game Tech Demo to Analyse RISC-V**: By creating a game tech demo,
we will be able to not only test the FPGA we produce and the open-source cores
and IPs we have integrated, but also to analyse using RISC-V's instruction set,
its vector extension, and other instructions we wish to implement. Implementing
custom instructions is an integral feature of RISC-V.
 
- **Stay Accountable to the Philosophical Goals of the Project**: By creating a
clear project philosophy, we can ensure the project does not diverge from its
objectives. Below, and soon to be in a PDF, is the Project Philosophy. An
integral part of this philosophy is a means of tracking and linking work to the
philosophy. We define what work is permitted, and issues can be back-linked to
these permitted categories of work to ensure the project remains guided.

## Project Philosophy

### 1. Definitions - Community: The contributors, (hardware) open-source community
and users of the project

### 2. Objectives

- Develop a project that meaningfully investigates and enriches the community.
- Prioritize utilizing open source for the free distribution of information and
technology, rather than for profit-making or contributing to industry profits.
- Position the project as a product for the community, ensuring it is
democratically controlled by its members.  - Allow any restrictions on
community contributions and decision-making to be implemented only through
democratic processes, such as defining criteria for verifying a community
member's vote.  - Ensure that any fabrication of the project adheres to ethical
standards.

### 3. Issues and Contributions

All GitHub and CodeBerg issues should connect back to or reference these core
topics. This must be completed by providing a link to a valid version of this
document, and referencing a topic by number(s).

#### 3.1. Importance of Open Source in FPGA Design
##### 3.1.1 Investigates why open source is critical.  
##### 3.1.2 Investigates why open source is critical in FPGA design.

#### 3.2 Investing in the Culture of Open Source Projects 
##### 3.2.1. Improves upon existing, or implements new features to open-source development.
##### 3.2.2. Improves upon existing, or implements new features to open-source development in FPGA design.

#### 3.3. Producing a Product 
##### 3.3.1. Contributes to the realisation of a FPGA game console, without conflicting with 2, 3.1 and 3.2.
