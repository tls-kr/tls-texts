xquery version "3.1";
(:~ The post-install runs after contents are copied to db.
 :
 : @version 1.0.0
 : @see http://www.adamretter.org.uk/presentations/security-in-existdb_xml-prague_existdb_20120210.pdf
 : @see http://localhost:8080/exist/apps/doc/security.xml?field=all&id=D3.21.11#permissions
 :)

import module namespace dbutil="http://exist-db.org/xquery/dbutil" at "/db/apps/shared-resources/content/dbutils.xql";

declare namespace repo="http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: restricted collections :)
declare variable $hidden := $target || "/chant";

(:~
 : Restrict non-public resources
:)
declare function local:special-permission($uri as xs:string, $perm as xs:string) as empty-sequence() {
for $res in xmldb:get-child-resources($uri)
let $path := $uri || "/" || $res
return
  ( sm:chown(xs:anyURI($path), "tls"),
    sm:chgrp(xs:anyURI($path), "tls-user"),
    sm:chmod(xs:anyURI($path), $perm) )
};

declare function local:chant-permission($uri as xs:string, $perm as xs:string) as empty-sequence() {
for $child in xmldb:get-child-collections($uri)
let $path := $uri || "/" || $child
return
   local:special-permission($path, $perm)
};

(:~
 : If user had no submodule access create an empty collection
:)
let $restricted := xmldb:collection-available($hidden) or xmldb:create-collection( $target, "chant" )


return
(: Ignotus Peverell :)
(: root of restricted resources is visible to world …:)
sm:chown(xs:anyURI($hidden), "tls"),
sm:chgrp(xs:anyURI($hidden), "tls-user"),
sm:chmod(xs:anyURI($hidden), 'rwxrwxr-x'),

(: only hide the resources, not the collections :)
local:chant-permission($hidden, 'rwxrwx---')

