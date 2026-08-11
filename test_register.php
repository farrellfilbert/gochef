<?php
$data = array(
    'name' => 'Test Chef',
    'email' => 'testchef3@example.com',
    'password' => '123456',
    'role' => 'chef',
    'kitchen_name' => 'Test Kitchen',
    'phone' => '0812345678',
    'avatar' => 'http://example.com/avatar.jpg',
    'kitchen_avatar' => 'http://example.com/kitchen.jpg',
    'kitchen_cover' => 'http://example.com/cover.jpg'
);

$options = array(
    'http' => array(
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data),
        'ignore_errors' => true
    )
);

$context  = stream_context_create($options);
$result = file_get_contents('https://astroboomin.co/api/register.php', false, $context);

echo "Result: " . $result;
?>
