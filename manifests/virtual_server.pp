define keepalived::virtual_server(
  $ensure = present,
  $sorry_server = false,
  $persistence_timeout = '60',
  $delay_loop = 10,
  $lb_algo = 'wrr',
  $lb_kind,
  $port,
  $protocol,
  $ip,
  $bindto = false,
  $virtualhost = false
) {

  $clean_name = regsubst($name, ' ', '-', 'G')
  $file_name =  "/etc/keepalived/concat/virtual_server.${clean_name}.${ip}"

  if ($ensure == 'present') {
    concat { "$file_name:${port}":
        notify => Exec['concat_keepalived.conf'];
    }

    concat::fragment {
      "${file_name}.${port}.header":
        content => template("keepalived/virtual_server.header.erb"),
        target  => "$file_name:${port}",
        order   => 01;

      "${file_name}.${port}.footer":
        content => template("keepalived/virtual_server.footer.erb"),
        target  => "$file_name:${port}",
        order   => 99;
    }

    if $bindto {
      Keepalived::Real_server <<| virtual_server_name == $name |>> {
        bindto => $bindto
      }
    } else {
        Keepalived::Real_server <<| virtual_server_name == $name |>>
    }
  } else {
    file { $file_name:
      ensure => $ensure,
    } 
  }
}
