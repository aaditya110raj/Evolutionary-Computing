# Binary-Coded Genetic Algorithm (GA) for Optimization

## 📌 Overview

This project implements a **Binary-Coded Genetic Algorithm (GA)** for solving optimization problems. The workflow follows two stages:

1. **Stage 1**: Apply Binary-Coded GA to find the **optimal value of the Sphere function** with 4 variables.
2. **Stage 2**: Use the GA on a real-world dataset (**Generalized Assignment Problem - GAP File 12**), and compare its results to:
   - **Greedy Approximation**
   - **Optimal Values**

---

## 🧪 Stage 1: Sphere Function Optimization

**Objective Function:**

```
minimize f(x) = ∑(xi^2) for i = 1 to 4
where xi ∈ [-10, 10]
```

- Each variable is encoded with 16 bits.
- The total chromosome length is 64 bits (4 variables × 16 bits).
- Fitness is calculated as the sphere function value (lower is better).
- Selection uses **Tournament Selection**.
- Genetic operations include **Single-Point Crossover** and **Bitwise Mutation**.
- **Elitism** is applied to retain the best solution.
- The **Convergence Graph** shows how the best fitness evolves across generations.

📁 File: `Binary_coded_sphere.m`  
📈 Output: A convergence plot saved as a figure displaying fitness per generation.

---

## 📊 Stage 2: GAP Dataset Comparison

Using the GA from Stage 1, we apply it to **GAP File 12** instances and compare:

- **GA Utility**
- **Greedy Utility**
- **Optimal Utility**

**Comparison Outputs:**

1. **Grouped Bar Chart** of total utility per instance.
2. **Line Plot of Performance Ratios (%)**:
   - `Greedy / Optimal`
   - `GA / Optimal`
3. **CSV Summary** with utility and performance metrics.

📁 File: `compareBGAvsOPvsAPP (1).m`

📊 Plots:
- `comparison_BCGA_APP_OP (1).png` – grouped utility chart.
- `performance_ratios.png` – ratio comparisons.
- `algorithm_comparison.csv` – summary table.

---

## 🔧 How to Run

1. Open **MATLAB**.
2. Run `Binary_coded_sphere.m` to:
   - Optimize the Sphere function.
   - View convergence behavior.
3. Run `compareBGAvsOPvsAPP (1).m` to:
   - Analyze GA performance on GAP dataset.
   - View and save comparative plots and tables.

---

## 📂 Output Files

| File Name                  | Description                                 |
|---------------------------|---------------------------------------------|
| `utility_comparison.png`  | Bar chart comparing Greedy, GA, and Optimal |
| `performance_ratios.png`  | Line chart of performance ratios            |
| `algorithm_comparison.csv`| Table of utility and ratio metrics          |
| `Binary_coded_sphere.m`   | GA for Sphere function                      |
| `compareBGAvsOPvsAPP (1).m` | GAP file utility comparison script        |

---

## ✅ Results Summary

- **Sphere Function** optimization converged smoothly with GA.
- On GAP File 12:
  - **GA outperformed Greedy** in most cases.
  - **Optimal utility** remains the upper benchmark.
