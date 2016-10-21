package Sparrow::Commands::RemoteTask;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use Sparrow::Commands::Plugin;
use Sparrow::Commands::Task;
use Carp;
use File::Basename;
use File::Path;

use JSON;
use Data::Dumper;
use File::Copy;

use Term::ANSIColor;

our @EXPORT = qw{

    remote_task_upload
    remote_task_install
    remote_task_share
    remote_task_hide
    remote_task_list

};


sub remote_task_upload {

    my $path = shift or confess "usage: remote_task_upload(path)";

    my ($project, $task) = split '/', $path;

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task" unless  -d sparrow_root."/projects/$project/tasks/$task";

    my $task_set = task_get($project,$task);

    confess "plugin not set" unless $task_set->{'plugin'};

    my $plugin_name = $task_set->{plugin};

    my $pdir = sparrow_root."/plugins/".($task_set->{'install_dir'});

    confess 'plugin not installed' unless -d $pdir;

    my $plugin_name = $task_set->{plugin};

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    my $suite_ini_path = sparrow_root."/projects/$project/tasks/$task/suite.ini";

    execute_shell_command(
        "curl -f -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/upload '.
         "-d project_name='$project' ".
         "-d task_name='$task' ".
         "-d plugin_name='$plugin_name' ".
         "-d suite_ini=\@$suite_ini_path ",
        silent => 1 ,
    );
    print "\n";
}


sub remote_task_list {

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    execute_shell_command(
        "curl -f -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/list',
        silent => 1 ,
    );
    print "\n";
}


1;

