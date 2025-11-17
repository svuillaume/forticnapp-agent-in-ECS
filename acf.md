# FortiCNAPP SCA - how to reduce Understanding Vulnerable Library Analysis: ACF vs AVD

Modern application security goes beyond simply identifying vulnerable libraries. 

It's essential to understand **how libraries are used** within an application to prioritize vulnerabilities based on real-world impact. FortiCNAPP offers 2 features:

- **Application Context Filtering (ACF)** – Analyzes **all references** to a vulnerable library in the source code. Currently supported for **Go, Java, and Kotlin**.  

- **Active Vulnerability Detection (AVD)** – Detect vulnerable functions that are **actually executed**.

AVD → Reduces alerts by checking what’s actually used during runtime
ACF → Reduces alerts by checking what parts of your code reference the library

When combined:
	•	AVD shows real-world exposure
	•	ACF shows real code impact
	•	You avoid wasting time on false alarms
	•	You focus on vulnerabilities that matter now or soon

This document explains the differences and provides a code example in **Java**, using **Log4j**, a widely known library with real-world vulnerabilities.


# Risk-Based Prioritization in FortiCNAPP

FortiCNAPP uses these principles to focus on the real threats:

	•	Not every vulnerability is equally dangerous.
	•	Prioritization is based on:
	•	Likelihood of exploitation (AVD shows what’s actually used)
	•	Impact if exploited (ACF shows where it touches critical parts of the app)
	•	This allows security teams to fix the riskiest problems first instead of chasing every low-priority alert.


**What is Log4J**

Log4j is a popular Java-based logging library developed by the Apache Software Foundation. It’s widely used in Java applications to record (log) messages about the application’s behavior, such as errors, warnings, informational messages, or debugging details.

**What Is the Log4Shell Attack?**

Log4Shell (CVE‑2021‑44228) is a critical remote code execution (RCE) vulnerability in Apache Log4j 2, discovered in December 2021.

In simple terms:

Imagine someone says a special “secret sentence” into a website — maybe in a login box or a chat message — and just because the website writes that sentence down in its logs, the attacker suddenly gets control of the whole system.

No password.
No breaking in.
No downloading a virus.
Nothing complicated.

#TL;DR: What Is Log4Shell?

	•	A flaw in Log4j 2.0–2.14.1
	•	Triggered by logging ${jndi:ldap://...}
	•	Allows remote code execution
	•	Requires no authentication
	•	Extremely widespread and easy to exploit
---

## Example: Java Application Using Log4j

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class MyApp {

    private static final Logger logger = LogManager.getLogger(MyApp.class);

    public void processUser(String userId) {
        logger.info("Processing user: " + userId);
        // Some processing logic
    }

    public void generateReport(String reportData) {
        logger.warn("Generating report with data: " + reportData);
        // Some report generation logic
    }
}
```

Lets assume the Log4j library has a known vulnerability: **CVE-2021-44228 (log4shell)**.

---

## 1. Active Use Detection (AVD)

### Concept

AVD focuses on runtime execution. It flags vulnerabilities only if the vulnerable functions are actively called.

### Example Analysis

Suppose in production, only `processUser` is executed. AVD will report:

```
Vulnerable Library: Log4j
Active Usage:
  - processUser(userId) → calls Logger.info
```

`generateReport` is ignored because it never runs in production.

### Pros

- Reduces false positives by focusing on live usage.

### Cons

- Might miss vulnerabilities in code paths not triggered during runtime.

---

## 2. Application Context Filtering (ACF)

### Concept

ACF analyzes the source code to identify all references to the vulnerable library, regardless of runtime execution.

### Example Analysis (Java, Log4j)

```
Vulnerable Library: Log4j
Library Usage References:
  - processUser(userId) → calls Logger.info
  - generateReport(reportData) → calls Logger.warn
```

Shows all potential usage points in the code, helping you prioritize patching and understand impact.

### Pros

- Complete picture of potential impact in Go, Java, and Kotlin projects.
- Helps prioritize patches based on actual references and context.

### Cons

- Some flagged paths may never execute, potentially inflating risk perception.
- Not available for languages like Python or JavaScript.

---

## 3. Comparison Table

| Feature | AVD (Active Use Detection) | ACF (Application Context Filtering) |
|---------|---------------------------|-------------------------------------|
| Basis | Runtime execution | Source code analysis |
| Focus | What is actively called | All references in code |
| Goal | Reduce false positives in live usage | Map full impact and prioritize by context |
| Limitation | Might miss untested code paths | Flags unused code, language support limited to Go, Java, Kotlin |
| Example (Log4j) | Flags only processUser if generateReport never runs | Flags both processUser and generateReport |

---

## 4. Visual Flow

```
Log4j Library Vulnerable
├── processUser() calls Logger.info
└── generateReport() calls Logger.warn

AVD (Active Use Detection)
├── processUser() → FLAGGED ✓
└── generateReport() → NOT FLAGGED ✗

ACF (Application Context Filtering)
├── processUser() → FLAGGED ✓
└── generateReport() → FLAGGED ✓
```

---

## 5. Conclusion: Value of Each Approach

- **ACF** is valuable for a comprehensive understanding of how vulnerable libraries touch your codebase in supported languages. Ideal for planning patches and prioritization.
- **AVD** is valuable for risk reduction in live systems, focusing on what is actually used and exposed to potential exploitation.

### Best Practice

Combining both approaches gives the full picture—you see both the potential impact and the real-world exposure, allowing for smarter security decisions.
