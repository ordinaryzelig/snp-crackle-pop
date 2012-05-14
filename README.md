SNP-Crackle-Pop
===============

**ALWAYS SEARCH FOR DOCUMENTS BY `ncbi_id`, NEVER BY MONGO ID.**
See 'Updating stale data' section.

# Updating stale data

NCBI's data changes over time. When it does, SNP-Crackle-Pop data is stale.
Data can be updated through `NCBI::Document.refetch!`.
`refetch!` destroys existing objects and `fetch!`es again.
Because the old document is destroyed, the _id is not currently preserved.

# Limits

## SNP

### Search Results

Most I got without getting a SearchTooBroad exception was 788:
`Snp::SearchRequest.new('btnl2[gene] AND human[ORGN] AND (32363843[CPOS]: 32372943[CPOS])').execute``

### Fetching

Haven't reached a limit, per se.
However, I did get different results submitting the same search a few times.
One request would succeed, another would say that ids were not found, and another would say a different list of ids were not found.

## Locating

Searching 100 locations is OK.

# TODO

* **MORE README**
* Unhandled exception + mailer
* refetch before showing (slows us down).
* Add link to wiki.
