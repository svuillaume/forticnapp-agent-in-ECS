# FortiCNAPP SCA: Reducing Alert Noise Through Application Context Filtering

## Understanding Alert Noise

Alert noise in cloud security occurs when security teams receive an overwhelming volume of alerts, most of which are not genuinely important. This happens because cloud systems generate enormous amounts of data, and security rules are not always optimally configured. The critical risk is that real attacks can easily hide among the noise, compromising security effectiveness.

## Modern Cloud-Native Application Security

Modern and cloud-native application security goes beyond simply identifying vulnerable libraries. It's essential to understand how libraries are actually used within your application so you can focus on vulnerabilities that truly matter.

FortiCNAPP offers two key features to address this challenge:

**Application Context Filtering (ACF)** analyzes all references to a vulnerable library in source code. Currently supported for Go, Java, and Kotlin. ACF is available as part of Lacework FortiCNAPP's CLI. To enable ACF when running a Software Composition Analysis (SCA) scan, include the `--acf` flag in your command.

**Active Vulnerability Detection (AVD)** detects vulnerable functions that are actually executed. This feature is enabled in the FortiCNAPP agent and represents the current integration point between Lacework FortiCNAPP SCA and Active Vulnerability Detection in the CLI and within CI/CD integrations.

## Running SCA with ACF

You can run the SCA scan with Application Context Filtering enabled using the `--acf` argument. Because the output can be large, save results to a JSON file for easier analysis.

### Example Command

```bash
lacework sca scan ./Projects/log4j-sample --acf -o ./Projects/log4j-sample/acf-results.json
```

## Running SCA with Active Vulnerability Detection

To enable Active Vulnerability Detection during an SCA scan, use the `--active-only` flag. This tells Lacework FortiCNAPP SCA to filter results and show only vulnerabilities that are actively used in your running applications.

### Example Command

```bash
lacework sca scan ./Projects/nodejs-goof --active-only
```

## Comparison: AVD vs. ACF

**AVD** reduces alerts by checking what's actually used during runtime.

**ACF** reduces alerts by checking which parts of your code reference the library.

When combined, AVD shows real-world exposure and ACF shows real code impact. This approach helps you avoid wasting time on false alarms and focus on vulnerabilities that matter now or soon.

## Risk-Based Prioritization in FortiCNAPP

FortiCNAPP uses these principles to focus on real threats:

Not every vulnerability is equally dangerous. Prioritization is based on the likelihood of exploitation (AVD shows what's actually used) and impact if exploited (ACF shows where it touches critical parts of the app). This allows security teams to fix the riskiest problems first instead of chasing every low-priority alert.

## Case Study: Log4j and Log4Shell

### What is Log4j?

Log4j is a popular Java-based logging library developed by the Apache Software Foundation. It's widely used in Java applications to record messages about application behavior, such as errors, warnings, informational messages, or debugging details.

### What is the Log4Shell Attack?

Log4Shell (CVE-2021-44228) is a critical remote code execution vulnerability in Apache Log4j 2, discovered in December 2021.

In simple terms: an attacker can send a special command string to a website (perhaps in a login box or chat message), and because the website logs that string, the attacker suddenly gains control of the entire system. No password, no breaking in, no virus download—nothing complicated.

**Quick Facts About Log4Shell:**

Log4Shell is a flaw in Log4j 2.0–2.14.1 that is triggered by logging `${jndi:ldap://...}`, allows remote code execution, requires no authentication, and is extremely widespread and easy to exploit.

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

Assume the Log4j library has the known vulnerability CVE-2021-44228 (Log4Shell).

### 1. Active Use Detection (AVD)

**Concept:** AVD focuses on runtime execution. It flags vulnerabilities only if the vulnerable functions are actively called.

**Example Analysis:** Suppose in production only `processUser` is executed. AVD will report:

```
Vulnerable Library: Log4j
Active Usage:
  - processUser(userId) → calls Logger.info
```

The `generateReport` method is ignored because it never runs in production.

**Advantages:** Reduces false positives by focusing on live usage.

**Limitations:** Might miss vulnerabilities in code paths not triggered during runtime.

### 2. Application Context Filtering (ACF)

**Concept:** ACF analyzes source code to identify all references to the vulnerable library, regardless of runtime execution.

**Example Analysis (Java, Log4j):**

```
Vulnerable Library: Log4j
Library Usage References:
  - processUser(userId) → calls Logger.info
  - generateReport(reportData) → calls Logger.warn
```

This approach shows all potential usage points in the code, helping you prioritize patching and understand impact.

**Advantages:** Provides a complete picture of potential impact in Go, Java, and Kotlin projects. Helps prioritize patches based on actual references and context.

**Limitations:** Some flagged paths may never execute, potentially inflating risk perception. Not available for languages like Python or JavaScript.

### 3. Comparison Table

| Feature | AVD (Active Use Detection) | ACF (Application Context Filtering) |
|---------|---------------------------|-------------------------------------|
| **Basis** | Runtime execution | Source code analysis |
| **Focus** | What is actively called | All references in code |
| **Goal** | Reduce false positives in live usage | Map full impact and prioritize by context |
| **Limitation** | Might miss untested code paths | Flags unused code; language support limited to Go, Java, Kotlin |
| **Log4j Example** | Flags only processUser if generateReport never runs | Flags both processUser and generateReport |

### 4. Visual Flow

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

## Conclusion: Value of Each Approach

**ACF** is valuable for comprehensive understanding of how vulnerable libraries touch your codebase in supported languages. It's ideal for planning patches and prioritization.

**AVD** is valuable for risk reduction in live systems, focusing on what is actually used and exposed to potential exploitation.

### Best Practice

Combining both approaches provides the full picture. You see both the potential impact and the real-world exposure, enabling smarter security decisions. This integrated approach helps security teams reduce alert noise while ensuring no critical vulnerabilities are overlooked.
