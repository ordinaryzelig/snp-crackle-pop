SNP-Crackle-Pop
===============

**ALWAYS SEARCH FOR DOCUMENTS BY `ncbi_id`, NEVER BY MONGO ID.**
See 'Updating stale data' section.

# Updating stale data

NCBI's data changes over time. When it does, SNP-Crackle-Pop data is stale.
Data can be updated through `NCBI::Document.refetch!`.
`refetch!` destroys existing objects and `fetch!`es again.
Because the old document is destroyed, the _id is not currently preserved.

# TODO

* **MORE README**
* Use VCR more. It was only introduced later when fetching SnpAssociations.
* Periodic re-recording of VCR cassettes.
* Unhandled exception + mailer
* refetch before showing (slows us down).
