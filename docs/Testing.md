
1.  **Pester + Simulation**: You verify that your "Zerto Override Logic" works by looking at the **Mock Excel** and **Mock Logs** created during the test. No network needed. 

[Image of the software testing pyramid]

2.  **Manual Simulation**: You run `-Simulation` yourself, open the Excel, and say "Yes, this is exactly what the Zerto Admin needs to see."
3.  **WhatIf**: You run `-WhatIf` against the real ZVM. PowerShell tells you: *"What if: Performing action 'Update Journal' on VPG 'App_Prod'."* This gives you confidence that your API calls are formatted correctly for the real system.
4.  **Live**: You run the script and the changes are made.