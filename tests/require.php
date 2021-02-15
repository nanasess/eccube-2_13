<?php
$loader = require __DIR__.'/../data/vendor/autoload.php';

if (!class_exists('PHPUnit_Framework_TestCase')) {
    class_alias('PHPUnit\Framework\TestCase', 'PHPUnit_Framework_TestCase');
}

if (file_exists(__DIR__.'/../data/config/config.php')) {
    require_once __DIR__.'/../data/config/config.php';
} else {
    defined('HTTP_URL') or define('HTTP_URL', 'http://example.com/');
    defined('HTTPS_URL') or define('HTTPS_URL', HTTP_URL);
    defined('ROOT_URLPATH') or define('ROOT_URLPATH', '/');
    defined('ADMIN_DIR') or define('ADMIN_DIR', '');
}

defined('HTML_REALDIR') or define('HTML_REALDIR', __DIR__.'/../html/');
require_once __DIR__.'/../html/define.php';
defined('DATA_REALDIR') or define('DATA_REALDIR', HTML_REALDIR . HTML2DATA_DIR);
if (file_exists(__DIR__.'/../data/cache/mtb_constants.php')) {
    defined('DIR_INDEX_PATH') or define('DIR_INDEX_PATH', '');
    require_once __DIR__.'/../data/cache/mtb_constants.php';
} else{
    defined('MAX_LOG_SIZE') or define('MAX_LOG_SIZE', '1000000');
    defined('MAX_LOG_QUANTITY') or define('MAX_LOG_QUANTITY', 5);
    defined('USE_VERBOSE_LOG') or define('USE_VERBOSE_LOG', false);
    defined('ERROR_LOG_REALFILE') or define('ERROR_LOG_REALFILE', __DIR__.'/../data/logs/error.log');
}

require_once __DIR__.'/../data/app_initial.php';

$classMap = function ($dir) {
    $map = [];
    $iterator = new RegexIterator(
        new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($dir)
        ),
        '/^(?!.+_ex\.php).+\.php$/i',
        RecursiveRegexIterator::MATCH
    );
    foreach ($iterator as $fileinfo) {
        /** @var SplFileInfo $fileinfo */
        $map[(string)str_replace('.'.$fileinfo->getExtension(), '', $fileinfo->getFilename())] = $fileinfo->getPathname();
    }
    return $map;
};
$loader->add('_generated', __DIR__.'/../ctests/_support');
$loader->addClassMap($classMap(__DIR__.'/../ctests'));
$loader->addClassMap($classMap(__DIR__.'/class'));
return $loader;
