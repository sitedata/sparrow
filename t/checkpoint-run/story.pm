run_story('project/create');
run_story('project/checkpoint/create');
run_story('plg/install');
run_story('project/checkpoint/set', { url => '127.0.0.1'});
run_story('project/checkpoint/set', { url => '127.0.0.1', plugin => 'foo-test' });
