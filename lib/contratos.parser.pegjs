L = ___* s:Full_S* ___* {return s}

Full_S = s:S EOS {return s}
S = S_Class / S_Package / S_Process

S_Class = "class " className:class_name sentences:class_sentences {return {className, sentences}}
class_sentences = from_file_sentence? extends_sentence? implements_sentence? uses_packages_sentence? uses_classes_sentence? uses_processes_sentence? has_sentence?
from_file_sentence = ___+ ( "file " ) file:file_name {return {type: "file", file}}
extends_sentence = ___+ ( "extends " ) clazz:class_reference {return {type: "extends", class:clazz}}
implements_sentence = ___+ ( "implements " ) classes:class_reference_list {return {type: "implements", classes:classes}}
uses_packages_sentence = ___+ ( "uses packages " / "uses package " ) packages:packages_list {return {type: "uses package", packages}}
uses_classes_sentence = ___+ ( "uses classes " / "uses class " ) classes:classes_list {return {type: "uses class", classes}}
uses_processes_sentence = ___+ ( "uses processes " / "uses process " ) processes:processes_list {return {type: "uses process", processes}}
has_sentence = ___+ "has" members:( property / method )* {return {type: "has", members}}
property = ___+ accessibility:( "static property " / "property " ) variable:typed_variable value:set_to? {return {type: "member", accessibility, variable, value}}
method = ___+ accessibility:( "static method " / "method " ) method:method_content {return {type: "method", accessibility, method}}
method_content = typed_variable uses_packages_sentence? uses_classes_sentence? uses_processes_sentence? that_receives? that_modifies? that_returns? described_as?
that_receives = ___+ ( "that receives " ) values:typed_variable_list {return {type:"receives", values}}
that_modifies = ___+ ( "that modifies " ) values:variable_reference_list {return {type:"modifies", values}}
that_returns = ___+ ( "that returns " ) value:typed_variable {return {type:"returns", value}}
described_as = ___+ ( "described as " ) value:all_line {return {type:"description", value}}
set_to = ___+ ( "set to " ) value:all_line {return {type:"set to", value}}
all_line = [^\n]* {return text()}

S_Package = "package " packageName:package_name from_file_sentence?

S_Process = "process " method_content

package_name = variable_name
class_name = variable_name
file_name = '"' [^"]+ '"' {return text()}
variable_name = [A-Za-z\$\_] [A-Za-z0-9\$\_]* {return text()}
variable_type = ":" full_type {return text()}
full_type = name:variable_name parametrization:(type_parameters)? {return {type:"type",name,parametrization}}
full_type_list = t1:full_type tN:( full_type_list_continuation )* {return [].concat(t1).concat(tN)}
full_type_list_continuation = "," ___+ t:full_type {return t}
type_parameters = "<" types:full_type_list ">" {return types}
typed_variable = name:variable_name type:variable_type? {return {name, type}}
typed_variable_list = t1:typed_variable tN:typed_variable_list_continuation* {return [].concat(t1).concat(tN)}
typed_variable_list_continuation = "," ___* t:typed_variable {return t}
class_reference = variable_reference
class_reference_list = variable_reference_list
variable_reference = variable_name ( "." variable_name )* {return {type: ["variable reference"], variable: text()}}
variable_reference_list =  v1:variable_reference vN:( variable_reference_others )* {return {type: ["variable reference list"], variables: [].concat(v1).concat(vN)}}
variable_reference_others = "," ___* v:variable_reference {return v}

packages_list = s:variable_reference_list {return {...s, type: s.type.concat("packages list")}}
classes_list = s:variable_reference_list {return {...s, type: s.type.concat("classes list")}}
processes_list = s:variable_reference_list {return {...s, type: s.type.concat("processes list")}}

_ = " " / "\t"
__ = "\r\n" / "\n"
___ = _ / __
EOS = ( ___+ ) / EOF
EOF = !.