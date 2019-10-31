<?php
$I = new AcceptanceTester($scenario);
$I->wantTo('正常にインストール可能か検証する');
$I->amOnPage('/install');
$I->see('EC-CUBEのインストールを開始します。');

