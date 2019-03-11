xquery version "3.1";

(:~ This library module contains XQSuite tests for the sm-test app.
 :
 : @author Duncan Paterson
 : @version 0.8.0
 :)

module namespace tests="http://hxwd.org/apps/tls-texts/tests";
import module namespace config="http://hxwd.org/apps/tls-texts/config" at "config.xqm";
declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $tests:hidden := $config:app-root || '/chant';

declare
  %test:name('chant should be invisible to user')
  %test:args('guest', 'guest')
  %test:assertError("java:org.xmldb.api.base.XMLDBException")
  %test:args('tls', 'tls')
  %test:assertError("java:org.xmldb.api.base.XMLDBException")
  function tests:out-of-sight($usr as xs:string, $pw as xs:string) as xs:boolean {
    system:as-user($usr, $pw, xmldb:get-child-resources($tests:hidden))
};

declare
  %test:name('chant should be admin only')
  %test:assertTrue
  function tests:reveal() as xs:boolean {
    exists($tests:hidden)
};

declare
  %test:name('user should not access chant')
  %test:args('tls', 'tls')
  %test:assertError
  function tests:no-doc($usr as xs:string, $pw as xs:string) as xs:string* {
      system:as-user($usr, $pw, doc($tests:hidden)//root/text())
};
