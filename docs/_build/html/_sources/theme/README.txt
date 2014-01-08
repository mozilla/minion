Mozilla sphinx's theme
######################

This is a version of Mozilla's sandstone theme, for `the Sphinx documentation
engine. <http://sphinx.pocoo.org>`_.

Okay, how do I install it?
==========================

You need to install it locally and configure Sphinx to use it. In your `conf.py` file::

    import mozilla_sphinx_theme                                       
    import os                                                         
                                                                      
    html_theme_path = [os.path.dirname(mozilla_sphinx_theme.__file__)]
                                                                      
    html_theme = 'mozilla'                                            

Also, take care and remove the `pygments_style` configuration, as it may not be
of the better taste with the mozilla's theme.

Enjoy!
