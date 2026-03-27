<?php
class floating_button extends rcube_plugin
{
    public $task = '.*';

    function init()
    {
        // $this->include_script('floating.js');
        // $this->include_stylesheet('floating.css');
        // $this->include_stylesheet('https://public.gv.je/static/web/gvbtn/gvbtn.css');
        $this->add_header('<link rel="stylesheet" href="https://public.gv.je/static/web/gvbtn/gvbtn.css">');
        $this->add_hook('render_page', [$this, 'inject_button']);
    }

    function inject_button($args)
    {
        $button = '<a href="https://www.gv.je" class="site-action-button" aria-label="Open action"><img src="https://public.gv.je/static/web/gvbtn/gv-logo-512x512.png" class="site-action-button-img"></a>';
        $args['content'] .= $button;
        return $args;
    }
}