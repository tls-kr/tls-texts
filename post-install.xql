xquery version "3.1";
(:~ The post-install runs after contents are copied to db.
 :
 : @version 1.0.0
 : @see http://www.adamretter.org.uk/presentations/security-in-existdb_xml-prague_existdb_20120210.pdf
 : @see http://localhost:8080/exist/apps/doc/security.xml?field=all&id=D3.21.11#permissions
 :)


declare namespace repo="http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: invisible collections :)
declare variable $hidden := $target || "/chant";

(:~
 : Restrict non-public resources
:)
declare function local:special-permission($uri as xs:string, $perm as xs:string) as empty-sequence() {
for $res in xmldb:get-child-resources($uri)
let $path := $uri || "/" || $res
return
  ( sm:chown(xs:anyURI($path), "admin"),
    sm:chgrp(xs:anyURI($path), "dba"),
    sm:chmod(xs:anyURI($path), $perm) )
};

(:~
 : If user had no submodule access create an empty collection
:)
let $restricted := xmldb:collection-available($hidden) or xmldb:create-collection( $target, "chant" )


return
(: Ignotus Peverell :)
(: root of restricted resources is visible to world …:)
sm:chown(xs:anyURI($hidden), "admin"),
sm:chgrp(xs:anyURI($hidden), "dba"),
sm:chmod(xs:anyURI($hidden), 'rwxrwxr--'),
(: … preinstalled contents are not :)
local:special-permission($hidden, 'rwxrwx---')
