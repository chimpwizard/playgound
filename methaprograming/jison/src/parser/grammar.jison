%lex

digit                       [0-9]
id                          [a-zA-Z][a-zA-Z0-9]*


%%

\s*\n\s*                /* ignore */
\s+                     /* ignore */
"//".*                  /* ignore comment */

"type"				    return 'CUSTOMTYPE';
"entity"				return 'ENTITY';
"is"				    return 'IS';
"enum"				    return 'ENUMERATION';
"relationship"			return 'RELATIONSHIP';
"service"				return 'SERVICE';
"var"                   return 'VARIABLE';
"required"              return 'REQUIRED';
"to"				    return 'TO';
"min"                   return 'MIN';
"max"                   return 'MAX';

":"				        return 'COLON';
","				        return 'COMMA';
";"				        return 'SEMICOLON';

"{"				        return 'OPENBRACE';
"}"				        return 'CLOSEBRACE';

"("				        return 'OPENPARENTECIS';
")"				        return 'CLOSEPARENTECIS';

"["				        return 'OPENSQUARE';
"]"				        return 'CLOSESQUARE';

"@"                     return 'ANOTATION';
"="                     return 'LET';

(OneToMany|OneToOne|ManyToMany|ManyToOne)             return 'RELATION';

(number|string|boolean|datetime) return 'TYPE';

[0-9]+                   return 'NUMBER';

[a-zA-Z_][a-zA-Z_0-9]+               return 'LITERAL';





\"[^\"]*\"|\'[^\']*\'		yytext = yytext.substr(1,yyleng-2); return 'STRING';


<<EOF>>				    return 'EOF';

"[[".*?
                        %{
                            yytext = parserlib.substring(yytext, 2, -1);
                            return 'CONTENT';
                        %}


/lex

%%

Program
    : Statements EOF
        {
            $$ = $1;
            return $$;
        }
    ;

Statements
    : Statement
    | Statements Statement
        {
            //$$ = _.concat($1, $2);
            $$ = _.merge($1, $2);
        }
    |
        {
            //$$ = []
            $$ = {}

        }
    ;

Statement
    : EntityStatement
    | TypeStatement
    | EnumerationStatement
    | RelationshipStatement
    | ServiceStatement
    | VariableStatement
    ;

AnotationStatements
    : AnotationStatement
    | AnotationStatements AnotationStatement
        {
            //$$ = _.concat($1, $2);
            $$ = _.merge($1, $2);
        } 
     |
        {
            //$$ = []
            $$ = {}
        }
    ;



AnotationStatement
    : ANOTATION LITERAL OPENPARENTECIS AnotationProperties CLOSEPARENTECIS
        {
            var anotation = $2;
            var annotations = {};
            _.set(annotations,anotation,{
                    "name": $2,
                    "attributes": $4,
            });
            $$ = annotations;

        }
    ;

TypeStatement
    : CUSTOMTYPE LITERAL OPENBRACE CLOSEBRACE
        {
            var type = $2;
            var types = {};
            _.set(types,type,{
                    "name": $2
            });
            $$ = {"types" : types};
        }
    | CUSTOMTYPE LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var type = $2;
            var types = {};
            _.set(types,type,{
                "name": $2,
                "attributes": $4
            });
            $$ = {"types" : types};
        }
    | AnotationStatements CUSTOMTYPE LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var type = $3;
            var types = {};
            _.set(types,type,{
                "name": $3,
                "attributes": $5,
                "anotations": $1
            });
            $$ = {"types" : types};
        }
    | CUSTOMTYPE LITERAL TYPE STRING SEMICOLON
        {
            var type = $2;
            var types = {};
            _.set(types,type,{
                "name": $1,
                "attributes": [
                    {
                        "name":$2,
                        "type":$3,
                        "mask":$4
                    }
                ]
            });
            $$ = {"types" : types};
        }
    ;

