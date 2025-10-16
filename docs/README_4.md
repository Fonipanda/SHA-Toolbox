[[_TOC_]]

# workflow-AAP-vm_standard
Workflow AAP for VM standardization configure VM with:
- FS creation with IT rules
- Supervision agent configuration
- Reftec update of VM state
- Illumio in "enforced" mode
- Start a TSM backup
- Logs purge
- Orchestrator agent configuration
- Add the new VM to an existing VIP

Workflow AAP could be used to transfer configuration between old VM to the new one alreday standardized:
- Flow migration (Not fully fonctionnal)
- LibertyCore et Wasbase migration (Under development)
- CFT migration (DEV finished, under testing)

Documentation for each playbook which construct this workflow:
- [standardisation.yml](https://gitlab-dogen.group.echonet/market-place/ap26167/production-as-code-projects/workflow-aap-vm_standard/-/blob/main/standardisation/README.md)
- [orchestrator.yml](https://gitlab-dogen.group.echonet/market-place/ap26167/production-as-code-projects/workflow-aap-vm_standard/-/blob/main/orchestrator/README.md)
- [rebuild.yml](https://gitlab-dogen.group.echonet/market-place/ap26167/production-as-code-projects/workflow-aap-vm_standard/-/blob/main/rebuild/README.md)
- [email.yml](https://gitlab-dogen.group.echonet/market-place/ap26167/production-as-code-projects/workflow-aap-vm_standard/-/blob/main/email/README.md)

## Schemas
```mermaid
flowchart LR

A[Start]


H[Email\nFailed after send email\nif any job failed before]

A --> Standardization --when success--> orchestrator1 
orchestrator1 --always run--> orchestrator_client1
orchestrator1 --always run--> orchestrator_client2
orchestrator1 --always run--> orchestrator_client3
orchestrator_client1 & orchestrator_client2 & orchestrator_client3 --always run--> Rebuild --always run--> H
Standardization --when failed--> H


subgraph Standardization
direction TB
B1[FS creation with IT rules]
B2[Supervision agent configuration]
B3[Reftec update of VM statte]
B4[Illumio in enforced mode]
B5[Start a TSM backup]
B6[Logs purge]
B1 -.-> B2 -.-> B3 -.-> B4 -.-> B5 -.-> B6
end


subgraph orchestrator1 [orchestrator agent - CAN'T FAILED]
direction TB
C1[Check if orchestrator is installed and used]
C2[Get correct client to set]
C3[Config is only on agent]
C4[No agent orchestrator]
C1 -.-> C2 & C3 & C4
end

subgraph orchestrator_client1 [orchestrator client HORSPROD - CAN FAILED]
direction TB
D1[Add agent to client]
D2[Start a backup for autosys box]
D3[No agent orchestrator]
D4[tasks skipped]
D5[No client/serveur orchestrator]
D6[tasks skipped]
D1 -.-> D2
D3 -.-> D4
D5 -.-> D6
end




subgraph orchestrator_client2 [orchestrator client ISOPROD - CAN FAILED]
direction TB
E1[Add agent to client]
E2[Start a backup for autosys box]
E3[No agent orchestrator]
E4[tasks skipped]
E5[No client/serveur orchestrator]
E6[tasks skipped]
E1 -.-> E2
E3 -.-> E4
E5 -.-> E6
end

subgraph orchestrator_client3 [orchestrator client PROD - CAN FAILED]
direction TB
F1[Add agent to client]
F2[Start a backup for autosys box]
F3[No agent orchestrator]
F4[tasks skipped]
F5[No client/serveur orchestrator]
F6[tasks skipped]
F1 -.-> F2
F3 -.-> F4
F5 -.-> F6
end

subgraph Rebuild [Rebuild from old VM - CAN FAILED]
direction TB
G1[Flow migration]
G2[CFT migration]
G3[liberty or wasbase migration]
G1 -.-> G2 -.- G3
end

```


