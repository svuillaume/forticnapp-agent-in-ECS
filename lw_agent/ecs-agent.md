## AWS Fargate ECS FortiCNAPP deployment - Embedded Agent vs Sidecar Agent

Lacework FortiCNAPP offers two methods for deployment into AWS Fargate for ECS. The first method is a container image embedded-agent approach, and the second is a sidecar-based approach that utilizes a volume map. In both deployment methods, the agent runs inside the application container.

For embedded-agent deployments, we recommend a multi-stage image build, which starts the agent in the context of the container as a daemon.

For sidecar-based deployments, the agent sidecar container exports a storage volume that is mapped by the application container. By mounting the volume, the agent can run in the application container namespace.

**Embedded Agent (Multi-Stage Image Build):**  
- The agent runs inside the application container as a daemon.  
- Non-intrusive to running services due to ECS rolling updates.  
- Modifies the application image itself, so considered **intrusive to the image**.  
- Upgrading the agent requires rebuilding the application image.  

**Sidecar Agent:**  
- Runs as a separate container alongside the application container.  
- Fully non-intrusive: neither the running service nor the application image is modified.  
- The agent can be upgraded or restarted independently.  
- Requires startup dependency ordering to ensure proper initialization.

| Feature | Embedded Agent | Sidecar Agent |
|---------|----------------|---------------|
| Application image modified? | Yes | No |
| Agent upgrade independent? | No | Yes |
| Startup dependency ordering needed? | No | Yes |
| Rolling update safe? | Yes | Yes |

---

 
 # Lacework FortiCNAPP Sidecar Deployment for ECS Fargate

This guide explains how to deploy the Lacework FortiCNAPP agent as a **sidecar container** alongside your ECS Fargate application container. Using a sidecar approach is **non-intrusive** and does not require modifying your running application container.

---

## Table of Contents

1. [Overview](#overview)  
2. [Prerequisites](#prerequisites)  
3. [Deployment Steps](#deployment-steps)  
   - [Add Sidecar Container](#add-sidecar-container)  
   - [Update Application Container](#update-application-container)  
4. [Embedded Agent vs Sidecar Agent](#embedded-agent-vs-sidecar-agent)  
5. [Best Practices](#best-practices)  
6. [Notes](#notes)  

---

## Overview

There are two ways to deploy the Lacework FortiCNAPP agent:

1. **Embedded Agent** – runs the agent inside the application container itself.  
2. **Sidecar Agent** – runs the agent as a separate container alongside the application container.  

The sidecar deployment involves:

- Adding a sidecar container for the Lacework FortiCNAPP agent.  
- Updating the application container to use a shared volume containing the agent executable.

---

## Prerequisites

Before deploying, ensure the following:

- Verify the agent release package signature using GPG and RSA keys.  
- Understand your application image, including whether it uses **ENTRYPOINT** or **CMD**.  
- The agent startup script must be run as **root**.  
- An existing ECS task definition with a single application container is available.

---

## Deployment Steps

### Add Sidecar Container

1. Edit your ECS task definition.  
2. Add a new container definition for the Lacework FortiCNAPP agent.  
3. Ensure the container runs as **root**.  
4. Configure any necessary volumes for sharing the agent executable with the application container.

### Update Application Container

The application container needs to temporarily override its startup behavior to integrate with the sidecar.

1. Depending on whether your container uses **CMD** or further down **ENTRYPOINT**, update the task definition accordingly.

<img width="627" height="166" alt="image" src="https://github.com/user-attachments/assets/7444f30c-f9ea-483c-b2db-b88888dcb27c" />


<img width="616" height="161" alt="image" src="https://github.com/user-attachments/assets/e1921655-4ea9-4feb-b8f0-9d0bcfa0b0ba" />



2. In the **Storage and Logging** section:  
   - Mount the shared volume exported by the sidecar container.  
   - This allows the application container to access the Lacework agent executable.  
3. Set the **Startup Dependency Ordering**:  
   - Container name: `datacollector-sidecar`  
   - Condition: `SUCCESS`  
   - This ensures the application container starts only after the sidecar has successfully started.  
4. Click **Update** to update the application container definition.  
5. Create a new revision of the task definition by clicking **Create**.  

---


## Best Practices (Optional)

- Set the following environment variables in the application container:  
  - `LaceworkAccessToken`  
  - `LaceworkServerUrl`  

- ECS uses a **rolling update** strategy by default, so redeploying the service after updating the task definition **will not interrupt your running service**.

---

## Notes

- Ensure the sidecar container is properly configured before deploying.  
- The application container will only start after the sidecar container has successfully started, maintaining proper startup order.  
- Both containers will now be listed in the updated ECS task definition.

---

2. In the **Storage and Logging** section:  
   - Mount the shared volume exported by the sidecar container.  
   - This allows the application container to access the Lacework agent executable.  
3. Set the **Startup Dependency Ordering**:  
   - Container name: `datacollector-sidecar`  
   - Condition: `SUCCESS`  
   - This ensures the application container starts only after the sidecar has successfully started.  
4. Click **Update** to update the application container definition.  
5. Create a new revision of the task definition by clicking **Create**.  

---


## Best Practices (Optional)

- Set the following environment variables in the application container:  
  - `LaceworkAccessToken`  
  - `LaceworkServerUrl`  

- ECS uses a **rolling update** strategy by default, so redeploying the service after updating the task definition **will not interrupt your running service**.

---

## Notes

- Ensure the sidecar container is properly configured before deploying.  
- The application container will only start after the sidecar container has successfully started, maintaining proper startup order.  
- Both containers will now be listed in the updated ECS task definition.

---
