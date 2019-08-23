# Get-Workspace

## Description
	Small utility to get a project from TFS and map the appropriate workspace.

## DESCRIPTION
    Will perform the following:
    1.  Ascertain which TFS collection the project belongs to
    2.  Map the specified workspace to the appropriate project (default is study)
    3.  Fetch the latest specified branch from tfs
    4.  Copy any SwitchStartupProject json config files (if existing)
    5.  Launch visual studio

## Usage
1. Default usage - retrieve specified project's DEV branch with a workspace of the study name

    `get-workspace.ps1 STUDY123`

1. Retrieve the studies main branch.  Mapped to workspace named `STUDY123`

    `get-workspace.ps1 STUDY123 -branch main`

1. Retrieve a studies main branch into workspace `STUDY123_OTHER`

    `get-workspace.ps1 STUDY123 -branch main -workspace STUDY123_OTHER`