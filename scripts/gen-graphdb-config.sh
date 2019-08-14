#!/bin/sh

# print the prefix of the configuration file
cat << EOF
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix rep: <http://www.openrdf.org/config/repository#>.
@prefix sr: <http://www.openrdf.org/config/repository/sail#>.
@prefix sail: <http://www.openrdf.org/config/sail#>.
@prefix owlim: <http://www.ontotext.com/trree/owlim#>.
EOF

if [ -z "$CONF_REPOSITORY_ID" ]; then
    echo "Repository ID must be specified." 1>&2
    exit 1
fi

# print the header file
cat << EOF
[] a rep:Repository ;
    rep:repositoryID "$CONF_REPOSITORY_ID" ;
    rdfs:label "$CONF_REPOSITORY_LABEL" ;
    rep:repositoryImpl [
EOF

# print the repository type
cat << EOF
        rep:repositoryType "${CONF_REPOSITORY_SAIL_TYPE:-"graphdb:FreeSailRepository"}";
        sr:sailImpl [
EOF

#print the sail type
cat << EOF
            sail:sailType "${CONF_SAIL_TYPE:-"graphdb:FreeSail"}" ;
EOF

# sSpecifies the default namespace for the main persistence file. 
# Non-empty namespaces are recommended, because their use guarantees 
# the uniqueness of the anonymous nodes that may appear within the repository.
if [ ! -z "$CONF_BASE_URL" ]; then
cat << EOF
            owlim:base-URL "$CONF_BASE_URL";
EOF
fi

# Default namespaces corresponding to each imported schema file separated 
# by semicolon and the number of namespaces must be equal to the number of 
# schema files from the imports parameter.
if [ ! -z "$CONF_DEFAULT_NS" ]; then
cat << EOF
            owlim:defaultNS "$CONF_DEFAULT_NS";
EOF
fi

# Defines the initial size of the entity hash table index entries. The bigger
# the size, the less the collisions in the hash table and the faster the entity
# retrieval. The entity hash table will adapt to the number of stored entities
# once the number of collisions passes a critical threshold.
# Default value: 10000000
if [ ! -z "$CONF_ENTITY_INDEX_SIZE" ]; then
cat << EOF
            owlim:entity-index-size "$CONF_ENTITY_INDEX_SIZE";
EOF
fi

# Defines the bit size of internal IDs used to index entities (URIs, blank nodes
# and literals). In most cases, this parameter can be left to its default value.
# However, if very large datasets containing more than 2^31 entities are used,
# set this parameter to 40. Be aware that this can only be set when instantiating
# a new repository and converting an existing repository from 32 to 40-bit entity
# widths is not possible.
# Default value: 32
# Possible values: 32 and 40
if [ ! -z "$CONF_ENTITY_ID_SIZE" ]; then
cat << EOF
            owlim:entity-id-size "$CONF_ENTITY_ID_SIZE";
EOF
fi

# A list of schema files that will be imported at start up. All the statements, 
# found in these files, will be loaded in the repository and will be treated as
# read-only. The serialisation format is determined by the file extension.
if [ ! -z "$CONF_IMPORTS" ]; then
cat << EOF
            owlim:imports "$CONF_IMPORTS";
EOF
fi

# Possible values: file-repository, weighted-file-repository
if [ ! -z "$CONF_REPOSITORY_TYPE" ]; then
cat << EOF
            owlim:repository-type "$CONF_REPOSITORY_TYPE";
EOF
fi

# Sets of axiomatic triples, consistency checks and entailment rules, which
# determine the applied semantics.
# Default value: rdfs-plus-optimized
# Possible values: empty, rdfs, owl-horst, owl-max and owl2-rl and their 
# optimised counterparts rdfs-optimized, owl-horst-optimized, owl-max-optimized 
# and owl2-rl-optimized. A custom ruleset is chosen by setting the path to its rule 
# file .pie.
if [ ! -z "$CONF_RULESET" ]; then
cat << EOF
            owlim:ruleset "$CONF_RULESET";
EOF
fi

# Specifies the folder where the index files will be stored.
if [ ! -z "$CONF_STORAGE_FOLDER" ]; then
cat << EOF
            owlim:storage-folder "${CONF_STORAGE_FOLDER:-$CONF_REPOSITORY_ID}";
EOF
fi

# Default value: false
# Possible value: true, where GraphDB will build and use the context index.
if [ ! -z "$CONF_ENABLE_CONTEXT_INDEX" ]; then
cat << EOF
            owlim:enable-context-index "$CONF_ENABLE_CONTEXT_INDEX";
EOF
fi

# Enables or disables mappings from an entity (subject or object) to its predicates; 
# switching this on can significantly speed up queries that use wildcard predicate 
# patterns.
# Default value: false
if [ ! -z "$CONF_ENABLE_PREDICATE_LIST" ]; then
cat << EOF
            owlim:enablePredicateList "$CONF_ENABLE_PREDICATE_LIST";
EOF
fi

# Turns caching of the literal languages and data-types on and off. If the caching 
# is on and the entity pool is restored from persistence, but there is no such cache
# available on disk, it is created after the entity pool initialisation.
# Default value: false
if [ ! -z "$CONF_IN_MEMORY_LITERAL_PROPERTIES" ]; then
cat << EOF
            owlim:in-memory-literal-properties "$CONF_IN_MEMORY_LITERAL_PROPERTIES";
EOF
fi

#  Enables or disables the storage. The literal index is always built as data is
# loaded/modified. This parameter only affects whether the index is used during 
# query-answering.
# Default value: true
if [ ! -z "$CONF_ENABLE_LITERAL_INDEX" ]; then
cat << EOF
            owlim:enable-literal-index "$CONF_ENABLE_LITERAL_INDEX";
EOF
fi

# Turns the mechanism for consistency checking on and off; consistency checks are
# defined in the rule file and are applied at the end of every transaction, if this
# parameter is true. If an inconsistency is detected when committing a transaction,
# the whole transaction will be rolled back.
# Default value: false
if [ ! -z "$CONF_CHECK_FOR_INCONSISTENCIES" ]; then
cat << EOF
            owlim:check-for-inconsistencies "$CONF_CHECK_FOR_INCONSISTENCIES";
EOF
fi

# Enables or disables the owl:sameAs optimisation.
# Default value: false
if [ ! -z "$CONF_DISABLE_SAMEAS" ]; then
cat << EOF
            owlim:disable-sameAs "$CONF_DISABLE_SAMEAS";
EOF
fi

# Sets the number of seconds after which the evaluation of a query will be terminated;
# values less than or equal to zero mean no limit.
# Default value: 0; (no limit);
if [ ! -z "$CONF_QUERY_TIMEOUT" ]; then
cat << EOF
            owlim:query-timeout "$CONF_QUERY_TIMEOUT";
EOF
fi

# Sets the maximum number of results returned from a query after which the evaluation
# of a query will be terminated; values less than or equal to zero mean no limit.
# Default value: 0; (no limit);
if [ ! -z "$CONF_QUERY_LIMIT_RESULTS" ]; then
cat << EOF
            owlim:query-limit-results "$CONF_QUERY_LIMIT_RESULTS";
EOF
fi

# In this mode, no modifications are allowed to the data or namespaces.
# Default value: false
# Possible value: true, puts the repository in to read-only mode.
if [ ! -z "$CONF_READ_ONLY" ]; then
cat << EOF
            owlim:read-only "$CONF_READ_ONLY";
EOF
fi

# Default value: false
# Possible value: true; if set, a QueryEvaluationException is thrown when 
# the duration of a query execution exceeds the time-out parameter.
if [ ! -z "$CONF_THROW_QUERY_EVALUATION_EXCEPTION_ON_TIMEOUT" ]; then
cat << EOF
            owlim:throw-QueryEvaluationException-on-timeout "$CONF_THROW_QUERY_EVALUATION_EXCEPTION_ON_TIMEOUT";
EOF
fi

cat << EOF
        ]
    ].
EOF

