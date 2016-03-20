import jenkins.model.*

def instance = Jenkins.getInstance()

final String name = "{{ java_proxy_host }}"
final int port = {{ java_proxy_port }}
final String userName = "{{ java_proxy_login }}"
final String password = "{{ java_proxy_password }}"
final String noProxyHost = "{{ java_no_proxy_host }}"

final def pc = new hudson.ProxyConfiguration(name, port, userName, password, noProxyHost)
instance.proxy = pc
instance.save()
println "Proxy settings updated!"
