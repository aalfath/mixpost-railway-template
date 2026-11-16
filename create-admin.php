<?php
// Creates the first Mixpost admin from MIXPOST_ADMIN_EMAIL and
// MIXPOST_ADMIN_PASSWORD, but only when the users table is empty.
// Later password changes in the Mixpost UI are never overwritten.
require '/var/www/html/vendor/autoload.php';
$app = require '/var/www/html/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$userClass = Inovector\MixpostAuth\MixpostAuth::getUserClass();

if ($userClass::query()->exists()) {
    echo "Mixpost admin: users already exist, nothing to do.\n";
    exit(0);
}

$email = getenv('MIXPOST_ADMIN_EMAIL') ?: 'admin@example.com';
$password = getenv('MIXPOST_ADMIN_PASSWORD') ?: '';

if (strlen($password) < 12) {
    fwrite(STDERR, "MIXPOST_ADMIN_PASSWORD must be set (at least 12 characters) to create the first admin.\n");
    exit(1);
}

$userClass::create([
    'name' => 'Admin',
    'email' => $email,
    'password' => bcrypt($password),
]);

echo "Mixpost admin: created $email (password from MIXPOST_ADMIN_PASSWORD).\n";
