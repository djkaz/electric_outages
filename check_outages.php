<?php
// Configuration
$url = "https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2F20250528%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3";
$recipient = "alex.tiron@direwolf.ro";
$subject = "Filtered Nuci Outage Reports";

// Load XML from RSS feed
$xmlContent = @file_get_contents($url);
if ($xmlContent === false) {
    die("Failed to load RSS feed.");
}

// Parse XML
$xml = new SimpleXMLElement($xmlContent);

// Filter items
$filteredItems = [];
foreach ($xml->channel->item as $item) {
    $title = (string) $item->title;
    $description = (string) $item->description;
    $pubDate = (string) $item->pubDate;

    if (stripos($title, 'nuci') !== false || stripos($description, 'nuci') !== false) {
        $filteredItems[] = "=== OUTAGE INFORMATION ===\nTitle: $title\nDescription: $description\nPublished: $pubDate\n";
    }
}

// Prepare and send email
if (!empty($filteredItems)) {
    $message = implode("\n\n", $filteredItems);
    $headers = "From: outage-notifier@yourdomain.com\r\n";

    if (mail($recipient, $subject, $message, $headers)) {
        echo "Email sent to $recipient with the filtered outage info.";
    } else {
        echo "Failed to send email.";
    }
} else {
    echo "No Nuci-related outages found.";
}
?>
