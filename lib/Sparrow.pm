package Sparrow;

our $VERSION = '0.0.3';

1;

__END__

=encoding utf8


=head1 SYNOPSIS

Sparrow - L<swat|https://github.com/melezhik/swat> based monitoring tool.


=head1 CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


=head1 FEATURES

=over

=item *

console client to setup and run swat test suites


=item *

installs and runs sparrow plugins - shareable swat test suites


=item *

ability to run tests remotely over rest API (TODO)


=back


=head1 DEPENDENCIES

git, curl, bash


=head1 INSTALL

    sudo yum install git
    sudo yum install curl
    
    cpanm Sparrow


=head1 USAGE

These are actions provided by sparrow console client:


=head2 create a project

I<sparrow project $project_name create>

Create a sparrow project.

Sparrow project is a container for swat test suites and applications.

Sparrow project is where one run swat tests against different applications.

    sparrow project foo create

To get project info say this:

I<sparrow project $project_name info>

For example:

    sparrow project foo info


=head2 download and install swat plugins

I<sparrow plg install $plugin_name>

Sparrow plugin is a shareable swat test suite.

One could install sparrow plugin and then run related swat tests, see L<check_site|#run-swat-tests> action.

    echo swat-nginx | https://github.com/melezhik/swat-nginx.git >> ~/sparrow/sparrow.list
    sparrow plg install swat-nginx
    sparrow plg install swat-tomcat

Check L<sparrow-plugins|#sparrow-plugins> section to know more about sparrow plugin configuration.

To see available plugin list say this:

I<sparrow plg list>

To see installed plugin list say this:

I<sparrow plg list --local>

To see installed plugin info say this:

I<sparrow plg info $plugin_name>

To update installed plugin:

I<sparrow plg update $plugin_name>

This command simple execute `git pull' for cloned git repository

For example:

    sparrow plg update swat-tomcat

To remove installed plugin:

I<sparrow plg remove $plugin_name>

For example:

    sparrow plg remove swat-tomcat


=head2 link plugins to a project

I<sparrow project $project_name add_plg $plugin_name>

Swat project could I<link> to one or more plugins.

That means one may run different swat test suites represented by plugins against project's sites.

So linked plugins could be run against sites in sparrow project.

    sparrow project foo add_plg nginx
    sparrow project foo add_plg tomcat
    
    # and then add some sites


=head2 create sites

I<sparrow project $project_name add_site $site_name $base_url>

Sparrow site is a abstraction of web application to run swat tests against.

Sparrow site have a name and base URL.

Site's base URL is root http URL to send http requests to when running swat test suites against a site.

Base URL should be curl compliant.

Add_site command examples:

    sparrow project foo add_site nginx_proxy http://127.0.0.1
    sparrow project foo add_site tomcat_app 127.0.0.1:8080
    sparrow project foo add_site tomcat_app my.host/foo/bar


=head2 run swat tests

I<sparrow project $project_name check_site $site_name $plugin_name>

Once sparrow project is configured and has some  sites and plugins one could run swat test suites against projects sites.

Check_site command examples:

    # run swat-nginx test suite for application nginx_proxy
    sparrow project foo check_site nginx_proxy swat-nginx
    
    # run swat-tomcat test suite for application tomcat_app
    sparrow project foo check_site tomcat_app swat-tomcat


=head2 customize swat settings for site

I<sparrow project $project_name swat_setup $site_name>

Swat_setup action allow to customize swat settings, using swat.ini file format.

This command setups L<swat ini file|https://github.com/melezhik/swat#swat-ini-files> for given site .

    export EDITOR=nano
    sparrow project foo swat_setup nginx_proxy
    
        port=88
        prove_options='-sq'

More information on swat ini files syntax could be found here - L<https://github.com/melezhik/swat#swat-ini-files|https://github.com/melezhik/swat#swat-ini-files>


=head2 run swat tests remotely

NOT IMPLEMENTED YET.

I<GET /$project_name/check_site/$site_name/$plugin_name>

Sparrow rest API allow to run swat test suites remotely over http.

    # runs sparrow rest API daemon
    sparrowd
    
    # runs swat tests via http call
    curl http://127.0.0.1:5090/foo/check_site/nginx_proxy/swat-nginx


=head1 SPARROW PLUGINS

Sparrow plugins are shareable swat test suites installed from remote git repositories.

To install sparrow plugins one should configure sparrow plugin list (SPL).


=head1 SPARROW PLUGINS LIST

Sparrow plugins list is represented by text file ~/sparrow/sparrow.list

SPL file contains lines of the following format:

I<$plugin_name $git_repo_url>

Where:

=over

=item *

gitI<repo>url - is git repository URL


=item *

plugin_name - is name of sparrow plugin.


=back

For example:

    swat-yars https://github.com/melezhik/swat-yars.git
    metacpan https://github.com/CPAN-API/metacpan-monitoring.git

To install swat-yars plugin one should do following

    # add plugin to SPL
    echo swat-yars https://github.com/melezhik/swat-yars.git >> ~/sparrow/sparrow.list
    
    # install plugin
    sparrow plg install swat-yars


=head1 COMMUNITY SPARROW PLUGINS

Community sparrow plugins are public plugins listed at L<https://github.com/melezhik/sparrow-hub|https://github.com/melezhik/sparrow-hub>

Sparrow community members are encouraged to create a useful plugins and have them listed here.

To add sparrow public plugins to your SPL do this:

    curl https://raw.githubusercontent.com/melezhik/sparrow-hub/master/sparrow.list >> ~/sparrow/sparrow.list


=head1 CREATING SPARROW PLUGINS

To accomplish this task one should be able to

=over

=item *

init local git repository and map it to remote one



=item *

create swat test suite



=item *

add sparrow related configuration



=item *

commit changes and then push into remote



=back


=head2 Init git repository

Sparrow expects your swat test suite will be under git and will be accessed as remote git repository:

    git init .
    echo 'my first sparrow plugin' > README.md
    git add README.md
    git commit -m 'my first sparrow plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master


=head2 Create swat test suite

To get know what swat is and how to create swat tests please follow swat project documentation -
L<https://github.com/melezhik/swat|https://github.com/melezhik/swat>.

A simplest swat test suite to check if GET / returns 200 OK would be like this:

    echo 200 OK > get.txt


=head2 Add sparrow related info

As sparrow relies on L<carton|https://metacpan.org/pod/Carton> to handle perl dependencies and execute script
the only minimal requirement is having valid cpanfile on the root directory of your swat test suite project.

For example:

    # cat cpanfile
    
    # yes, we need a swat to run our tests
    require 'swat';
    
    # and some other modules
    require 'HTML::Entities'


=head2 Step by step list

To create sparrow plugin:

    * create local git repository
    * create swat tests
    * swat project root should be current working directory
    * run swat test to ensure that they works fine ( this one is optional but really useful )
    * create cpanfile to declare perl dependencies
    * commit your changes
    * add remote git repository
    * push your changes


=head2 Hello world example

To repeat all told before in a code way:

    git init .
    echo "local" > .gitignore
    echo "require 'swat';" > cpanfile
    echo 200 OK > get.txt
    git add .
    git commit -m 'my first swat plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master

That's it. To use your freshly baked plugin just say this:

    echo my-plugin $your-remote-git-repository >> sparrow.list
    sparrow plg install my-plugin


=head1 AUTHOR

L<Aleksei Melezhik|mailto:melezhik@gmail.com>


=head1 Home page

https://github.com/melezhik/sparrow


=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 THANKS

=over

=item *

to God as - I<For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)>


=back