EntityStatement
    : ENTITY LITERAL OPENBRACE CLOSEBRACE
        {
            var entity = $2;
            var entities = {};
            _.set(entities,entity,{
                    "name": $2
            });
            $$ = {"entities" : entities};
        }
    | ENTITY LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var entity = $2;
            var entities = {};
            _.set(entities,entity,{
                    "name": $2,
                    "attributes": $4
            });
            $$ = {"entities" : entities};

        }
    | AnotationStatements ENTITY LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var entity = $3;
            var entities = {};
            _.set(entities,entity,{
                "name": $3,
                "attributes": $5,
                "anotations": $1
            });
            $$ = {"entities" : entities};
        }
    | ENTITY LITERAL IS LITERAL OPENBRACE CLOSEBRACE
        {
            var entity = $2;
            var entities = {};
            _.set(entities,entity,{
                "name": $2,
                "is": $4
            });
            $$ = {"entities" : entities};

        }
    | ENTITY LITERAL IS LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var entity = $2;
            var entities = {};
            _.set(entities,entity,{
                "name": $2,
                "is": $4,
                "attributes": $6
            });
            $$ = {"entities" : entities};

        }
    | AnotationStatements ENTITY LITERAL IS LITERAL OPENBRACE EntityAttributes CLOSEBRACE
        {
            var entity = $3;
            var entities = {};
            _.set(entities,entity,{
                "name": $3,
                "is": $5,
                "attributes": $7,
                "anotations": $1
            });
            $$ = {"entities" : entities};
        }
    ;


EntityAttributes
    : EntityAttribute
    | EntityAttributes EntityAttribute
        {
            //$$ = _.concat($1, $2);
            $$ = _.merge($1, $2);
        }
    | 
        {
            //$$ = []
            $$ = {}
        }
    ;

//TODO: Consider VARIABLES as values|validations
EntityAttribute
    : LITERAL TYPE REQUIRED SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2,
                "required": true
            });
            $$ = attributes;

        }
    | LITERAL TYPE SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2
            });
            $$ = attributes;

        }
    | LITERAL TYPE STRING SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2,
                "mask": $3
            });
            $$ = attributes;

        }
    | LITERAL TYPE REQUIRED STRING SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2,
                "required": true,
                "mask": $5
            });
            $$ = attributes;

        }
    | LITERAL TYPE MIN OPENPARENTECIS NUMBER CLOSEPARENTECIS MAX OPENPARENTECIS NUMBER CLOSEPARENTECIS SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2,
                "min": $5,
                "max": $9
            });
            $$ = attributes;

        }
    | LITERAL LITERAL SEMICOLON
        {
            var attribute = $1;
            var attributes = {};
            _.set(attributes,attribute,{
                "name": $1,
                "type": $2
            });
            $$ = attributes;

        }
    ;

EnumerationStatement
    : ENUMERATION LITERAL OPENBRACE EnumerationAttributes CLOSEBRACE
        {
            var enumertion = $2;
            var enumertions = {};
            _.set(enumertions,enumertion,{
                    "name": $2,
                    "values": $4
            });
            $$ = {"enumertions" : enumertions};


        }
    ;

EnumerationAttributes
    : EnumerationAttribute
    | EnumerationAttributes EnumerationAttribute
        {
            $$ = _.concat($1, $2);
        }
    | 
        {
            $$ = []
        }
    ;

EnumerationAttribute
    : LITERAL
        {
            $$ = $1
        }
    | LITERAL COMMA
        {
            $$ = $1
        }
    ;

RelationshipStatement
    : RELATIONSHIP RELATION OPENBRACE Relationship CLOSEBRACE 
        {
            var type = $2;
            var pair = $4;

            _.set(pair,"type", type);

            var relationships = {};
            var key = pair.from.entity + "-" + pair.to.entity;            

            var relation = {} 
            _.set(relation,key, pair);

            _.merge(relationships, relation);

             var entities = {};
             var entityFrom = {}
             var entityTo = {}

             _.set(entityFrom,pair.from.entity , {"relationships": relation});
             _.set(entityTo,pair.to.entity , {"relationships": relation});

             _.merge(entities, entityFrom);
             _.merge(entities, entityTo);

            $$ = {
                    "relationships" : relationships,
                    "entities" : entities
                };
        }
    ;

