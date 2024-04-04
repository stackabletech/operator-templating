---
name: Normal issue
about: This is just a normal empty issue with a simple checklist
title: ''
labels: ''
assignees: ''

---

# Title

- Ensure the title is specific and descriptive
- Avoid acronyms if possible

## Description

- Briefly describe what this epic aims to achieve
- "What" are we trying to achieve

## Value

- Clearly define the value this brings to customers or why else it is important if not _directly_ for customers (e.g. internal tooling or improvements, technical debt, ...)
- "Why" do we want to do this
- Explain how to showcase the outcome of this issue to users/customers or developers (add tasks for this if needed), how can we market this

Examples:
- "We want CRD versioning so we can make backwards compatible changes to our CRDs"
- "We want CRD versioning because we're making contractual stability promises to our customers around CRDs and we can o"

## Dependencies

- Consider and name any internal and external dependencies and constraints
- List all known necessary resources (e.g. cluster, customers, people, repositories, libraries...)

- Example: This epic will require changes to docker image XY, it will require a change to the listener operator and we'll need an OpenShift 4.15 cluster to test


## Tasks

- List all known tasks that need to be completed to finish this epic
    - Not all tasks might be known at the beginning!
    - Task types
        - Technical
        - Testing
        - Documentation
        - Marketing / Showcase
- Initial tasks might just be _separate_ research tasks which, upon completion, lead to more tasks in this epic
- When creating the list of tasks make sure to put them in an order and focus on creating minimum marketable features

## Acceptance Criteria

- List acceptance criteria
- Define clear objective criteria for when we would consider this issue "Done"
    - It should consider the same things as mentioned above (Testing, Docs, ...)
- TODO: This needs to be fleshed out, I'm not good at writing acceptance criteria
    - @NickLarsenNZ: As long as we avoid generic copy/paste criteria (easily ignored), but leave them open-ended enough that people can achieve them without having to be mind readers.
      Example of a poor criterion: ***All tests pass*** (that should be implied for anything).
      Example of a better criterion: ***Traces are exported via OTLP and can be seen in Jaeger (or equivalent trace visualisation tool)*** (achieves a goal, while only being as prescriptive as necessary).

## (Information Security) Risk Assessment

- Outline any information security (this includes cybersecurity) risks and the controls how to mitigate them
- This is relevant for ISO 27001, the Cyber Resilience Act and other standards/norms
- Examples:
    - Does this open any new ports? If so, how are they secured
    - Do we ask for the least amount of privileges required
    - Does this require any secrets?
    - Which ciphers might be used and how can they be configured
    - Does it introduce a new dependency? Have you reviewed it for vulnerabilities, licenses issues, recent activity etc.
    - ...

### Quality

- Outline how this epic will be tested
- Compatibility: Ensure compatibility with all our supported versions (e.g. Kubernetes, OpenShift, product versions)


## Release Notes

- Write a short sentence or abstract that can go into the release notes
- This way it is also documented for anyone finding _just this_ epic later
- This does not need to be filled out during refinement but can/should be added later before closing the epic

# Todos / Remarks

<!-- We can use comments to prompt the writer, which still hiding it in the rendered view. That way they don't need to delete anything.-->

This section is not meant to end up in the final issue, please delete it before submitting the issue.

- [ ] Fill out as many sections above as you can, not everything is known at the beginning. Delete everything that is not relevant for this particular issue.
- [ ] Add appropriate labels (TODO: Link to a document describing our labels)


- There are different types of epics
    - e.g. "Update product versions"
    - e.g. "Implement new feature"
- In the whole issue write out all acronyms that are not industry standard at least once. Example: OpenPolicyAgent (OPA)
- If this is part of another issue please make sure to link the two in both places (parent & child)
- If CRD changes (not necessarily breaking) are required, make sure structs/enums/fields are documented and are rendered properly in the CRD generation tool
- Also see our [Development Philosophy](https://app.nuclino.com/Stackable/Stackable-Handbook/Development-Philosophy-ba280b20-b8cd-4fb6-a863-ff6d8c9f1af2)
