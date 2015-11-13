
class icinga2::icinga_installation{
 
	  $service_hiera = hiera_hash('icinga2::icinga_installation::service_restart')
	  
	  $ido_mysql_host = hiera('icinga2::icinga_installation::ido_mysql_host')
	  $ido_enbale_ha = hiera('icinga2::icinga_installation::ido_enbale_ha')
 		
          $ido_db_user = hiera('icinga2::icinga_installation::ido_db_user')
          $ido_db_pass = hiera('icinga2::icinga_installation::ido_db_pass')
          $ido_db_name = hiera('icinga2::icinga_installation::ido_db_name')
          $ido_db_schema = hiera('icinga2::icinga_installation::ido_db_schema')
	  $ido_db_remote_host = hiera('icinga2::icinga_installation::ido_db_remote_host')


		$tag_files = { tag => 'files' } 
		$tag_rpm = { tag => 'rpm'}
		$tag_feature = { tag => 'feature' }
		$tag_dir = { tag => 'dir' }
                $tag_templ = { tag => 'templ'}
		$tag_service = { tag => 'service'}
		$tag_yum = { tag => 'yum' }
	
	$rpm_hiera = hiera('icinga2::icinga_installation::rpm_pre')
	$feature_hiera = hiera_hash('icinga2::icinga_installation::feature')
	$file_hiera = hiera_hash('icinga2::icinga_installation::files')
	$dir_hiera = hiera('icinga2::icinga_installation::dir')
	$templ_hiera = hiera('icinga2::icinga_installation::file_templ')	
        $yum_hiera = hiera('icinga2::icinga_installation::yumrepo')




###Mysql DB create and Populate
 
####Create a database/user icinga and give access
	exec { 'create-mysql-icinga2-ido-db':
    		path => '/bin:/usr/bin:/sbin:/usr/sbin',
    		unless => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name",
    		command => "mysql -uroot -e \"CREATE DATABASE $ido_db_name ; GRANT ALL ON $ido_db_name.* TO $ido_db_user@$ido_db_remote_host IDENTIFIED BY \'$ido_db_pass\';\"",
        	alias => 'create-mysql-icinga2-ido-db',
       		require => Service['mysqld'],
 
		}
 
 
 
##populate the mysql schema from mysql data dump
 
  	exec { 'populate-icinga2-ido-mysql-db':
    		path => '/bin:/usr/bin:/sbin:/usr/sbin',
    		unless => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name -e \"SELECT * FROM icinga_dbversion;\" &> /dev/null",
    		command => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name < $ido_db_schema",
		alias => 'populate_mysql',
		require => Service['mysqld'],
 		 }
 
#sample create_resources(RESOURCE_NAME,$HIERA_VARIABLE_HASH,$TAG_NAME) 
	create_resources(icinga2::icinga_installation::files,$file_hiera,$tag_files) 
	create_resources(icinga2::icinga_installation::packages,$rpm_hiera,$tag_rpm)
	create_resources(icinga2::icinga_installation::service_restart,$service_hiera,$tag_service)
	create_resources(icinga2::icinga_installation::feature,$feature_hiera,$tag_feature)
	create_resources(icinga2::icinga_installation::dir,$dir_hiera,$tag_dir)
        create_resources(icinga2::icinga_installation::files_templ,$templ_hiera,$tag_templ)
        create_resources(icinga2::icinga_installation::yumrepo,$yum_hiera,$tag_templ)


	Icinga2::Icinga_installation::Yumrepo<| tag == 'yum' |> -> 
        Icinga2::Icinga_installation::Packages<| tag == 'rpm' |> -> 
      	Icinga2::Icinga_installation::Service_restart<| tag == 'service' and title == 'mysqld' |> ->
	Exec['create-mysql-icinga2-ido-db'] ->
        Exec['populate-icinga2-ido-mysql-db'] ->
        Icinga2::Icinga_installation::Feature<| tag == 'feature' and title == 'api' |> ->
        Icinga2::Icinga_installation::Feature<| tag == 'feature' and title !='api' |> ->
        Icinga2::Icinga_installation::Dir<| tag == 'dir' |> ->
        Icinga2::Icinga_installation::Files<| tag == 'files' |> ->
        Icinga2::Icinga_installation::Files_templ<| tag == 'templ' |> 
#        Icinga2::Icinga_installation::Service_restart<| tag == 'service' |>








 
 
#Define to enable icinga2 features (eg:api)

 
	define icinga2::icinga_installation::yumrepo ($title,$baseurl,$enabled,$gpgcheck,$descr){

		yumrepo { "$title":
                	baseurl        => $baseurl,
                	enabled        => $enabled,
                	gpgcheck       => $gpgcheck,
                	descr          => $descr,
        #        	alias 	       => $alias,
                 }


}







 
	define icinga2::icinga_installation::feature ($feature) {
  		exec { "icinga2-feature-${feature}":
    			path => '/bin:/usr/bin:/sbin:/usr/sbin',
    			unless => "readlink /etc/icinga2/features-enabled/${feature}.conf",
    			command => "icinga2 feature enable ${feature}",
    			notify => Service[icinga2]
  			}
								}
 
	define icinga2::icinga_installation::dir ($dir) {
  		file { "$dir":
        		ensure => "directory",
        		owner => icinga,
 		        group => icinga,
        		mode  => 644
			  }
								}
 

       define icinga2::icinga_installation::packages ($rpm){
		package { $rpm:
    			ensure => latest,
    	#		require => Yumrepo['icinga2-repo-file'],

  			}
							}
       define icinga2::icinga_installation::service_restart ($service){

		service { $service:
        		enable => true,
    			ensure => running,
		        hasrestart => true,
		#	alias => $service
			}
 									}





      define icinga2::icinga_installation::files ($files,$user,$mode,$source) {
  	       file { "$files":
        		ensure => "file",
        		owner => $user,
        		group => $user,
        		mode  => $mode,
        		source => "puppet:///modules/icinga2${source}",
			notify => Service[icinga2],
 			  }
									}	
 
 
/*	define icinga2::icinga_installation::files_templ ($templ) {
  		file { "$templ":
        		ensure => "file",
        		owner => icinga,
        		group => icinga,
        		mode  => 644,
        		content => template('icinga2/constants_conf.erb'),
			notify => Service[icinga2],
  			}
 
								}*/


	define icinga2::icinga_installation::files_templ ($templ,$user,$mode,$content) {
                file { "$templ":
                        ensure => "file",
                        owner => $user,
                        group => $user,
                        mode  => $mode,
                        content => template($content),
                        notify => Service[icinga2],
                        }

									} 
 
 
 
 
			}
 
