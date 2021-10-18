# Interdependent Resource Model

The ResourceInterdependent model couples ecosystem carbon (C), nitrogen (N), and phosphorus (P) and water (W) cycles and generates output for all stocks and fluxes on a daily time step. The differential equations that describe the mass balance for each of the simulated components of the ecosystem are solved numerically using a 4th-5th order Runge-Kutta integrator with a time-step size that adapts with each pass through the integrator to optimize precision and computation time (Press et al. 1986).  The model is coded in Lazarus 2.0.12 (2020) Free Pascal and runs on a PC or Mac computer.

The ResourceInterdependent model uses a simplified model structure to amplify the heuristic value of the analysis. As a framework from which to illustrate resource optimization for interdependent resources, we build a mass-balance model for C and N in the biomass of an idealized vegetation based on uptake, turnover, and respiration. We simulate the N concentration in the environment based on a simple mass balance of inputs to the environment minus uptake by the vegetation minus losses from the environment. Asset allocation toward resource acquisition is represented by an abstract quantity called “effort”. This effort is distributed hierarchically; first the primary effort is allocated toward acquiring C, N, and P then the primary effort allocated toward C is subdivided among sub-efforts targeted at the resources that are required for photosynthesis; carbon dioxide, light and water.

A detailed model description is presented in Rastetter and Kwiatkowski, 2020 and the ResourceInterdependent model equations are presented in the file, ResourceInterdependent.txt.

--------------------------------------------------------------------------

### Publications 
Rastetter EB, and BL Kwiatkowski. 2020. An approach to modeling resource optimization for substitutable and interdependent resources. Ecological Modelling 425: 109033. DOI: /10.1016/j.ecolmodel.2020.109033

Rastetter, E. 2020. Model output, drivers and parameters for Ecosystem Recovery from Disturbance is Constrained by N Cycle Openness, Vegetation-Soil N Distribution, Form of N Losses, and the Balance Between Vegetation and Soil-Microbial Processes ver 1. Environmental Data Initiative. https://doi.org/10.6073/pasta/0af82d3c3d9d1710775cf9b1464ce70b (Accessed 2020-09-17).

Rastetter, E. and B. Kwiatkowski. 2020. Model executable, output, drivers and parameters for modeling organism acclimation to changing availability of and requirements for substitutable and interdependent resources ver 1. Environmental Data Initiative. https://doi.org/10.6073/pasta/5f4f6fcfe9bf7e63adef00d0c9203327 (Accessed 2020-09-17).

--------------------------------------------------------------------------
### Code Instructions 

The ResourceInterdependent model is written for modelshell, a model develepment package, which is written in Lazarus/Free Pascal. Modelshell allows the user to create a model by making creating a plain text file description of the model. Modelshell provides a GUI interface, an integrator, file IO, and a simple graph. All output files created by modelshell are comma delimited text files.

Detailed instructions for compiling and running the model are in "Install and Run ResourceInterdependent.docx"

--------------------------------
### Funding 
This work was supported in part by the National Science Foundation under NSF grants 1651722, 1637459, 1603560, 1556772, 1841608. Any Opinions, findings and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect those of the National Science Foundation.
