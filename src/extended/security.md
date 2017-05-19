# Security basics

---

## OWASP – Open Web Application Security Project

* **Not-for-profit** organization focused on **improving the security** of software;
* **Documentation** and **tools** to help learn about security, and protect your applications.

> [https://www.owasp.org](https://www.owasp.org)

---

## OWASP Top 10 – 2017

1. Injection
2. Broken Authentication and Session Management
3. Cross-Site Scripting (XSS)
4. Broken Access Control
5. Security Misconfiguration
6. Sensitive Data Exposure <small>← won't be covered here</small>
7. Insufficient Attack Protection <small>← won't be covered here</small>
8. Cross-Site Request Forgery (CSRF)
9. Using Components with Known Vulnerabilities
10. Underprotected APIs <small>← won't be covered here</small>

> [https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project<Paste>)

---

# 1. Injection

---

## OWASP definition

<p>
    <blockquote class="quote">
    Injection flaws, such as SQL, OS, XXE, and LDAP injection occur when <strong>untrusted
    data is sent to an interpreter</strong> as part of a command or query. The attacker’s
    <strong>hostile data can trick</strong> the interpreter into <strong>executing unintended commands</strong>
    or <strong>accessing data</strong> without proper authorization.
    </blockquote>
</p>

> [https://www.owasp.org/index.php/Category:Injection](https://www.owasp.org/index.php/Category:Injection)

---

## In other words

* When an application **sends untrusted data to an interpreter**;
* Attacker sends simple **text-based attacks** that exploit the syntax of the targeted interpreter;
* Almost **any source of data can be an attack vector**:
    - `GET`/`POST` parameters
    - `PATH_INFO`
    - HTTP headers
    - uploaded **files**
    - …
* Can result in **data loss or corruption** or denial of access.

---

## SQL injection

Unescaped user input causes the **premature end of a SQL query**,
and allows a malicious query to be executed:

    !php
    $query = 'SELECT * FROM foo WHERE bar = "' . $_GET['bar'] . '"';
    // example.org?bar=nope" OR 1 = 1 --

---

## Directory traversal attack

Filesystem access combined to unvalidated user input allows attackers to
**access private files**:

    !php
    echo file_get_contents(__DIR__.'/'.$_GET['file']);
    // example.org?file=../../private.conf

## Remote Code Execution

Unsafe input is **dynamically executed**:

    !php
    exec('rm -rf web/upload/' . $_GET['file']);
    // example.org?file=*; rm -rf /;

---

## How To Prevent Injections?

### Escape, escape, escape!

* SQL: **Prepared Statements** (PDO);
* Input/Output: `basename()`, `realpath()`;
* HTML: `htmlspecialchars()` (or better: use a template engine that escapes
  everything by default);
* System calls: `shell_escape_args()`;
* Cookies: make sure they contain what you expect;
* Validate **all** user input;
* Positive or **white-list** input validation;
* Avoid `eval()` or `exec()` functions.

---

# 2. Broken Authentication and Session Management

---

## In A Nutshell

* Attackers **use leaks or flaws in the authentication** or **session management functions** to impersonate users;
* May allows **some or even all accounts to be attacked**. Once successful, the **attacker can do anything the victim could do**.
* Privileged accounts are frequently targeted!

---

## How To Prevent This?

* **Hash and salt passwords** properly (**bcrypt**/**Blowfish** please);
    * Use the [Password Hashing API](http://www.php.net/manual/en/book.password.php) in PHP
    * See also [password_compat](https://github.com/ircmaxell/password_compat)
* **Never** ever **store passwords in clear text**;
* Don't put session IDs in URLs;
* Regenerate IDs when authentication changes;
* Allow session IDs to timeout/expire;
* Use HTTPS. ALWAYS.

---

## PHP Session Configuration

    !yaml
    ; Helps mitigate XSS by telling the browser not to expose the cookie to
    ; client side scripting such as JavaScript
    session.cookie_httponly = 1

    ; Prevents session fixation by making sure that PHP only uses cookies for
    ; sessions and disallow session ID passing as a GET parameter
    session.use_only_cookies = 1

    ; Better entropy source
    ; Evades insufficient entropy vulnerabilities
    session.entropy_file = "/dev/urandom"

    ; Might help against brut-force attacks too!
    session.entropy_length=32

    ; Smaller exploitation window for XSS/CSRF/Clickjacking...
    session.cookie_lifetime = 0

    ; Ensures session cookies are only sent over secure connections
    ; (it requires a valid SSL certificate)
    ; Related to OWASP 2013-A6-Sensitive Data Exposure
    session.cookie_secure = 1

---

# 3. Cross-Site Scripting (XSS)

---

## In A Nutshell

* The most prevalent web application security flaw!
* When an **application includes user supplied data** in a page sent to the browser **without properly validating or escaping that content**;
* Attacker sends **text-based attack scripts** that exploit the interpreter in the browser;
* Almost any source of data can be an attack vector, including internal sources such as **data from the database**, but also **URLs**, **form fields**;
* Can result in **session hijacking**, malicious scripts execution, website **defacement**.

---

## How To Prevent XSS?

### Do not trust anyone!

* **Escape** all untrusted data based on the HTML context will go through `htmlspecialchars()`;
* **Whitelist** input validation;
* Consider **auto-sanitization libraries** ([HTML Purifier](http://htmlpurifier.org/));
* Don't even trust admins;
* Secure your cookies (encrypt or sign them);
* Use template engines that **escape everything by default** (like Twig).

---

## Content Security Policy (CSP)

Defines the `Content-Security-Policy` HTTP header <br>that allows you to create
a **whitelist of sources of trusted content**, and **instructs the browser** to
only execute or<br>render resources from those sources.

    Content-Security-Policy: script-src 'self' https://apis.google.com

![](../images/csp.png)


> [An Introduction to Content Security Policy](http://www.html5rocks.com/en/tutorials/security/content-security-policy/)
>
> [Using Content-Security-Policy for Evil](http://homakov.blogspot.fr/2014/01/using-content-security-policy-for-evil.html)

---

# 4. Broken Access Control

---

## OWASP definition

<p>
    <blockquote class="quote">
    <strong>Restrictions</strong> on what authenticated users are allowed to do
    are <strong>not properly enforced</strong>. Attackers can exploit these flaws
    to <strong>access unauthorized functionality</strong> and/or data, such as
    access other users accounts, view sensitive files, modify other users
    data, change access rights, etc.
    </blockquote>
</p>

---

## How To Prevent This?

* Always **check the user credentials before allowing<br>access** to restricted content.

---

# 5. Security Misconfiguration

---

## In A Nutshell

* Attacker accesses **default accounts**, **unused pages**, **unpatched flaws**, **unprotected files** and directories, etc. to gain unauthorized access to or knowledge of the system;
* Can completely **compromise the system without you knowing it**. **All of your data can be stolen** or modified slowly over time;
* Recovery costs can be expensive!

---

## How To Prevent This?

* Have a process for **keeping on top of updates and patches**;
* Disable *risky* PHP native functions (`shell_exec`, …)
* Build a **strong application architecture** that provides **effective** and **secure** separation between components;
* Consider running **scans** and doing **audits** periodically;
* Let your webserver process run by a user with restricted permission. **Never** as root!

---

# 8. Cross-Site Request Forgery (CSRF)

---

## In A Nutshell

* Attacker creates **forged HTTP requests and tricks a victim into submitting
them** via image tags, XSS, Form POSTs, or numerous other techniques. If the user is authenticated, the attack succeeds;
* Attackers **can create malicious web pages** which generate **forged requests
that are indistinguishable from legitimate ones**;
* Causes victim to **change any data the victim is allowed to change**, but
also to **perform any function the victim is authorized to use**.

<i class="fa fa-bookmark"></i> [Facebook CSRF worth USD 5000](http://amolnaik4.blogspot.fr/2012/08/facebook-csrf-worth-usd-5000.html)
<br>
<i class="fa fa-bookmark"></i> [Does Google Understand CSRF?](http://cryptogasm.com/2012/02/does-google-understand-csrf/)
<br>
<i class="fa fa-bookmark"></i> [A few CSRF-like vulnerable examples.](http://homakov.blogspot.fr/2012/03/hacking-skrillformer-moneybookers.html)

---

## CSRF With GET

Using a zero-byte image attack:

    !html
    <img
        src="https://bank.com/transfer.do?acct=BOB&amount=100"
        height="0" width="0"
    />

Using a link, asking the victim to click on it:

    !html
    <a href="http://bank.com/transfer.do?acct=BOB&amount=100">
        View my Pictures!
    </a>

---

## CSRF With POST

A malicious page can issue a POST request to any domain:

    !html
    <form method="POST" action="http://example.org/form">
        <input type="text" name="name" value="Joe la frite">
        <input type="text" name="message" value="Hello, World!">
        <!-- ... -->
    </form>

With a few lines of JavaScript:

    !javascript
    $(document).ready(function() {
        $('form').submit();
    });

---

## How To Prevent This?

* Don't do "things" using the `GET` method;
* Create **one unique token per user** (at least once per session);
    * Include/verify it in every sensitive form;
    * Avoid putting this token in the query string.

---

## Same-Origin Policy

The same-origin policy **restricts how** a document
or **script** loaded from one origin **can
interact** with a resource from another origin.

<br>
![](../images/sameorigin.jpg)

---

# 9. Using Components with Known Vulnerabilities

---

## In A Nutshell

* Attacker identifies **a weak component through
scanning or manual analysis**. He customizes the
exploit as needed and executes the attack;
* Virtually **every application has these issues**
because most development teams don't focus on
ensuring their libraries<br>are up to date;
* In many cases, the developers don't even know all
the components they are using, never mind their
versions. **Component dependencies make things even
worse**;
* The impact could range **from minimal to complete
host takeover and data compromise**.

---

## How To Prevent This?

* **Keep** components **up to date**;
* Identify all components and versions;
* Monitor security of these components;
* Subscribe to security mailing-lists, twitter accounts
  <br>(e.g. [@debian_security](https://twitter.com/debian_security));
* Make sure your components aren't verbose.
  <br>(e.g. Webserver tellings its name and version)
* Require [`roave/security-advisories:dev-master`](https://github.com/Roave/SecurityAdvisories)
  in your `composer.json`;
* Use SensioLabs [Security Advisories Checker](https://security.sensiolabs.org/).
