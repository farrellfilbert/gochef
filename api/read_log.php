<?php
if (file_exists('checkout_error.log')) {
    echo file_get_contents('checkout_error.log');
} else {
    echo "Log file not found.";
}
?>