Relationship
    : LITERAL OPENBRACE RelationAttribute CLOSEBRACE TO LITERAL OPENBRACE RelationAttribute CLOSEBRACE
        {
            $$ = {
                "from": {
                    "entity":$1,
                    "attribute": $3
                },
                "to": {
                    "entity": $6,
                    "attribute": $8
                }
            };
            
        }
    ;

RelationAttribute
    : LITERAL
        {
            $$ = {
                "name": $1
            }
        }
    | LITERAL OPENPARENTECIS LITERAL CLOSEPARENTECIS
        {
            $$ = {
                "name": $1,
                "show": $3
            }
        }
    ;


AnotationProperties
    : AnotationProperty
    | AnotationProperties COMMA AnotationProperty
        {
            //$$ = _.concat($1, $3);
            $$ = _.merge($1, $3);
        }
    |
        {
            //$$ = []
            $$ = {}
        }
    ;

AnotationProperty
    : LITERAL LET STRING 
        {
            $$ = {"properties" : {
                "name": $1,
                "value": $3
            }}
        }
    | LITERAL LET ArrayStatement
        {
            $$ = {"properties" : {
                "name": $1,
                "value": $3
            }}
        }
    ;



VariableStatement
    : VARIABLE LITERAL LET LITERAL SEMICOLON
        {
            var variable = $2;
            var variables = {};
            _.set(variables,variable,{
                    "name": $2,
                    "value": $4
            });
            $$ = {"variables" : variables};

        }
    | VARIABLE LITERAL LET STRING SEMICOLON
        {
            var variable = $2;
            var variables = {};
            _.set(variables,variable,{
                    "name": $2,
                    "value": $4
            });
            $$ = {"variables" : variables};

        }
    | VARIABLE LITERAL LET NUMBER SEMICOLON
        {
            var variable = $2;
            var variables = {};
            _.set(variables,variable,{
                    "name": $2,
                    "value": $4
            });
            $$ = {"variables" : variables};
        }
    ;

ArrayStatement
    : OPENSQUARE ArrayElements CLOSESQUARE
        {
            $$ = [$2]
            }
        }
    | 
    ;

ArrayElements
    : STRING
    | STRING COMMA STRING
        {
            $$ = _.concat($1, $3);
        }
    |
        {
            $$ = []
        }
    ;

ServiceStatement
    : SERVICE LITERAL OPENBRACE CLOSEBRACE
        {
            $$ = {"services" : {
                "service": {
                    "name": $2
                }
            }}
        }
    | SERVICE LITERAL OPENBRACE ServiceActions CLOSEBRACE
        {
            $$ = {"services" :{
                "service": {
                    "name": $2,
                    "actions": $4
                }}
            }
        }
    | AnotationStatements SERVICE LITERAL OPENBRACE ServiceActions CLOSEBRACE
        {
            $$ = {"services" :{
                "service": {
                    "name": $3,
                    "actions": $5,
                    "anotations": $1
                }
            }}
        }
    ;

ServiceActions
    : ServiceAction
    | ServiceActions COMMA ServiceAction
        {
            //$$ = _.concat($1, $3);
            $$ = _.merge($1, $3);
        }
    | 
        {
            //$$ = []
            $$ = {}
        }
    ;

//TODO: Consider VARIABLES as values|validations
ServiceAction
    : STRING COLON BlockStatement
        {
            $$ = {"actions" : {
                "name": $1,
                "block": $4
            }}
        }
    
    ;

BlockStatement
    : OPENBRACE CONTENT CLOSEBRACE
        {
            $$ = $1
        }
    ;

%%
_ = require("lodash")
function hello(obj) {
    console.log("HELLO");
}