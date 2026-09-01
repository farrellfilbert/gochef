<?php
// api/pay.php - Fallback route for GoChef Custom Payment Page
require_once __DIR__ . '/config.php';

$clientSecret = $_GET['client_secret'] ?? '';
$orderId = htmlspecialchars($_GET['order_id'] ?? 'Unknown Order');
$totalAmount = htmlspecialchars($_GET['total'] ?? '0.00');
$kitchenName = htmlspecialchars($_GET['kitchen'] ?? 'GoChef Kitchen');
$kitchenAvatar = htmlspecialchars($_GET['avatar'] ?? '');
$itemsCount = intval($_GET['items'] ?? 1);

if (!$clientSecret) {
    die("<h3>Invalid payment session. Please return to GoChef and try again.</h3><p><a href='/'>Return to Home</a></p>");
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Complete Your Payment - GoChef</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://js.stripe.com/v3/"></script>
    <style>
        :root {
            --bg-color: #0d0f15;
            --surface-color: #171923;
            --surface-card: #1f2230;
            --primary: #FF7A00;
            --primary-hover: #ff8e24;
            --primary-glow: rgba(255, 122, 0, 0.25);
            --border-color: rgba(255, 255, 255, 0.1);
            --text-primary: #FFFFFF;
            --text-secondary: #9BA3AF;
            --text-muted: #6B7280;
            --error: #EF4444;
            --success: #10B981;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            -webkit-tap-highlight-color: transparent;
        }
        body {
            background-color: var(--bg-color);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px 16px;
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(255, 122, 0, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(255, 122, 0, 0.05) 0%, transparent 40%);
        }
        .payment-wrapper {
            width: 100%;
            max-width: 520px;
            background: var(--surface-color);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(255, 255, 255, 0.05);
            overflow: hidden;
            animation: fadeIn 0.4s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .payment-header {
            padding: 24px 28px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--border-color);
        }
        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }
        .brand-logo img {
            height: 34px;
            object-fit: contain;
        }
        .brand-name {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-primary);
            letter-spacing: -0.5px;
        }
        .brand-name span {
            color: var(--primary);
        }
        .cancel-btn {
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 600;
            padding: 8px 14px;
            border-radius: 12px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .cancel-btn:hover {
            color: var(--text-primary);
            border-color: rgba(255, 255, 255, 0.25);
            background: rgba(255, 255, 255, 0.05);
        }
        .payment-body {
            padding: 24px 28px 28px;
        }
        .order-summary-box {
            background: var(--surface-card);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .kitchen-info {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .kitchen-avatar {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            object-fit: cover;
            background: #2A2D3D;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .kitchen-meta h4 {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 3px;
        }
        .kitchen-meta p {
            font-size: 12px;
            color: var(--text-secondary);
        }
        .order-total-display {
            text-align: right;
        }
        .order-total-display .total-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            margin-bottom: 2px;
        }
        .order-total-display .total-value {
            font-size: 20px;
            font-weight: 800;
            color: var(--primary);
        }
        .section-title {
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-secondary);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section-title svg {
            width: 16px;
            height: 16px;
            color: var(--primary);
        }
        #payment-element {
            margin-bottom: 24px;
            min-height: 180px;
        }
        #payment-error-message {
            display: none;
            background: rgba(239, 68, 68, 0.12);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #FCA5A5;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 20px;
            line-height: 1.4;
        }
        .submit-pay-button {
            width: 100%;
            height: 52px;
            background: linear-gradient(135deg, var(--primary), #FF5500);
            color: #FFFFFF;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 8px 24px var(--primary-glow);
            transition: all 0.2s ease;
        }
        .submit-pay-button:hover:not(:disabled) {
            background: linear-gradient(135deg, var(--primary-hover), #FF6611);
            transform: translateY(-1px);
            box-shadow: 0 12px 28px rgba(255, 122, 0, 0.35);
        }
        .submit-pay-button:active:not(:disabled) {
            transform: translateY(0);
        }
        .submit-pay-button:disabled {
            opacity: 0.65;
            cursor: not-allowed;
            filter: grayscale(20%);
        }
        .spinner {
            display: none;
            width: 22px;
            height: 22px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: #FFFFFF;
            animation: spin 0.8s linear infinite;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .security-footer {
            margin-top: 20px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
        }
        .security-footer svg {
            width: 14px;
            height: 14px;
            color: var(--success);
        }
        .skeleton-loader {
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding: 10px 0;
        }
        .skeleton-line {
            height: 48px;
            background: linear-gradient(90deg, #1d202b 25%, #2a2d3d 50%, #1d202b 75%);
            background-size: 200% 100%;
            animation: shimmer 1.5s infinite;
            border-radius: 10px;
        }
        @keyframes shimmer {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }
        @media (max-width: 480px) {
            .payment-header, .payment-body {
                padding-left: 20px;
                padding-right: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="payment-wrapper">
        <div class="payment-header">
            <a href="/" class="brand-logo">
                <img src="/assets/images/GoCheflogo.png" onerror="this.src='/favicon.png'; this.style.borderRadius='8px';" alt="GoChef">
                <span class="brand-name">Go<span>Chef</span></span>
            </a>
            <a href="/#/checkout" class="cancel-btn">Cancel</a>
        </div>
        <div class="payment-body">
            <div class="order-summary-box">
                <div class="kitchen-info">
                    <img src="<?php echo $kitchenAvatar ?: '/assets/images/GoCheflogo.png'; ?>" onerror="this.src='/favicon.png';" class="kitchen-avatar" alt="Kitchen">
                    <div class="kitchen-meta">
                        <h4><?php echo $kitchenName; ?></h4>
                        <p><?php echo $itemsCount; ?> Items • <?php echo $orderId; ?></p>
                    </div>
                </div>
                <div class="order-total-display">
                    <div class="total-label">Total to Pay</div>
                    <div class="total-value">$<?php echo $totalAmount; ?></div>
                </div>
            </div>
            <div class="section-title">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
                </svg>
                Payment Details
            </div>
            <form id="payment-form">
                <div id="payment-element">
                    <div class="skeleton-loader" id="payment-skeleton">
                        <div class="skeleton-line"></div>
                        <div class="skeleton-line"></div>
                    </div>
                </div>
                <div id="payment-error-message"></div>
                <button id="submit-btn" class="submit-pay-button" type="submit">
                    <span class="spinner" id="button-spinner"></span>
                    <span id="button-text">Pay $<?php echo $totalAmount; ?></span>
                </button>
            </form>
            <div class="security-footer">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                Guaranteed safe & secure checkout powered by Stripe
            </div>
        </div>
    </div>
    <script>
        const publishableKey = "<?php echo STRIPE_PUBLISHABLE_KEY; ?>";
        const clientSecret = "<?php echo $clientSecret; ?>";
        const orderId = "<?php echo $orderId; ?>";

        const stripe = Stripe(publishableKey);

        const appearance = {
            theme: 'night',
            variables: {
                colorPrimary: '#FF7A00',
                colorBackground: '#171923',
                colorText: '#FFFFFF',
                colorDanger: '#EF4444',
                fontFamily: 'Montserrat, sans-serif',
                borderRadius: '12px',
                spacingUnit: '4px',
            },
            rules: {
                '.Tab': {
                    backgroundColor: '#1f2230',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                },
                '.Tab:hover': {
                    borderColor: '#FF7A00',
                },
                '.Tab--selected': {
                    backgroundColor: '#272b3d',
                    borderColor: '#FF7A00',
                    boxShadow: '0 0 0 1px #FF7A00',
                },
                '.Input': {
                    backgroundColor: '#11131a',
                    border: '1px solid rgba(255, 255, 255, 0.12)',
                    color: '#FFFFFF',
                },
                '.Input:focus': {
                    borderColor: '#FF7A00',
                    boxShadow: '0 0 0 1px #FF7A00',
                },
                '.Label': {
                    color: '#9BA3AF',
                    fontWeight: '600',
                    fontSize: '12px',
                }
            }
        };

        const elements = stripe.elements({
            clientSecret: clientSecret,
            appearance: appearance
        });

        const paymentElement = elements.create('payment', {
            layout: 'tabs'
        });

        paymentElement.mount('#payment-element');

        paymentElement.on('ready', () => {
            const skeleton = document.getElementById('payment-skeleton');
            if (skeleton) skeleton.style.display = 'none';
        });

        const form = document.getElementById('payment-form');
        const submitBtn = document.getElementById('submit-btn');
        const buttonSpinner = document.getElementById('button-spinner');
        const buttonText = document.getElementById('button-text');
        const errorBox = document.getElementById('payment-error-message');

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            setLoading(true);
            errorBox.style.display = 'none';

            const { error } = await stripe.confirmPayment({
                elements,
                confirmParams: {
                    return_url: window.location.origin + '/#/payment_success?order_id=' + encodeURIComponent(orderId),
                },
            });

            if (error) {
                if (error.type === "card_error" || error.type === "validation_error") {
                    showError(error.message);
                } else {
                    showError("An unexpected error occurred. Please try again.");
                }
                setLoading(false);
            }
        });

        function showError(message) {
            errorBox.textContent = message;
            errorBox.style.display = 'block';
        }

        function setLoading(isLoading) {
            submitBtn.disabled = isLoading;
            if (isLoading) {
                buttonSpinner.style.display = 'inline-block';
                buttonText.textContent = 'Processing Securely...';
            } else {
                buttonSpinner.style.display = 'none';
                buttonText.textContent = 'Pay $<?php echo $totalAmount; ?>';
            }
        }
    </script>
</body>
</html>
