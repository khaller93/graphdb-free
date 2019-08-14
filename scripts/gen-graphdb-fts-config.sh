#!/bin/sh

echo "
PREFIX luc: <http://www.ontotext.com/owlim/lucene#>

INSERT DATA {"

# Provides a regular expression to identify nodes, which will be excluded from 
# the molecule. Note that for literals and URI local names the regular expression
# is case-sensitive.
if [ ! -z "$CONF_FTS_EXCLUDE" ]; then
	echo "luc:exclude luc:setParam \"$CONF_FTS_EXCLUDE\" ."
fi

# A comma/semi-colon/white-space separated list of entities that will NOT be included
# in an RDF molecule. The example below includes any URI in a molecule, except the 
# two listed.
if [ ! -z "$CONF_FTS_EXCLUDE_ENTITIES" ]; then
	echo "luc:excludeEntities luc:setParam \"$CONF_FTS_EXCLUDE_ENTITIES\" ."
fi

# A comma/semi-colon/white-space separated list of properties that will NOT be traversed
# in order to build an RDF molecule. The example below prevents any entities being added
# to an RDF molecule, if they can only be reached via the two given properties.
if [ ! -z "$CONF_FTS_EXCLUDE_PREDICATES" ]; then
	echo "luc:excludePredicates luc:setParam \"$CONF_FTS_EXCLUDE_ENTITIES\" ."
fi

# Indicates what kinds of nodes are to be included in the molecule. The value can be a 
# list of values from: URI, literal, centre (the plural forms are also allowed: URIs, 
# literals, centres). The value of centre causes the node for which the molecule is built 
# to be added to the molecule (provided it is not a blank node). This can be useful, for 
# example, when indexing URI nodes with molecules that contain only literals, but the 
# local part of the URI should also be searchable.
if [ ! -z "$CONF_FTS_INCLUDE" ]; then
	echo "luc:include luc:setParam \"$CONF_FTS_INCLUDE\" ."
fi

# A comma/semi-colon/white-space separated list of entities that can be included in an RDF 
# molecule. Any other entities are ignored. The example below builds molecules that only 
# contain the two entities.
if [ ! -z "$CONF_FTS_INCLUDE_ENTITIES" ]; then
	echo "luc:includeEntities luc:setParam \"$CONF_FTS_INCLUDE_ENTITIES\" ."
fi

# A comma/semi-colon/white-space separated list of properties that can be traversed in order
# to build an RDF molecule. The example below allows any entities to be added to an RDF 
# molecule, but only if they can be reached via the two given properties.
if [ ! -z "$CONF_FTS_INCLUDE_PREDICATES" ]; then
	echo "luc:includePredicates luc:setParam \"$CONF_FTS_INCLUDE_PREDICATES\" ."
fi

# Indicates what kinds of nodes are to be indexed. The value can be a list of values from: 
# URI, literal, bnode (the plural forms are also allowed: URIs, literals, bnodes).
# Default: "literals"
if [ ! -z "$CONF_FTS_INDEX" ]; then
	echo "luc:index luc:setParam \"$CONF_FTS_INDEX\" ."
fi

# A comma separated list of language tags. Only literals with the indicated language tags 
# are included in the index. To include literals that have no language tag, use the special
# value none.
# Default: "" (which is used to indicate that literals with any language tag are used, including
# those with no language tag)
if [ ! -z "$CONF_FTS_LANGUAGES" ]; then
	echo "luc:languages luc:setParam \"$CONF_FTS_LANGUAGES\" ."
fi

# Sets the size of the molecule associated with each entity. A value of zero indicates that
# only the entity itself should be indexed. A value of 1 indicates that the molecule will
# contain all entities reachable by a single ‘hop’ via any predicate (predicates not included
# in the molecule). Note that blank nodes are never included in the molecule. If a blank node
# is encountered, the search is extended via any predicate to the next nearest entity and so on.
# Therefore, even when the molecule size is 1, entities reachable via several intermediate 
# predicates can still be included in the molecule, if all the intermediate entities are blank 
# nodes. Molecule sizes of 2 and more are allowed, but with large datasets it can take a very 
# long time to create the index.
if [ ! -z "$CONF_FTS_MOLECULE_SIZE" ]; then
	echo "luc:moleculeSize luc:setParam \"$CONF_FTS_MOLECULE_SIZE\" ."
fi

# Indicates whether the RDF weights (if they have been already computed) associated with each
# entity should be used as boosting factors when computing the relevance of a given Lucene query. 
# Allowable values are no, yes and squared. The last value indicates that the square of the RDF 
# Rank value is to be used.
# Default: "no"
if [ ! -z "$CONF_FTS_USE_RDF_RANK" ]; then
	echo "luc:useRDFRank luc:setParam \"$CONF_FTS_USE_RDF_RANK\" ."
fi

echo "luc:$1 luc:createIndex \"true\" ."
echo "}"