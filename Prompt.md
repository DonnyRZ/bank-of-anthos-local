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