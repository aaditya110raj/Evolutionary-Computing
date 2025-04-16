
# 🔢 MATLAB-Based Solver for the Generalized Assignment Problem (GAP)

This repository contains a MATLAB implementation for solving the **Generalized Assignment Problem (GAP)**. The GAP is addressed using integer linear programming to determine the optimal allocation of users to servers, maximizing the total utility while respecting resource limits.

---

## 📁 Directory Overview

```
📂 project/
├── Copy_of_optimal.m            # MATLAB script for solving GAP instances
├── Assignments/          # Input files (gap1.txt to gap12.txt)
│   ├── gap1.txt
│   ├── ...
│   └── gap12.txt
└── gapResult.csv         # Output file with results per instance (generated after execution)
```

---

## 📝 Problem Summary

The Generalized Assignment Problem (GAP) involves:
- Assigning users to a set of servers
- Each assignment has a utility (profit) and consumes resources
- Servers have a limited capacity

**Goal**: Maximize the total utility while ensuring:
- Each user is assigned to exactly one server
- No server exceeds its resource limit

---

## ▶️ Execution Instructions

1. Place your dataset files (`gap1.txt` to `gap12.txt`) inside a folder named `gap dataset files/`.
2. Open MATLAB and set the current directory to the folder containing `Copy_of_optimal.m`.
3. Run the script using:
   ```matlab
   processDataFiles();
   ```
4. After completion, the script generates a file named `gap_max_results.csv` with the results.

---

## 📄 Output Details

The output CSV file contains the following structure:

| FileIndex | InstanceName | Cost |
|-----------|--------------|---------|
| 1         | c500-1       | 1042    |
| 1         | c500-2       | 986     |
| ...       | ...          | ...     |

- **FileIndex**: Index of the dataset file (e.g., 1 for gap1.txt)
- **InstanceName**: Identifier for the test case (format: `c<serverUser>-<case>`)
- **Cost**: Calculated total utility for the instance

---

## 🧠 Technical Approach

- The script reads multiple test cases from 12 input files.
- For each instance:
  - It reads the utility, resource, and capacity data
  - Constructs a mixed-integer optimization problem
  - Solves it using MATLAB’s `intlinprog` solver
- The output includes both console display and a CSV log

---

## ⚙️ Requirements

- MATLAB (recommended: R2019b or later)
- Optimization Toolbox enabled (uses `intlinprog`)

---

## 📊 Console Output

The script also prints grouped outputs like:

```
gap1            gap2            gap3            gap4            
c500-1  1042    c500-1  1021    c500-1  998     c500-1  1003
c500-2  986     c500-2  999     c500-2  972     c500-2  978
...
```

