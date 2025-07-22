---
title: "Automating Linux"
date: 2023-03-14T20:37:02-03:00
draft: false 
---

Shell scripting has often been referred to as "the glue that holds the Internet together".  While simple, it is incredibly powerful and is used for a huge array of tasks in Enterprise Linux - everything from archiving to health-checking to starting and stopping essential applications and services.

## Automating Environment Configuration
### Ansible
Ansible is a powerful open-source automation tool commonly used by system administrators and DevOps professionals to simplify and streamline various IT tasks. Its primary purpose is to automate repetitive tasks like software provisioning, configuration management, application deployment, and system orchestration.

[Ansible Key Concepts]({{< ref "ansibleKeyConcepts.md" >}})

## Shell Scripting
### The Basics
The concepts and skills used in shell scripting are similar to many other languages - particularly Python (often used as a replacement for shell scripting) or PowerShell (often seen as Microsoft's version of shell scripting!).

[Scripting "Hello World"]({{< ref "scriptingHelloWorld.md" >}})

[Make Decisions with `if/else` Statements]({{< ref "ifElseStatements.md" >}})

[Make Decisions with `case` Statements]({{< ref "caseStatements.md" >}})

### Increasing Robustness 
Once you have mastered the basics, its time to kick it up a notch and make your scripts a bit more robust.

[Testing the Number of Parameters Passed to a Shell Script]({{< ref "testingNumberOfParameters.md" >}})
