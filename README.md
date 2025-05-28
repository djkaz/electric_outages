# ⚡ Nuci Outage RSS Filter & Email Notifier

This project is a lightweight PHP-based tool that:

- Downloads an RSS feed containing outage information.
- Filters entries related to **"Nuci"** (case-insensitive).
- Sends the filtered results via email to a predefined recipient.
- Includes a simple web interface (`index.html`) to trigger the process.

---

## 📂 Project Structure

.
├── index.html # Simple form to trigger PHP script
├── check_outages.php # Core logic to fetch, filter, and send emails
└── README.md # Project documentation


---

## 🚀 How It Works

1. The user opens `index.html` in a browser.
2. A button click triggers `check_outages.php` via POST.
3. PHP downloads the RSS XML from a secure S3 link.
4. It parses XML for `<item>` elements.
5. Filters those containing "Nuci" in the `<title>` or `<description>`.
6. Sends an email to `alex.tiron@direwolf.ro` with the filtered results.

---

## 📧 Email Example

Subject: Filtered Nuci Outage Reports

=== OUTAGE INFORMATION ===
Title: Power Outage in Nuci Area
Description: A scheduled maintenance will occur in Nuci...
Published: Wed, 29 May 2025 08:00:00 GMT


---

## 🛠️ Requirements

- PHP 7.0+
- Internet access (to fetch RSS feed)
- Mail sending capabilities (`mail()` function enabled)

> 💡 Tip: For more reliable email delivery, consider using [PHPMailer](https://github.com/PHPMailer/PHPMailer).

---

## ✅ Setup & Usage

1. Clone or download this repo:
   ```bash
   git clone https://github.com/your-username/nuci-outage-notifier.git
   cd nuci-outage-notifier
Deploy to a PHP-enabled server (Apache, Nginx + PHP-FPM, etc).

Visit index.html in a browser.

Click "Check and Email Outages".

🔐 Security Notes
The RSS URL contains signed AWS credentials; consider rotating them or securing access.

Validate incoming requests in production (e.g. CSRF tokens or authentication).

Sanitize and escape output if expanding the UI.

📄 License
MIT License — Free to use, modify, and distribute.
