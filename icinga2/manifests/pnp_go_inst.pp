class icinga2::pnp_go_inst{
	
	$rpm_pnp_hiera = hiera('icinga2::pnp_go_inst::packages')
	$feature_pnp_hiera = hiera_hash('icinga2::pnp_go_inst::feature')
	$file_pnp_hiera = hiera_hash('icinga2::pnp_go_inst::files')
	$folder_pnp_hiera = hiera_hash('icinga2::pnp_go_inst::folder_perm')
	
	
	
	$tag_pnp_rpm = { tag => 'rpm'}
	$tag_pnp_feature = { tag => 'feature' }
	$tag_pnp_files = { tag => 'files' } 
	$tag_pnp_folder = { tag => 'folder' }
	
	
	create_resources(icinga2::pnp_go_inst::packages,$rpm_pnp_hiera,$tag_pnp_rpm)
	create_resources(icinga2::pnp_go_inst::feature,$feature_pnp_hiera,$tag_pnp_feature)
	create_resources(icinga2::pnp_go_inst::files,$file_pnp_hiera,$tag_pnp_files) 
	create_resources(icinga2::pnp_go_inst::folder_perm,$folder_pnp_hiera,$tag_pnp_folder) 
	
	Icinga2::Pnp_go_inst::Packages <| tag == 'rpm' |> -> 
	Icinga2::Pnp_go_inst::Feature <| tag == 'feature' and title !='perfdata' |> ->
	Icinga2::Pnp_go_inst::Files <| tag == 'files' |> ->
	Exec [ 'add spdb_gateway chkconfig' ] ->
	Icinga2::Pnp_go_inst::Folder_perm <| tag == 'folder' |>
	
	 
	 
	  
	exec { "add spdb_gateway chkconfig":
          command  => "chkconfig --add spdb_gateway",
    } 
	
	
	 define icinga2::pnp_go_inst::packages ($rpm){
		package { $rpm:
    			ensure => latest,
  			}
			}
			
	 define icinga2::pnp_go_inst::feature ($feature) {
  		exec { "icinga2-feature-${feature}":
    			path => '/bin:/usr/bin:/sbin:/usr/sbin',
    			unless => "readlink /etc/icinga2/features-enabled/${feature}.conf",
    			command => "icinga2 feature enable ${feature}",
    			notify => Service[icinga2]
  			}
		   }
		   
	define icinga2::pnp_go_inst::files ($files,$user,$mode,$source) {
  	       file { "$files":
        		ensure => "file",
        		owner => $user,
        		group => $user,
        		mode  => $mode,
        		source => "$source",
			notify => Service[icinga2]
 			  }
			}		   
			
			
			define icinga2::pnp_go_inst::folder_perm ($folder){
				exec { "permission-${folder}":
				command  => "chown -R icinga:icinga $folder",
				}

						}
		   
 
}
