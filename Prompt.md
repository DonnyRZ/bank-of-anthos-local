---

Prompt Lengkap: Implementasi Admin Dashboard pada Bank of Anthos

Tolong bantu saya mengimplementasikan fitur Admin Dashboard ke dalam proyek Bank of Anthos (https://github.com/GoogleCloudPlatform/bank-of-anthos),
dengan spesifikasi sebagai berikut:

1. Modifikasi Backend (`userservice`)

* Pada file src/accounts/userservice/db.py, tambahkan kolom role pada tabel users dengan tipe String dan default 'customer'.
* Pada file src/accounts/userservice/userservice.py:
* Saat login berhasil, sertakan klaim role ke dalam payload JWT.
* Tambahkan endpoint baru /users/all yang mengembalikan daftar semua pengguna dalam format JSON.

2. Implementasi Frontend (`frontend`)

* Pada file src/frontend/frontend.py:
* Tambahkan route /admin untuk halaman Admin Dashboard.
* Buat decorator @admin_required yang memvalidasi token JWT dan memastikan klaim role=admin. Jika tidak sesuai, tolak akses.
* Route /admin harus mengambil data dari tiga sumber:
1. Daftar pengguna dari endpoint userservice/users/all.
2. Jumlah total akun dari service balancereader.
3. Jumlah total transaksi dari service transactionhistory.
* Render data ke template baru bernama admin.html.
* Pada route /home, deteksi apakah pengguna yang login adalah admin (berdasarkan token JWT). Kirimkan variabel boolean is_admin ke template
index.html.
* Update: Modifikasi logika login untuk secara otomatis mengalihkan (redirect) pengguna ke /admin jika klaim role pada token JWT mereka
adalah 'admin'. Pengguna lain akan dialihkan ke /home.
* Buat file template src/frontend/templates/admin.html untuk menampilkan statistik dan tabel daftar pengguna.
* Di file src/frontend/templates/shared/navigation.html, tambahkan link "Admin Dashboard" di menu dropdown yang hanya tampil jika is_admin=true.

3. Migrasi User Admin Otomatis

* Pada userservice.py, tambahkan skrip migrasi yang dijalankan sekali saat aplikasi startup.
* Skrip harus memeriksa environment variable ADMIN_USERNAME dan ADMIN_PASSWORD.
* Jika ada, buat user admin secara idempotent (tidak membuat duplikat). Jika user sudah ada, pastikan perannya adalah admin.

4. Konfigurasi Deployment

* Pada file kubernetes-manifests/userservice.yaml, tambahkan environment variable ADMIN_USERNAME dan ADMIN_PASSWORD ke dalam container
userservice.
* Nilai harus bisa dikonfigurasi dari deployment manifest.

---

Potential Vulnerabilities:

* Insecure Password Storage: The create_user function uses bcrypt to hash passwords, which is a good practice. The salt is generated using
  bcrypt.gensalt(), which is the default and is sufficient.
* Improper Input Validation: The __validate_new_user function validates the new user's input. However, the validation is not complete. For example,
  the function does not validate the birthday, timezone, address, state, zip, or ssn fields. This could lead to a number of vulnerabilities, such as
  cross-site scripting or SQL injection.
* Use of `bleach.clean()`: The create_user and login functions use bleach.clean() to sanitize user input. This is a good practice that helps to
  prevent XSS attacks.
* Hardcoded Secrets: The code reads the private and public keys from files specified by the PRIV_KEY_PATH and PUB_KEY_PATH environment variables.
  While not directly in the code, this approach is still risky. If an attacker gains access to the environment variables, they can access the keys.

Recommendations:

* Complete Input Validation: The __validate_new_user function should be updated to validate all user input. This can be done by using a library, such
  as WTForms, or by manually validating the input.
* Hardcoded Secrets: Use a secret management system, such as Google Secret Manager or HashiCorp Vault, to store and manage secrets.

This concludes my analysis of the userservice service.

Overall Summary

The Bank of Anthos application has a number of potential security vulnerabilities. These vulnerabilities could be exploited by an attacker to gain
unauthorized access to the application, steal user data, or perform other malicious actions.

The most serious vulnerabilities are:

* Cross-Site Scripting (XSS): The application is vulnerable to XSS in the home function of frontend.py.
* Insecure JWT Verification: The application uses JWTs for authentication, but it does not always verify the signature of the JWT. This could allow an
  attacker to forge a JWT and gain unauthorized access to the application.
* Insecure Direct Object Reference (IDOR): The getAvailableBalance method in LedgerWriterController.java is vulnerable to IDOR. An attacker could use
  this method to retrieve the balance of any account, simply by providing the account number.
* Missing Input Sanitization: The application does not always sanitize user input. This could lead to a number of vulnerabilities, such as SQL
  injection or cross-site scripting.

I recommend that the developers of the Bank of Anthos application address these vulnerabilities as soon as possible.

I have completed my security analysis of the Gemini-generated code. Would you like me to generate a report of my findings?