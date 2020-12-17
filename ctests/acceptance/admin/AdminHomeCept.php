<?php
$I = new AcceptanceTester($scenario);
$I->wantTo('管理画面に正常にログインできるかを確認する');

if (getenv('ADMIN_DIR') != 'admin/') {
    $html_dir = __DIR__.'/../../../html/';
    if (!file_exists($html_dir.'admin')) {
        mkdir($html_dir.'admin');
        copy($html_dir.getenv('ADMIN_DIR').'home.php', $html_dir.getenv('ADMIN_DIR').'home.php');
    }

    $I->expect('/admin/home.php での認証を確認します');
    $I->amOnPage('/admin/home.php');
    $I->see('ログイン認証の有効期限切れの可能性があります。');
}

$I->amOnPage('/'.getenv('ADMIN_DIR'));
$I->fillField('input[name=login_id]', 'admin');
$I->fillField('input[name=password]', 'password');
$I->click(['css' => '.btn-tool-format']);

$I->see('ログイン : 管理者 様');
